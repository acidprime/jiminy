class jiminy::git::ssh(
  $git_server      = $jiminy::params::git_server,
  $vcs_module_path = $jiminy::params::vcs_module_path,
) inherits jiminy::params {

  Exec {
    path => '/usr/bin:/bin:/user/sbin:/usr/sbin',
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
