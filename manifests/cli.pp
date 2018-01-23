# == Class: rancher::cli
#
# Class to install Rancher Cli using the recommended curl command.
#
# === Parameters
#
# [*ensure*]
#   Whether to install or remove Rancher Cli
#   Valid values are absent present
#   Defaults to present
#
# [*version*]
#   The version of Rancher Cli to install.
#   Defaults to the value set in $rancher::params::cli_version
#
# [*install_path*]
#   The path where to install Rancher Cli.
#   Defaults to the value set in $rancher::params::cli_install_path
#
# [*proxy*]
#   Proxy to use for downloading Rancher Cli.
#
class rancher::cli(
  Optional[Pattern[/^present$|^absent$/]] $ensure          = 'present',
  Optional[String] $version                                = $rancher::params::cli_version,
  Optional[String] $install_path                           = $rancher::params::cli_install_path,
  Optional[String] $proxy                                  = undef
) inherits rancher::params {

  if $proxy != undef {
      validate_re($proxy, '^((http[s]?)?:\/\/)?([^:^@]+:[^:^@]+@|)([\da-z\.-]+)\.([\da-z\.]{2,6})(:[\d])?([\/\w \.-]*)*\/?$')
  }

  if $ensure == 'present' {
    ensure_packages(['curl'])

    if $proxy != undef {
        $proxy_opt = "--proxy ${proxy}"
    } else {
        $proxy_opt = ''
    }

    exec { "Install Rancher Cli ${version}":
      path    => '/usr/bin/',
      cwd     => '/tmp',
      command => "curl -s -L ${proxy_opt} https://releases.rancher.com/cli/v${version}/rancher-linux-amd64-v${version}.tar.gz | tar -zxv -O --strip-components 2 './rancher-v${version}/rancher' > ${install_path}/rancher-${version}",
      creates => "${install_path}/rancher-${version}",
      require => Package['curl'],
    }

    file { "${install_path}/rancher-${version}":
      owner   => 'root',
      mode    => '0755',
      require => Exec["Install Rancher Cli ${version}"],
    }

    file { "${install_path}/rancher":
      ensure  => 'link',
      target  => "${install_path}/rancher-${version}",
      require => File["${install_path}/rancher-${version}"],
    }
  } else {
    file { [
      "${install_path}/rancher-${version}",
      "${install_path}/rancher",
    ]:
      ensure => absent,
    }
  }
}
