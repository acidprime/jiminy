# == Class: jiminy
#
# Full description of class jiminy here.
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
#  class { jiminy:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <zack@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013 Zack Smith, unless otherwise noted.
#
class jiminy (
  $agent_name = "${jiminy::params::mc_agent_name}.rb",
  $app_name   = "${jiminy::params::mc_app_name}.rb",
  $agent_ddl  = "${jiminy::params::mc_agent_name}.ddl",
  $agent_path = $jiminy::params::mc_agent_path,
  $app_path   = $jiminy::params::mc_application_path,
  $mc_service = $jiminy::params::mc_service_name,
  $setup_git  = true,
  $setup_r10k = true,
  $is_master  = true #str2bool($::fact_is_puppetmaster),
) inherits jiminy::params {

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service[$jiminy::params::mc_service_name],
  }

  if $is_master {
    file { "${app_path}/${app_name}"  :
      source => "puppet:///modules/${module_name}/application/${agent_name}",
    }

    file { "${agent_path}/${agent_ddl}"  :
      source => "puppet:///modules/${module_name}/agent/${agent_ddl}",
    }

    file { "${agent_path}/${agent_name}" :
      source  => "puppet:///modules/${module_name}/agent/${agent_name}",
      require => File["${agent_path}/${agent_ddl}"],
    }
    if ! defined(Service[$mc_service]) {
      service { $mc_service :
        ensure => running,
      }
    }
  }
  if $setup_git {
    include jiminy::git
  }
  if $setup_r10k {
    include jiminy::r10k
  }
}
