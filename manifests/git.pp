class jiminy::git(
  $repo_path = '/var/repos',
) {
  if ! defined(Package['git']) {
    package { 'git':
      ensure => present,
    }
  }
  file { $repo_path :
    ensure => directory,
  }

  Jiminy::Git::Repo {
    repo_path => $repo_path,
    require   => File[$repo_path],
  }

  jiminy::git::repo{ 'modules': }
  jiminy::git::repo{ 'hiera'  : }
}
