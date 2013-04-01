define jiminy::git::repo (
  $repo_path    = '/var/repositories',
) {
  vcsrepo { "${repo_path}/${name}.git":
    ensure   => bare,
    provider => git,
  }
}
