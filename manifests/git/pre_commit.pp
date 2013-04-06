class jiminy::git::pre_commit(
  $vcs_module_path = $jiminy::params::vcs_module_path,
) inherits jiminy::params {

  # Create the pre-commit hook in the jiminy working repo
  file { '.git/hooks/pre-commit':
    ensure  => file,
    mode    => '0755',
    path    => "${vcs_module_path}/.git/hooks/pre-commit",
    source  => "puppet:///modules/${module_name}/pre-commit",
    require => Vcsrepo[$vcs_module_path],
  }

  # Same dependancies as r10k to be safe
  Class['ruby'] -> Class['ruby::dev'] -> Package['puppet-lint']

  # Add the package if its not already defined in the catalog
  if ! defined(Package['puppet-lint']) {
    package { 'puppet-lint':
      ensure   => present,
      provider => 'gem',
    }
  }
}
