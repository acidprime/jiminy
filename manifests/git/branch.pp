class jiminy::git::branch(
  $repo_path,
  $vcs_module_path,
) {
    exec { 'git add .gitignore':
      command     => 'git add .gitignore',
      cwd         => $vcs_module_path,
      refreshonly => true,
      notify      => Exec['intial commit'],
    }
    exec { 'intial commit':
      command     => 'git commit .gitignore -m "intial commit"',
      cwd         => $vcs_module_path,
      refreshonly => true,
      notify      => Exec['push origin master'],
    }
    exec { 'push origin master':
      command     => 'git push origin master',
      cwd         => $vcs_module_path,
      refreshonly => true,
      before      => Exec['create production branch'],
    }
    exec { 'create production branch':
      command => 'git branch production',
      cwd     => "${repo_path}/modules.git",
      creates => "${repo_path}/modules.git/refs/heads/production",
      notify  => Exec['change HEAD to production'],
    }
    exec { 'change HEAD to production':
      command     => 'git symbolic-ref HEAD refs/heads/production',
      cwd         => "${repo_path}/modules.git",
      refreshonly => true,
    }
}