class jiminy::params
{

  # Puppet Enterprise specific settings
  if $::is_pe == 'true' {
    # Mcollective configuration dynamic
    $mc_service_name     = 'pe-mcollective'
    $dyn_module_path     = [ '/opt/puppet/share/puppet/modules' ]
    $plugins_dir         = '/opt/puppet/libexec/mcollective/mcollective'
  } else {
    # Getting ready for FOSS support in this module

    # Mcollective configuration dynamic
    $mc_service_name     = 'pe-mcollective'
    $plugins_dir         = '/usr/libexec/mcollective/mcollective'
    $dyn_module_path     = [ '/etc/puppet/modules' ]
  }

  # r10k configuration
  $r10k_config_file     = '/etc/r10k.yaml'
  $r10k_cache_dir       = '/var/cache/r10k'
  $r10k_basedir         = "${::settings::confdir}/environments"
  $r10k_purgedirs       = $jiminy::params::r10k_basedir

  # Mcollective configuration static
  $mc_agent_name       = "${module_name}.rb"
  $mc_agent_ddl_name   = "${module_name}.ddl"
  $mc_app_name         = "${module_name}.rb"
  $mc_agent_path       = "${plugins_dir}/agent"
  $mc_application_path = "${plugins_dir}/application"

  # Git configuration
  $git_server          = $::settings::ca_server
  $repo_path           = '/var/repos'
  $remote              = "ssh://${git_server}${repo_path}/modules.git"
  $vcs_module_path     =  "${::settings::confdir}/${module_name}"

  # Automatically determine the master based on this fact value
  $is_master_fact      = '::fact_is_puppetca' #fact_is_puppetmaster 2.7.0 testing
  $is_master           = str2bool(getvar($is_master_fact))

  # Configuration Parameters used at run time
  $setup_git           = true
  $setup_r10k          = $jiminy::params::setup_git
}
