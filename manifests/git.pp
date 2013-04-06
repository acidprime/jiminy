class jiminy::git(
  $git_server        = $jiminy::params::git_server,
  $repo_path         = $jiminy::params::repo_path,
  $vcs_module_path   = $jiminy::params::vcs_module_path,
  $dyn_module_path   = $jiminy::params::dyn_module_path,
  $remote            = $jiminy::params::remote,
) inherits jiminy::params {

  Exec {
    path => '/usr/bin'
  }
  #############################################################################
  # Configure our git server
  #############################################################################
  if $::fqdn == $git_server {
    # Export & Collect on the git server
    @@vcsrepo { $vcs_module_path :
        ensure   => present,
        provider => 'git',
        force    => true,
        source   => $remote,
        tag      => $module_name,
        require  => Package['git'],
    }
    Vcsrepo<<| tag == $module_name |>>

    # Setup post-receive where the magic happens
    # with the jiminy mcollective agent
    class {'jiminy::git::post_receive':
      require => Vcsrepo[$vcs_module_path],
    }

    # Setup the intial commit & production branch
    include jiminy::git::branch
  }
  #############################################################################
  # Configure our git clients on all non git servers
  #############################################################################
  else {

    # Clone the production branch of the jiminy repo
    # Once collected & complete setup ./environments using r10k
    # This collection happens a little differently  in that we clone the prod b
    Vcsrepo<<| tag == $module_name |>>{
      revision     => 'production',
      notify       => Class['jiminy::r10k::sync'],
    }

    # Setup our dynamic environments with r10k
    include jiminy::r10k::sync

    # Setup our pre-commit hook in our jiminy repo
    include jiminy::git::pre_commit
  }

  # Configure ssh keys on all machines
  include jiminy::git::ssh

  # This is a one shot define for the time being
  jiminy::git::repo{ 'modules':
    repo_path => $repo_path,
    require   => File[$repo_path],
  }

  if ! defined(Package['git']) {
    package { 'git':
      ensure => present,
    }
  }

  # Create our repository path
  file { $repo_path :
    ensure => directory,
  }

}
