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
  $setup_git         = true,
  $setup_r10k        = $setup_git,
  $vcs_module_path   = $jiminy::params::vcs_module_path,
  $dyn_module_path   = $jiminy::params::dyn_module_path,
  $repo_path         = $jiminy::params::repo_path,
  $git_server        = $jiminy::params::git_server,
  $agent_name        = $jiminy::params::mc_agent_name,
  $app_name          = $jiminy::params::mc_app_name,
  $agent_ddl         = $jiminy::params::mc_agent_ddl_name,
  $agent_path        = $jiminy::params::mc_agent_path,
  $app_path          = $jiminy::params::mc_application_path,
  $mc_service        = $jiminy::params::mc_service_name,
  $is_master         = true #str2bool($::fact_is_puppetmaster),
) inherits jiminy::params {

  # Sanity check
  validate_bool($setup_git)
  validate_bool($setup_r10k)

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service[$mc_service],
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

  # Unless we are an agent only , install git repos
  if $setup_git {

    include jiminy::git

    # We automatically setup r10k if we setup git
    if $setup_r10k {
      class {'jiminy::r10k':
        remote => "ssh://${git_server}${repo_path}/modules.git",
      }
    }
  }
}
