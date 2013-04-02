class jiminy::git(
  $git_server        = $jiminy::params::git_server,
  $repo_path         = $jiminy::params::repo_path,
  $vcs_module_path   = $jiminy::params::vcs_module_path,
  $dyn_module_path   = $jiminy::params::dyn_module_path,
) inherits jiminy::params {
  Exec {
    path => '/usr/bin'
  }

  if ! defined(Package['git']) {
    package { 'git':
      ensure => present,
    }
  }

  Jiminy::Git::Repo {
    repo_path => $repo_path,
    require   => File[$repo_path],
  }

  # Create our repository path
  file { $repo_path :
    ensure => directory,
  }

  jiminy::git::repo{ 'modules':}

  # hacky must refactor

  if $::fqdn == $git_server {
    # Export & Collect on the git server
    @@vcsrepo { $vcs_module_path :
        ensure   => present,
        provider => 'git',
        force    => true,
        source   => "ssh://${git_server}/${repo_path}/modules.git",
        tag      => $module_name,
        require  => Package['git'],
    }
    Vcsrepo<<| tag == $module_name |>>

    file {'post-receive':
      ensure  => file,
      mode    => '0755',
      path    => "${repo_path}/modules.git/hooks/post-receive",
      source  => "puppet:///modules/${module_name}/post-receive",
      require => Vcsrepo[$vcs_module_path],
    }
    class { 'jiminy::git::branch' :
      repo_path       => $repo_path,
      vcs_module_path => $vcs_module_path,
    }
  }
  else {
    Vcsrepo<<| tag == $module_name |>>{
      revision => 'production',
      notify   => Exec['r10k sync'],
    }
    exec { 'r10k sync':
      command     => 'r10k synchronize',
      refreshonly => true,
      require     => Class['jiminy::r10k'],
      before      => Augeas['puppet.conf modulepath'],
    }

    # Configure out dynamic environment module path
    augeas{'puppet.conf modulepath' :
      context => '/files//puppet.conf/main',
      changes => "set modulepath ${dyn_module_path}",
    }
  }

  file { '.git/hooks/pre-commit':
    ensure  => file,
    mode    => '0755',
    path    => "${vcs_module_path}/.git/hooks/pre-commit",
    source  => "puppet:///modules/${module_name}/pre-commit",
    require => Vcsrepo[$vcs_module_path],
  }

  if ! defined(Package['puppet-lint']) {
    package { 'puppet-lint':
      ensure   => present,
      provider => 'gem',
      require  => [Class['ruby'],Class['ruby::dev']],
    }
  }

  # TODO:enable store configs
  class { 'jiminy::git::ssh':
    git_server => $git_server,
  }
}
