include_recipe "build-essential"
 
remote_file "#{Chef::Config[:file_cache_path]}/dante-#{node[:dante][:source][:version]}.tar.gz" do
  source node[:dante][:source][:url]
  mode      "0644"
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/dante-#{node[:dante][:source][:version]}.tar.gz") }
end

bash "Extract Dante source" do
  cwd Chef::Config[:file_cache_path]
  
  dante_path = "#{Chef::Config[:file_cache_path]}/dante-#{node[:dante][:source][:version]}"
  
  code <<-EOH
    tar -zxvf #{dante_path}.tar.gz
    if test -e #{dante_path}-release; then mv #{dante_path}-release #{dante_path}; fi;
  EOH

  not_if { ::File.exists?(dante_path) }
end
 
bash "Build and Install Dante" do
  cwd "#{Chef::Config[:file_cache_path]}/dante-#{node[:dante][:source][:version]}"
  
  code <<-EOH
    ./configure
    make
    make install
  EOH
end

if node[:dante][:auth][:users][:login] && node[:dante][:auth][:users][:password]
  # The following packages are required in order to set the password for the login user
  package %w{ ruby-dev ruby-shadow } do
    retries 3
    retry_delay 3
  end
  
  user_account node[:dante][:auth][:users][:login] do
    password node[:dante][:auth][:users][:password]
    comment "Dante proxy user"
    action :create
  end
end

log_dirs = [
  ::File.dirname(node[:dante][:logging][:log_file_path]),
  ::File.dirname(node[:dante][:logging][:error_log_file_path])
].uniq

log_dirs.each do |log_dir|
  directory log_dir do
    owner   node[:dante][:auth][:users][:privileged]
    group   node[:dante][:auth][:users][:privileged]
    mode    00755
  
    action  :create
  
    only_if { !::File.exists?(log_dir) }
  end
  
  logrotate_app "sockd" do
    cookbook "logrotate"
    path "#{log_dir}/*.log"
    enable true
    frequency "daily"
    rotate 2
    options ["compress", "copytruncate", "delaycompress", "missingok"]
  end
end

template "/etc/init.d/sockd" do
  source "init/init.d.erb"
  owner "root"
  group "root"
  mode 0755
  only_if { platform?('ubuntu') && Chef::VersionConstraint.new('< 15.04').include?(node['platform_version']) }
end

template "/etc/systemd/system/sockd.service" do
  source 'systemd/sockd.service.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  only_if { platform?('ubuntu') && Chef::VersionConstraint.new('>= 15.04').include?(node['platform_version']) }
end

execute 'systemctl daemon-reload' do
  action :nothing
end

directory ::File.dirname(node[:dante][:configuration_file]) do
  owner "root"
  group "root"
  mode 0755
  action :create
  not_if { File.exist?(::File.dirname(node[:dante][:configuration_file])) }
end

template node[:dante][:configuration_file] do
  source "dante/sockd.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

service 'sockd' do
  service_name node[:dante][:daemon][:name]
  action [:enable, :start]
  provider (platform?('ubuntu') && Chef::VersionConstraint.new('>= 15.04').include?(node['platform_version'])) ? Chef::Provider::Service::Systemd : nil
end
