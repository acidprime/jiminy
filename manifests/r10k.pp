class jiminy::r10k(
  $remote,
  $cachedir   = '/var/cache/r10k',
  $basedir    = '/etc/puppetlabs/puppet/environments',
  $purgedirs  = $basedir,
  $configfile = '/etc/r10k.yaml'
){
  include 'ruby'
  include 'ruby::dev'
  #/usr/bin/gem install --include-dependencies --no-rdoc --no-ri r10k' returned 1: ERROR:  While executing gem ... (OptionParser::InvalidOption)
  #    invalid option: --include-dependencies
  #if ! defined(Package['r10k']) {
  #  package { 'r10k':
  #    ensure   => present,
  #    provider => 'gem',
  #    require  => [Class['ruby'],Class['ruby::dev']],
  #  }
  #}
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
