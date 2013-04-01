define jiminy::git::repo (
  $path    = '/var/repositories',
) {
  vcsrepo { "${path}/${name}.git":
    ensure   => bare,
    provider => git,
  }
}
