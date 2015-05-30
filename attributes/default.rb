# Installation
default[:dante][:source][:version]                =   '1.4.1'
default[:dante][:source][:url]                    =   'https://www.inet.no/dante/files/dante-1.4.1.tar.gz'

# Daemon / Init
default[:dante][:daemon][:binary]                 =   '/usr/local/sbin/sockd'
default[:dante][:daemon][:name]                   =   'sockd'

# Logging
default[:dante][:logging][:log_output]            =   'syslog stdout /var/log/sockd/sockd.log'
default[:dante][:logging][:log_file_path]         =   '/var/log/sockd/sockd.log'

# Server
# This is a shorthand for quickly setting one or several ip-addresses and a port
# By setting ip addresses and port, the settings for internals/externals won't be used
# If you'd like to define your own interfaces or ip-addresses for internals/externals, make sure to set the values below to nil!

default[:dante][:server][:ip_addresses]           =   [node[:ipaddress]]
default[:dante][:server][:port]                   =   1080

# Interfaces
# The newer versions of Dante supports IPv4 and IPv6
# Read more here https://www.inet.no/dante/doc/1.4.x/config/ipv6.html
default[:dante][:internal][:protocol]             =   'ipv4 ipv6'
default[:dante][:internal][:internals]            =   [{node[:ipaddress] => 1080}] # Hash key: interface/ip-address, hash value: port

default[:dante][:external][:protocol]             =   'ipv4 ipv6'
default[:dante][:external][:rotation]             =   nil # Possible values: route, same-same
default[:dante][:external][:externals]            =   [node[:ipaddress]] # Array value: interface/ip-address

# Authentication & Users
# Create users used to authenticate to the proxy server

# # User functionality is provided by the user cookbook: https://github.com/fnichol/chef-user
# The password for the user must be a shadow hash of the password, see http://stackoverflow.com/questions/22386777/how-do-i-determine-the-password-attribute-value-for-the-chef-user-resource#answer-22393308 for more info
# Command: openssl passwd -1 -salt "yoursaltphrase"

# Make sure to set default[:dante][:auth][:methods][:socks] to ['username'] to enable user/password authentication and disable anonymous auths
# Set the values below to nil if you won't be using system users to authenticate to the proxy server
default[:dante][:auth][:users][:login]            =   nil
default[:dante][:auth][:users][:password]         =   nil

# Auth configuration Settings
default[:dante][:auth][:methods][:client]         =   []
default[:dante][:auth][:methods][:socks]          =   ['username none'] # Default: enable anonymous auths

default[:dante][:auth][:users][:privileged]       =   "root"
default[:dante][:auth][:users][:unprivileged]     =   "nobody"
default[:dante][:auth][:users][:libwrap]          =   nil # Specify a user if libwrap is used

# Rules
default[:dante][:rules][:client][:pass]           =   [{:from => "0.0.0.0/0", :to => '0.0.0.0/0', :log => 'connect error'}]
default[:dante][:rules][:client][:block]          =   [{:from => "0.0.0.0/0", :to => '0.0.0.0/0', :log => 'connect error'}]
default[:dante][:rules][:socks][:pass]            =   [{:from => "0.0.0.0/0", :to => '0.0.0.0/0', :log => 'connect error'}]
default[:dante][:rules][:socks][:block]           =   [{:from => "0.0.0.0/0", :to => '0.0.0.0/0', :log => 'connect error'}]

# Connection options
default[:dante][:connection][:negotiate_timeout]  =   nil
default[:dante][:connection][:io_timeout]         =   nil
default[:dante][:connection][:src_host]           =   nil

# Compatibility
default[:dante][:compatibility]                   =   nil

# Extensions
default[:dante][:extensions]                      =   nil

# Routes
default[:dante][:routes]                          =   nil