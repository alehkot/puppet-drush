class drush::git::drush (
  $git_branch = '',
  $git_tag    = '',
  $git_repo   = 'https://github.com/drush-ops/drush.git',
  $update     = false
  ) inherits drush::params {

  if !defined(Package[$drush::params::php_cli_package]) {
    package { $drush::params::php_cli_package: ensure => present }
  }

  drush::git { $git_repo :
    path       => '/usr/share',
    git_branch => $git_branch,
    git_tag    => $git_tag,
    update     => $update,
  }

  file {'symlink drush':
    ensure  => link,
    path    => '/usr/bin/drush',
    target  => '/usr/share/drush/drush',
    require => Drush::Git[$git_repo],
    notify  => Exec['first drush run'],
  }

  # Needed to download a Pear library
  exec {'first drush run':
    command     => '/usr/bin/drush cache-clear drush',
    refreshonly => true,
    require     => [
      File['symlink drush'],
      Package['php5-cli'],
    ],
  }

}
