class jiminy::r10k(
  $remote     = $jiminy::params::remote,
  $purgedirs  = $basedir,
  $cachedir   = '/var/cache/r10k',
  $basedir    = "${::settings::confdir}/environments",
  $configfile = '/etc/r10k.yaml'
) inherits jiminy::params {
  Class['ruby'] -> Class['ruby::dev'] -> Package['gcc']

  # rubygems_update => false
  # https://projects.puppetlabs.com/issues/19741
  class {'ruby':
    rubygems_update => false,
  }
  class { 'ruby::dev':}


  Package['gcc'] -> Package['make'] -> Package['r10k']

  # Install the r10k gem & dependacies
  if ! defined(Package['gcc']) {
    package { 'gcc':
      ensure => installed,
    }
  }

  if ! defined(Package['make']) {
    package { 'make':
      ensure => present,
    }
  }

  package { 'r10k':
    ensure   => present,
    provider => 'gem',
  }

  file { $configfile :
    ensure  => present,
    content => template("${module_name}/${configfile}"),
  }
}
