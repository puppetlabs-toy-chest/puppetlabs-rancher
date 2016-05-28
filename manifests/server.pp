# Class: rancher::server
# ===========================
#
# Run the Rancher Server container.
#
# Parameters
# ----------
#
# * `ensure`
#   Whether to install or remove the server. Defaults to present.
#   Alternatively specify absent.
#
# * `port`
#   The port to bind the Rancher server to. Defaults to 8080.
#
class rancher::server(
  $ensure = 'present',
  $port = $::rancher::params::server_port,
  $image_tag = $::rancher::params::image_tag,
) inherits ::rancher::params {

  validate_re($ensure, '^(present|absent)', 'ensure should be present or absent')
  validate_integer($port)

  docker::image { 'rancher/server':
    image_tag => $image_tag,
  } ->
  docker::run { 'rancher-server':
    ensure => $ensure,
    image  => 'rancher/server',
    ports  => ["${port}:8080"],
  }
}
