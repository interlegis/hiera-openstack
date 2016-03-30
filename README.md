# hiera-openstack backend

This module allows hiera to look up entries in Openstack Compute (Nova) Metadata. 

# Installation

This module can be placed in your puppet module path and will be pluginsync'd to the master. 

You need to install ruby-openstack gem: 

<pre>
gem install openstack
</pre>

# Use

## Configuration example
<pre>

:openstack:
  :auth_url: https://your.openstack.cloud.domain:5000/v2.0
  :username: admin
  :password: password
  :tenant: admin

</pre>

## Puppet example


# Details

# Authors

  - Fabio Rauber     http://github.com/fabiorauber

