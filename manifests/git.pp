class jiminy::git(
  $repo_path         = '/var/repos',
  $vcs_module_path   = "/etc/puppetlabs/puppet/${module_name}",
  $git_server        = 'classroom.puppetlabs.vm',
) {

  if ! defined(Package['git']) {
    package { 'git':
      ensure => present,
    }
  }

  # Create our repository path
  file { $repo_path :
    ensure => directory,
  }

  Jiminy::Git::Repo {
    repo_path => $repo_path,
    require   => File[$repo_path],
  }

  jiminy::git::repo{ 'modules': }

  vcsrepo { $vcs_module_path :
      ensure   => present,
      provider => 'git',
      force    => true,
      source   => "ssh://${git_server}/${repo_path}/modules.git",
      require  => Package['git'],
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
