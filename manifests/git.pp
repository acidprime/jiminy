class jiminy::git(
  $repo_path         = '/var/repos',
  $vcs_module_path   = "/etc/puppetlabs/puppet/${module_name}",
  $git_server        = 'classroom.puppetlabs.vm',
) {
  Exec {
    path => '/usr/bin:/bin:/user/sbin:/usr/sbin',
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

  Jiminy::Git::Repo {
    repo_path => $repo_path,
    require   => File[$repo_path],
  }

  jiminy::git::repo{ 'modules': }

  vcsrepo { $vcs_module_path :
      ensure   => present,
      provider => 'git',
      force    => true,
      source   => "ssh://${git_server}/${repo_path}/modules.git"
  }

  # Configure ssh private keys on our masters
  file {'/root/.ssh':
    ensure => directory,
    mode   => '0600',
  }
  exec { 'generate_key':
    command => 'ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa',
    creates => '/root/.ssh/id_rsa',
    require => File['/root/.ssh'],
  }

  # TODO:enable store configs

  # If we are the git server then export our known host
  if $::fqdn == $git_server {
    @@sshkey { $::hostname :
      ensure          => present,
      host_aliases    => [$::fqdn, $::ipaddress ],
      type            => 'rsa',
      key             => $::sshrsakey,
      tag             => $module_name,
    }
    # Collect the authorized_keys from all hosts
    Ssh_authorized_key <<| tag == $module_name |>> {
      before => Vcsrepo[$vcs_module_path],
    }
  }

  if $::root_ssh_key {
     @@ssh_authorized_key { $::fqdn :
       key     => $::root_ssh_key,
       type    => 'ssh-rsa',
       user    => 'root',
       tag     => $module_name,
       require => File['/root/.ssh'],
     }
   }

  # Collect the git server's key on all hosts
  Sshkey <<| tag == $module_name |>> {
    before => Vcsrepo[$vcs_module_path],
  }

}
