require 'rubygems'
require 'openstack'

class Hiera
  module Backend
    class Openstack_backend
      def initialize
        conf = Config[:openstack]

        Hiera.debug("Hiera Openstack backend starting")

        @connection = OpenStack::Connection.create({
          :username        => get_config_value(:username, "admin"),
          :api_key         => conf[:password],
          :auth_method     => "password",
          :auth_url        => conf[:auth_url],
          :authtenant_name => get_config_value(:tenant, "admin"),
          :service_type    => "compute"})
      end

      def hashit(object)
        properties = Hash.new
        object.instance_variables.each {|x| properties[x[1..-1]] = object.instance_variable_get(x) }
        return properties
      end


      # Helper for parsing config. Does not Hiera provide one?
      def get_config_value(label, default)
        if Config.include?(:openstack) && Config[:openstack].include?(label)
          Config[:openstack][label]
        else
          default
        end
      end

      def lookup(key, scope, order_override, resolution_type)
        conf = Config[:openstack] 
        answer = []

        Hiera.debug("Looking up #{key} in openstack metadata backend")

        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for data source #{source}")
          @connection.servers.each do |server| 
            Hiera.debug("Server: #{server[:name]} with id #{server[:id]}")
            if server[:name] == source
              if @connection.server(server[:id]).respond_to?(key)
                property = @connection.server(server[:id]).send(key)
                case key
                when 'addresses'
                  property.each do |addr|
                    answer.push hashit(addr)
                  end
                when 'flavor'
                  oflavor = @connection.flavor(property['id'])
                  answer.push hashit(oflavor)
                when 'metadata'
                  meta = []
                  property.each_pair do |k , v|
                    meta.push [ k , v ]
                  end
                  answer.push Hash[meta]
                else
                  answer.push property
                end
              end
              @connection.server(server[:id]).metadata.each_pair do |k , v|
                Hiera.debug("Found metadata with key #{k}.")
                if k == key
                  answer.push v 
                end
              end
            end
          end
        end #end datasources

        return answer
        rescue Exception => e
          Hiera.debug("Exception: #{e}")
        end
    end
  end
end
