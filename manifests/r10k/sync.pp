class jiminy::r10k::sync (

) inherits jiminy::params {
  Exec {
    path => '/usr/bin'
  }

  # This is our intial sync to create production folder
  exec { 'r10k sync':
    command     => 'r10k synchronize',
    refreshonly => true,
  }

  # Add the dynamic environments to the array from params
  # This is a little bit odd syntax but I was limited by the DSL

  if is_array($jiminy::params::dyn_module_path) {
    $jiminy::params::dyn_module_path +=  '$confdir/environments/$environment'

    $r10k_module_path = join(reverse($jiminy::params::dyn_module_path),':')
  }
  else {
    fail("${module_name}: please specify an array of alternative modulepaths")
  }

  # Configure out dynamic environment module path
  augeas{'puppet.conf modulepath' :
    context       => '/files//puppet.conf/main',
    changes       => "set modulepath ${r10k_module_path}",
    require       => Class['jiminy::r10k'],
  }
}
