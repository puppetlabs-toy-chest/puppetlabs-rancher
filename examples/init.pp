# Installing a Rancher server, using the (separate) garethr/docker
# module to ensure docker is present
class { '::docker': } ->
class { '::rancher:server': }

# Installing the corresponding Rancher agent. Also requires docker
# to be present on the host and also requires a valid registration
# token
class { '::rancher':
  registration_url => 'http://127.0.0.1:8080/v1/scripts/DB121CFBA836F9493653:1434085200000:2ZOwUMd6fIzz44efikGhBP1veo',
}
