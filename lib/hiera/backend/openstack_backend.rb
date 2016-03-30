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

        #Backend.datasources(scope, order_override) do |source|
        #  Hiera.debug("Looking for data source #{source}")
        #  begin

        # end #end datasources
      rescue Exception => e
        Hiera.debug("Exception: #{e}")
      end
    end
  end
end
