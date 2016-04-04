require 'spec_helper_acceptance'

RANCHER_PORTS = [
  8080,
]

RANCHER_SERVER_CONTAINERS = [
  'rancher-server',
]

RANCHER_SERVER_IMAGES = [
  'rancher/server',
]

RANCHER_AGENT_CONTAINERS = [
  'rancher-agent',
]

RANCHER_AGENT_IMAGES = [
  'rancher/agent',
]

describe 'rancher' do
  context 'installation' do
    before(:all) do
      @pp = <<-EOS
        class { 'docker': } ->
        class { 'rancher::server': }
      EOS
      @result = apply_manifest_with_exit(@pp)
    end

    it_behaves_like 'an idempotent resource'
    it_behaves_like 'a system running docker'

    RANCHER_SERVER_CONTAINERS.each do |name|
      describe docker_container(name) do
        it { should be_running }
      end
    end

    RANCHER_SERVER_IMAGES.each do |image|
      describe docker_image(image) do
        it { should exist }
      end
    end

    RANCHER_PORTS.each do |value|
      describe port(value) do
        it { should be_listening }
      end
    end
  end
end

describe 'rancher agent', :node => 'agent' do
  before(:all) do
    server_address = if fact_on('server', 'osfamily') == 'RedHat'
                       fact_on('server', 'ipaddress_enp0s8')
                     else
                       fact_on('server', 'ipaddress_eth1')
                     end
    registration_url = get_rancher_registration_url(server_address)
    address = fact_on('agent', 'osfamily') == 'RedHat' ? fact_on('agent', 'ipaddress_enp0s8') : fact_on('agent', 'ipaddress_eth1')
    @pp = <<-EOS
      class { 'docker': } ->
      class { 'rancher':
        registration_url => '#{registration_url}',
        agent_address    => '#{address}',
      }
    EOS
    @result = apply_manifest_on_with_exit('agent', @pp)
  end

  it_behaves_like 'an idempotent resource'
  it_behaves_like 'a system running docker'

  RANCHER_AGENT_CONTAINERS.each do |name|
    describe docker_container(name) do
      it { should be_running }
    end
  end

  RANCHER_AGENT_IMAGES.each do |image|
    describe docker_image(image) do
      it { should exist }
    end
  end
end
