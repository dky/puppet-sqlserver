# == Class: sqlserver
#
# Full description of class sqlserver here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { sqlserver:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class sqlserver
{
  if ($operatingsystem != 'Windows')
  {
    err("This module works on Windows only!")
    fail("Unsupported OS")
  }

  $sql_repo    = 'http://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x64/'
  $sql_install = 'SQLEXPR_x64_ENU.exe'

  exec {'sqlserver-install-download':
    command  => "((new-object net.webclient).DownloadFile('${sql_repo}/${sql_install}','${core::cache_dir}/${sql_install}'))",
    creates  => "${core::cache_dir}/${sql_install}",
    provider => powershell,
    require  => [
                  File["${core::cache_dir}"],
                ]
  }

  $sa_password='D0gf00d'

  exec {'sqlserver-install':
    # First test, we can use /QS
    command  => "${core::cache_dir}/${sql_install} /QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=install /FEATURES=SQL,AS,RS,IS,Tools /INSTANCENAME=\"MSSQLSERVER\" /SECURITYMODE=SQL /SAPWD=\"${sa_password}\" /TCPENABLED=1",
    #creates => "${core::cache_dir}/${sql_install}",
    cwd      => "${core::cache_dir}",
    provider => windows,
    require  => [
                  File["${core::cache_dir}"],
                  Exec['sqlserver-install-download'],
                ]
  }
}
