class jiminy::r10k {
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
}
