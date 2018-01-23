# == Class rancher::params
#
# This class is meant to be called from rancher.
# It sets variables according to platform.
#
class rancher::params {
  $server_port = 8080
  $docker_socket = '/var/run/docker.sock'
  $agent_address = $::ipaddress
  $image_tag = 'latest'
  $cli_version = '0.6.7'
  $cli_install_path = '/usr/local/bin'
  $compose_version = '0.12.5'
  $compose_install_path = '/usr/local/bin'
  $container_name = 'rancher-server'
  $db_port = 3306
  $db_name = 'rancher'
  $db_user = 'rancher'
  $db_password = undef
  $db_container = 'rancher-db'
  $dns = []
  $dns_search = []
}
