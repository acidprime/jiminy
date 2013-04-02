class jiminy::git(
  $repo_path         = '/var/repos',
  $vcs_module_path   = "/etc/puppetlabs/puppet/${module_name}",
  $git_server        = 'classroom.puppetlabs.vm',
) {
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

    file { "${vcs_module_path}/.gitignore":
      ensure  => file,
      notify  => Exec['git add .gitignore'],
      require => Vcsrepo[$vcs_module_path],
    }

    file {'post-receive':
      ensure  => file,
      path    => "${repo_path}/modules.git/hooks/post-receive",
      source  => "puppet:///modules/${module_name}/post-receive",
      require => Vcsrepo[$vcs_module_path],
    }

    exec { 'git add .gitignore':
      command     => 'git add .gitignore',
      cwd         => $vcs_module_path,
      refreshonly => true,
      notify      => Exec['intial commit'],
    }
    exec { 'intial commit':
      command     => 'git commit .gitignore -m "intial commit"',
      cwd         => $vcs_module_path,
      refreshonly => true,
      notify      => Exec['push origin master'],
    }
    exec { 'push origin master':
      command     => 'git push origin master',
      cwd         => $vcs_module_path,
      refreshonly => true,
      before      => Exec['create production branch'],
    }
    exec { 'create production branch':
      command => 'git branch production',
      cwd     => "${repo_path}/modules.git",
      creates => "${repo_path}/modules.git/refs/heads/production",
      notify  => Exec['change HEAD to production'],
    }
    exec { 'change HEAD to production':
      command     => 'git symbolic-ref HEAD refs/heads/production',
      cwd         => "${repo_path}/modules.git",
      refreshonly => true,
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
    augeas{'puppet.conf modulepath' :
      context => '/files//puppet.conf/main',
      changes => 'set modulepath $confdir/environments/$environment:/opt/puppet/share/puppet/modules',
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
