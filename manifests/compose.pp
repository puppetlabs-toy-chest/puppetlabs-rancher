# == Class: rancher::compose
#
# Class to install Rancher Compose using the recommended curl command.
#
# === Parameters
#
# [*ensure*]
#   Whether to install or remove Rancher Compose
#   Valid values are absent present
#   Defaults to present
#
# [*version*]
#   The version of Rancher Compose to install.
#   Defaults to the value set in $rancher::params::compose_version
#
# [*install_path*]
#   The path where to install Rancher Compose.
#   Defaults to the value set in $rancher::params::compose_install_path
#
# [*proxy*]
#   Proxy to use for downloading Rancher Compose.
#
class rancher::compose(
  Optional[Pattern[/^present$|^absent$/]] $ensure          = 'present',
  Optional[String] $version                                = $rancher::params::compose_version,
  Optional[String] $install_path                           = $rancher::params::compose_install_path,
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

    exec { "Install Rancher Compose ${version}":
      path    => '/usr/bin/',
      cwd     => '/tmp',
      command => "curl -s -L ${proxy_opt} https://releases.rancher.com/compose/v${version}/rancher-compose-linux-amd64-v${version}.tar.gz | tar -zxv -O --strip-components 2 './rancher-compose-v${version}/rancher-compose' > ${install_path}/rancher-compose-${version}",
      creates => "${install_path}/rancher-compose-${version}",
      require => Package['curl'],
    }

    file { "${install_path}/rancher-compose-${version}":
      owner   => 'root',
      mode    => '0755',
      require => Exec["Install Rancher Compose ${version}"],
    }

    file { "${install_path}/rancher-compose":
      ensure  => 'link',
      target  => "${install_path}/rancher-compose-${version}",
      require => File["${install_path}/rancher-compose-${version}"],
    }
  } else {
    file { [
      "${install_path}/rancher-compose-${version}",
      "${install_path}/rancher-compose",
    ]:
      ensure => absent,
    }
  }
}
