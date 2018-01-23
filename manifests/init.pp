# Class: rancher
# ===========================
#
# Install a Rancher agent based on the passed parameters.
# Requires Docker to be already running on the host.
#
# Parameters
# ----------
#
# * `registration_url`
#   Required. Specify the Rancher server registration URL, including the registration token.
#   This should be available from within the Rancher dashboard or from the API
#
# * `agent_address`
#   Override the address for the agent. Defaults to the value of the fact ipaddress.
#   This is passed to CATTLE_AGENT_IP
#
# * `docker_socket`
#   The file path to the docker socket on the host. This is mounted into the bootstrap container
#   in order to launch the agent. Defaults to /var/run/docker.sock
#
class rancher (
  $registration_url,
  $agent_address = $::rancher::params::agent_address,
  $docker_socket = $::rancher::params::docker_socket,
  $image_tag = $::rancher::params::image_tag,
) inherits ::rancher::params {

  validate_absolute_path($docker_socket)
  validate_string($registration_url)
  validate_string($image_tag)
  validate_ip_address($agent_address)

  docker::image { 'rancher/agent': } ->
  exec { 'bootstrap rancher agent':
    path      => ['/usr/local/bin', '/usr/bin', '/bin'],
    logoutput => true,
    command   => "docker run --rm --privileged -v ${docker_socket}:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher -e 'CATTLE_AGENT_IP=${agent_address}' rancher/agent:${image_tag} ${registration_url}",
    unless    => 'docker inspect rancher-agent',
  }
}
