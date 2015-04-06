
class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

include_recipe 'openstack-block-storage::cinder-common'

platform_options = node['openstack']['block-storage']['platform']

platform_options['cinder_backup_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']
    action :upgrade
  end
end

case node['openstack']['block-storage']['backup']['driver']
when 'cinder.backup.drivers.ceph'
  include_recipe 'ceph'
# TODO ensure cephx authorization without repeating code already in volume recipe
end

service 'cinder-backup' do
  service_name platform_options['cinder_backup_service']
  provider Chef::Provider::Service::Upstart if node[:platform] == 'ubuntu'
  supports status: true, restart: true
  action [:enable, :start]
  subscribes :restart, 'template[/etc/cinder/cinder.conf]'
end
