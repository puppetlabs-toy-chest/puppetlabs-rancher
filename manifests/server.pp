# Class: rancher::server
# ===========================
#
# Run the Rancher Server container.
#
# If all db_* parameters are provided, an external database container will be
# created for the Rancher server.
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
# * `image_tag`
#   Docker image tag to use for the Rancher server image. Defauts to latest
#
# * `container_name`
#   Name of the new Rancher container. Defaults to rancher-server
#
# * `db_port`
#   Database port for using an external database container. Defaults to 3306
#
# * `db_name`
#   Name of the database. Defaults to rancher
#
# * `db_user`
#   Database user. Defaults to rancher
#
# * `db_password`
#   Password for the database user. Defaults to undef
#
# * `db_container`
#   Name of the database container. Defaults to rancher-db
#
# * `dns`
#   DNS server addresses to pass to the Rancher container. Defaults to the
#   standard Docker-generated array.
#
# * `dns_search`
#   DNS search domains to pass to the Rancher container. Defaults to the
#   standard Docker-generated array.
#

class rancher::server(
  $ensure = 'present',
  $port = $::rancher::params::server_port,
  $image_tag = $::rancher::params::image_tag,
  $container_name = $::rancher::params::container_name,
  $db_port = $::rancher::params::db_port,
  $db_name = $::rancher::params::db_name,
  $db_user = $::rancher::params::db_user,
  $db_password = $::rancher::params::db_password,
  $db_container = $::rancher::params::db_container,
  $dns = $::rancher::params::dns,
  $dns_search = $::rancher::params::dns_search,
) inherits ::rancher::params {

  validate_re($ensure, '^(present|absent)', 'ensure should be present or absent')
  validate_integer($port)
  validate_string($container_name)
  validate_array($dns)
  validate_array($dns_search)

  if  ($db_port != undef) and
      ($db_name != undef) and
      ($db_user != undef) and
      ($db_password != undef) and
      ($db_container != undef) {
    validate_string($db_container)
    validate_string($db_name)
    validate_string($db_user)
    validate_string($db_password)
    validate_integer($db_port)
    $env = [
      "CATTLE_DB_CATTLE_MYSQL_HOST=${db_container}",
      "CATTLE_DB_CATTLE_MYSQL_PORT=${db_port}",
      "CATTLE_DB_CATTLE_MYSQL_NAME=${db_name}",
      "CATTLE_DB_CATTLE_USERNAME=${db_user}",
      "CATTLE_DB_CATTLE_PASSWORD=${db_password}",
    ]
    $links = [ $db_container ]
    $depends = [ $db_container ]
    docker::image {'mariadb':
      image_tag => 'latest',
    } ->
    docker::run { $db_container:
      image   => 'mariadb',
      env     => [
        "MYSQL_ROOT_PASSWORD=${db_password}",
        "MYSQL_USER=${db_user}",
        "MYSQL_PASSWORD=${db_password}",
        "MYSQL_DATABASE=${db_name}",
      ],
      volumes => [ "/var/lib/${db_container}:/var/lib/mysql" ],
      notify  => Docker::Run[$container_name],
    }
  } else {
    $env = []
    $links = []
    $depends = []
  }

  docker::image { 'rancher/server':
    image_tag => $image_tag,
  } ->
  docker::run { $container_name:
    ensure     => $ensure,
    image      => "rancher/server:${image_tag}",
    ports      => ["${port}:8080"],
    env        => $env,
    links      => $links,
    depends    => $depends,
    dns        => $dns,
    dns_search => $dns_search,
  }
}
