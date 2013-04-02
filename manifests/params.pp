class jiminy::params
{
  if $::is_pe == 'true' {
    $plugins_dir = '/opt/puppet/libexec/mcollective/mcollective'
  } else {
    $plugins_dir = '/usr/libexec/mcollective/mcollective'
  }

  $dyn_module_path = $::is_pe ? {
    'true'  => '$confdir/environments/$environment:/opt/puppet/share/puppet/modules',
    default => '$confdir/environments/$environment',
  }

  $mc_agent_name       = "${module_name}.rb"
  $mc_agent_ddl_name   = "${module_name}.ddl"
  $mc_app_name         = "${module_name}.rb"
  $git_server          = 'classroom.puppetlabs.vm'
  $repo_path           = '/var/repos'
  $mc_service_name     = 'pe-mcollective'
  $mc_agent_path       = "${plugins_dir}/agent"
  $mc_application_path = "${plugins_dir}/application"
  $vcs_module_path     =  "${::settings::confdir}/${module_name}"
  $is_master           = true #str2bool($::fact_is_puppetmaster),
  $setup_git           = true
  $setup_r10k          = $setup_git
  $remote              = "ssh://${git_server}${repo_path}/modules.git"
}
