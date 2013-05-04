# == Class: jiminy
#
# This class automatically configures a set of puppet masters with r10k
#
# === Parameters
#
# Document parameters here.
#
# [*is_master*]
#   boolean , determine if the system is a master using this boolean
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*setup_git*]
#  Should this module setup a bare git repo on the git_server (ca_server)
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
  $dyn_module_path   = [ $jiminy::params::dyn_module_path ],
  $is_master         = $jiminy::params::is_master,
  $setup_git         = $jiminy::params::setup_git,
  $setup_r10k        = $jiminy::params::setup_r10k,
  $vcs_module_path   = $jiminy::params::vcs_module_path,
  $repo_path         = $jiminy::params::repo_path,
  $git_server        = $jiminy::params::git_server,
  $agent_name        = $jiminy::params::mc_agent_name,
  $app_name          = $jiminy::params::mc_app_name,
  $agent_ddl         = $jiminy::params::mc_agent_ddl_name,
  $agent_path        = $jiminy::params::mc_agent_path,
  $app_path          = $jiminy::params::mc_application_path,
  $mc_service        = $jiminy::params::mc_service_name,
  $remote            = $jiminy::params::remote,
) inherits jiminy::params {

  # Sanity checks
  include jiminy::sanity

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service[$mc_service],
  }

  if $is_master {

    # Install the agent and its ddl file
    file { "${app_path}/${app_name}"  :
      source => "puppet:///modules/${module_name}/application/${agent_name}",
    }

    file { "${agent_path}/${agent_ddl}"  :
      source => "puppet:///modules/${module_name}/agent/${agent_ddl}",
    }

    # Install the application file (all masters at the moment)
    file { "${agent_path}/${agent_name}" :
      source  => "puppet:///modules/${module_name}/agent/${agent_name}",
      require => File["${agent_path}/${agent_ddl}"],
    }

    # Create a service resource for the notification
    if ! defined(Service[$mc_service]) {
      service { $mc_service :
        ensure => running,
      }
    }
  }

  # Unless we are a puppet agent , install git repos
  if $setup_git {
    # Automatically setup remote & local repos on all systems
    include jiminy::git

    # We automatically setup r10k if we setup git atm
    if $setup_r10k {
      include jiminy::r10k
    }
  }
}
