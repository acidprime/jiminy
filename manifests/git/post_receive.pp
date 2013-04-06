class jiminy::git::post_receive (
  $repo_path = $jiminy::params::repo_path,
) inherits jiminy::params {

  # Create the post-receive hook on the git_server
  # make sure this is executable
  file {'post-receive hook':
    ensure  => file,
    mode    => '0755',
    path    => "${repo_path}/modules.git/hooks/post-receive",
    source  => "puppet:///modules/${module_name}/post-receive",
  }
}
