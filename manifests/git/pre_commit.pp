class jiminy::git::pre_commit(
  $vcs_module_path = $jiminy::params::vcs_module_path,
) inherits jiminy::params {
  file { '.git/hooks/pre-commit':
    ensure  => file,
    mode    => '0755',
    path    => "${vcs_module_path}/.git/hooks/pre-commit",
    source  => "puppet:///modules/${module_name}/pre-commit",
    require => Vcsrepo[$vcs_module_path],
  }

  Class['ruby'] -> Class['ruby::dev'] -> Package['puppet-lint']

  if ! defined(Package['puppet-lint']) {
    package { 'puppet-lint':
      ensure   => present,
      provider => 'gem',
    }
  }
}
