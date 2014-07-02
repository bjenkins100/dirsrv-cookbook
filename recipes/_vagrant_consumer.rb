#
# Cookbook Name:: dirsrv
# Recipe:: _vagrant_consumer
#
# Copyright 2013, Alan Willis <alwillis@riotgames.com>
#
# All rights reserved
#

include_recipe "dirsrv"

dirsrv_instance node[:hostname] + '_389' do
  has_cfgdir    true
  cfgdir_addr   '29.29.29.10'
  cfgdir_domain "vagrant"
  cfgdir_ldap_port 389
  credentials  node[:dirsrv][:credentials]
  cfgdir_credentials  node[:dirsrv][:cfgdir_credentials]
  host         node[:fqdn]
  suffix       'o=vagrant'
  action       [ :create, :start ]
end

include_recipe "dirsrv::_vagrant_replication"

# o=vagrant replica

dirsrv_replica 'o=vagrant' do
  credentials  node[:dirsrv][:credentials]
  instance     node[:hostname] + '_389'
  id           6
  role         :consumer
end

# link back to hub
dirsrv_agreement 'consumer-hub' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.15'
  suffix 'o=vagrant'
  description 'supplier link from consumer to hub'
  replica_host '29.29.29.11'
  replica_credentials 'CopyCat!'
end

# Request initialization from hub
dirsrv_agreement 'hub-consumer' do
  credentials  node[:dirsrv][:credentials]
  host '29.29.29.11'
  suffix 'o=vagrant'
  description 'supplier link from hub to consumer'
  replica_host '29.29.29.15'
  replica_credentials 'CopyCat!'
end

# Write an entry for this node
dirsrv_entry "ou=#{node[:hostname]},o=vagrant" do
  credentials  node[:dirsrv][:credentials]
  port        389
  attributes  ({ objectClass: [ 'top', 'organizationalUnit' ], l: [ 'PA', 'CA' ], telephoneNumber: '215-310-5555' })
  prune      ([ :postalCode, :description ])
end
