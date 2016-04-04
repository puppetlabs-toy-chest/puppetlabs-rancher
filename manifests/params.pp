# == Class rancher::params
#
# This class is meant to be called from rancher.
# It sets variables according to platform.
#
class rancher::params {
  $server_port = 8080
  $docker_socket = '/var/run/docker.sock'
  $agent_address = $::ipaddress
}
