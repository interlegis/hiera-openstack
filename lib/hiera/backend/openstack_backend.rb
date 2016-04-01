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


      # Tranforms an OpenStack type Object into a Hash
      def hashit(object)
        if object.class.to_s == "OpenStack::Compute::Metadata"
          meta = []
          object.each_pair do |k , v|
            meta.push [ k, v ]
          end
          return Hash[meta]
        elsif object.class.to_s == "OpenStack::Compute::AddressList"
          addresses = []
          object.each do |addr|
            addresses.push hashit(addr)
          end
          return addresses
        else
          properties = Hash.new
          object.instance_variables.each do |x|
            propertyclass = object.instance_variable_get(x).class.to_s
            # I don't want Hiera to print all the Openstack connection details...
            if propertyclass == "OpenStack::Compute::Connection"
              next
            elsif propertyclass == "Hash" and x.to_s == '@flavor'
              properties[x[1..-1]] = hashit(@connection.flavor(object.instance_variable_get(x)['id']))
            elsif propertyclass.include? "OpenStack" 
              properties[x[1..-1]] = hashit(object.instance_variable_get(x))
            else
              properties[x[1..-1]] = object.instance_variable_get(x)
            end
          end
          return properties
        end
      end


      # Helper for parsing config. Does not Hiera provide one?
      def get_config_value(label, default)
        if Config.include?(:openstack) && Config[:openstack].include?(label)
          Config[:openstack][label]
        else
          default
        end
      end

      # Main Hiera lookup function
      def lookup(key, scope, order_override, resolution_type)
        conf = Config[:openstack] 
        answer = []

        Hiera.debug("Looking up #{key} in openstack metadata backend")

        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for data source #{source}")
          if source == 'common' and key == 'servers'
            @connection.servers.each do |server|
                answer.push hashit(@connection.server(server[:id]))
            end
          else 
            @connection.servers.each do |server| 
              if server[:name] == source
                Hiera.debug("Found server #{server[:name]} with id #{server[:id]}")
                if @connection.server(server[:id]).respond_to?(key)
                  property = @connection.server(server[:id]).send(key)
                  case key
                  when 'flavor'
                    oflavor = @connection.flavor(property['id'])
                    answer.push hashit(oflavor)
                  else
                    Hiera.debug ( "Property classname: #{property.class.to_s}")
                    answer.push hashit(property)
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
          end #end else
        end #end datasources

        return answer unless answer == []
        rescue Exception => e
          Hiera.debug("Exception: #{e}")
        end
    end
  end
end
