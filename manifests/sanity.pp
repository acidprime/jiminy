class jiminy::sanity {

  # Sanity checks from stdlib functions
  validate_bool($setup_git)
  validate_bool($setup_r10k)
  validate_string($git_server)
  validate_absolute_path($repo_path)
  validate_absolute_path($vcs_module_path)

  # Check to see where we are running from and fail if its in jiminies per vue
  $my_module_name_path = get_module_path($module_name)
  $my_module_path = inline_template('<%= File.dirname(my_module_name_path) %>')

  # Don't allow for this module to run from the dynamic envrionments
  if ! member($dyn_module_path,$my_module_path) {
    notify{"${module_name}: module must be in one of the alternative static module paths":}
  }
}
