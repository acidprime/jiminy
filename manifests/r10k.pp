class jiminy::r10k(
  $remote,
  $cachedir   = '/var/cache/r10k',
  $basedir    = '/etc/puppetlabs/puppet/environments',
  $purgedirs  = $basedir,
  $configfile = '/etc/r10k.yaml'
){
  # https://projects.puppetlabs.com/issues/19741
  class {'ruby':
    rubygems_update => false,
  }
  include 'ruby::dev'
  if ! defined(Package['r10k']) {
    package { 'r10k':
      ensure   => present,
      provider => 'gem',
      require  => [Class['ruby'],Class['ruby::dev']],
    }
  }
  if ! defined(Package['make']) {
    package { 'make':
      ensure => present,
    }
  }
  if ! defined(Package['gcc']) {
    package { 'gcc':
      ensure => installed,
    }
  }
  file { $configfile :
    ensure  => present,
    content => template("${module_name}/${configfile}"),
  }
}
