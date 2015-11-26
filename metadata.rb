name              "dante"
maintainer        "Sebastian Johnsson"
maintainer_email  "sebastian@agiley.se"
license           "Private"
description       "Installs and configures the Dante SOCKS proxy server"
version           "0.0.2"

recipe "dante",         "Default recipe"
recipe "dante::source", "Installs and compiles Dante from source"

%w{ ubuntu }.each do |os|
  supports os
end

%w{ build-essential user logrotate }.each do |cb|
  depends cb
end