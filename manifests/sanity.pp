class jiminy::sanity {
  # Sanity checks
  validate_bool($setup_git)
  validate_bool($setup_r10k)
  validate_string($git_server)
  validate_absolute_path($repo_path)
  validate_absolute_path($vcs_module_path)
  $my_module_name_path = get_module_path($module_name)
  $my_module_path = inline_template('<%= File.dirname(my_module_name_path) %>')
  # Don't allow for this module to run from the dynamic envrionments
  if ! member($dyn_module_path,$my_module_path) {
    fail("${module_name}: module must be in one of the alternative static module paths")
  }
}
