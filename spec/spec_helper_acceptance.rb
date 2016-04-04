require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

require 'rest-client'

# automatically load any shared examples or contexts
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.formatter = :documentation
  c.before :suite do
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'rancher')
      if fact_on(host, 'osfamily') == 'RedHat'
        on(host, 'sudo yum update -y -q')
        on(host, 'sudo systemctl stop firewalld')
      end
      ['puppetlabs-stdlib', 'garethr-docker'].each do |name|
        on host, puppet('module', 'install', name), { :acceptable_exit_codes => [0,1] }
      end
    end
  end
end

def apply_manifest_on_with_exit(host, manifest)
  # acceptable_exit_codes and expect_changes are passed because we want detailed-exit-codes but want to
  # make our own assertions about the responses. Explicit is better than implicit.
  apply_manifest_on(host, manifest, {:acceptable_exit_codes => (0...256), :expect_changes => true, :debug => true})
end

def apply_manifest_with_exit(manifest)
  # acceptable_exit_codes and expect_changes are passed because we want detailed-exit-codes but want to
  # make our own assertions about the responses. Explicit is better than implicit.
  apply_manifest(manifest, {:acceptable_exit_codes => (0...256), :expect_changes => true, :debug => true})
end


class RegistrationTokenNotReadyError < StandardError
end

class RegistrationDataError < StandardError
end

class RegistrationURLError < StandardError
end

def get_rancher_registration_data(server_address, project_id)
  token_response = RestClient.post "http://#{server_address}:8080/v1/registrationtoken", nil, :x_api_project_id => project_id
  token_data = JSON.parse(token_response, symbolize_names: true)
  token_id = token_data[:id]
  tries ||= 10
  begin
    registration_response = RestClient.get "http://#{server_address}:8080/v1/registrationtoken/#{token_id}"
    registration_data = JSON.parse(registration_response, symbolize_names: true)
    if registration_data[:registrationUrl].nil?
      raise RegistrationTokenNotReadyError
    else
      registration_data
    end
  rescue RegistrationTokenNotReadyError
    sleep(10)
    unless (tries -= 1).zero?
      retry
    else
      raise RegistrationDataError
    end
  end
end

def get_rancher_registration_url(server_address)
  tries ||= 10
  project_response = RestClient.get "http://#{server_address}:8080/v1/projects"
  project_data = JSON.parse(project_response, symbolize_names: true)
  project_id = project_data[:data].first[:id]
  registration_data = get_rancher_registration_data(server_address, project_id)
  registration_data[:registrationUrl]
rescue Errno::ECONNREFUSED
  sleep(10)
  unless (tries -= 1).zero?
    retry
  else
    raise RegistrationURLError
  end
end
