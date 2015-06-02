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
  %w{ ruby-dev ruby-shadow }.each do |a_package|
    package a_package
  end
  
  user_account node[:dante][:auth][:users][:login] do
    password node[:dante][:auth][:users][:password]
    comment "Dante proxy user"
    action :create
  end
end

directory ::File.dirname(node[:dante][:logging][:error_log_file_path]) do
  owner   node[:dante][:auth][:users][:privileged]
  group   node[:dante][:auth][:users][:privileged]
  mode    00755
  
  action  :create
  
  only_if { node[:dante][:logging][:error_log_file_path] && !::File.exists?(::File.dirname(node[:dante][:logging][:error_log_file_path])) }
end

directory ::File.dirname(node[:dante][:logging][:log_file_path]) do
  owner   node[:dante][:auth][:users][:privileged]
  group   node[:dante][:auth][:users][:privileged]
  mode    00755
  
  action  :create
  
  only_if { node[:dante][:logging][:log_file_path] && !::File.exists?(::File.dirname(node[:dante][:logging][:log_file_path])) }
end

template "/etc/init.d/sockd" do
  cookbook "dante"
  source "dante/init.d.erb"
  owner "root"
  group "root"
  mode 0755
end

service 'sockd' do
  action [:start, :stop, :restart, :reload]
end

template "/etc/sockd.conf" do
  cookbook "dante"
  source "dante/sockd.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :start, resources(:service => "sockd"), :immediately
end