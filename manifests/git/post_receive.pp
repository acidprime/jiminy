class jiminy::git::post_receive (
  $repo_path = $jiminy::params::repo_path,
) inherits jiminy::params {

  # make sure this is executable
  file {'post-receive':
    ensure  => file,
    mode    => '0755',
    path    => "${repo_path}/modules.git/hooks/post-receive",
    source  => "puppet:///modules/${module_name}/post-receive",
  }
}
