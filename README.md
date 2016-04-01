# hiera-openstack backend

This module allows hiera to look up entries in Openstack Compute (Nova) Metadata, using the ruby-openstack library. 
(https://github.com/ruby-openstack/ruby-openstack)

# Installation

This module can be placed in your puppet module path and will be pluginsync'd to the master. 

You need to install ruby-openstack gem. Make sure you have ruby-dev package installed. 

<pre>
apt-get install ruby-dev
gem install openstack
</pre>

# Use

## Configuration example

The following configuration will allow Hiera to get all properties of the instance with the name == "%{::hostname}". 

<pre>
# /etc/puppet/hiera.yaml
---
:backends:
  - openstack

:hierarchy:
  - "%{::hostname}"
  - common

:openstack:
  :auth_url: https://your.openstack.cloud.domain:5000/v2.0
  :username: admin
  :password: password
  :tenant: admin

</pre>

## Hiera keys

The following properties are defined, in addition of whatever the user defines inside the instance metadata:

- id
- name
- status
- progress
- accessipv4
- accessipv6
- addresses
- hostId
- image
- flavor
- metadata
- adminPass
- key_name
- created
- security_groups

The special key "servers", from the scope "common", lists all you project instances with their properties.

# Authors

  - Fabio Rauber     http://github.com/fabiorauber

