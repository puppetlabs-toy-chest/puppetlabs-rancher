require 'spec_helper'

describe 'rancher' do
  context 'on supported operating system' do
    on_supported_os.each do |os, facts|
      context "#{os}" do
        let(:facts) do
          facts
        end

        context "with minimal params" do
          let(:params) { { 'registration_url' => 'http://127.0.0.1:8080/v1/scripts/DB121CFBA836F9493653:1434085200000:2ZOwUMd6fIzz44efikGhBP1veo' } }
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_class('rancher::params')
            is_expected.to contain_docker__image('rancher/agent')
            is_expected.to contain_exec('bootstrap rancher agent')
              .with_unless('docker inspect rancher-agent')
              .with_command(/\/var\/run\/docker\.sock/)
              .with_command(/127\.0\.0\.1:8080/)
          end
        end

        context "with a custom agent address" do
          let(:params) do
            {
              registration_url: 'http://127.0.0.1:8080/v1/scripts/DB121CFBA836F9493653:1434085200000:2ZOwUMd6fIzz44efikGhBP1veo',
              agent_address: '10.0.0.1'
            }
          end
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_exec('bootstrap rancher agent')
              .with_command(/CATTLE_AGENT_IP=10\.0\.0\.1/)
          end
        end

        context "with a custom socket" do
          let(:params) do
            {
              registration_url: 'http://127.0.0.1:8080/v1/scripts/DB121CFBA836F9493653:1434085200000:2ZOwUMd6fIzz44efikGhBP1veo',
              docker_socket: '/tmp/bob.sock'
            }
          end
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_exec('bootstrap rancher agent')
              .with_command(/\/tmp\/bob\.sock/)
          end
        end

        context "with a custom image tag" do
          let(:params) do
            {
              registration_url: 'http://127.0.0.1:8080/v1/scripts/DB121CFBA836F9493653:1434085200000:2ZOwUMd6fIzz44efikGhBP1veo',
              image_tag: 'v1.0.1'
            }
          end
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_exec('bootstrap rancher agent')
              .with_command(/rancher\/agent:v1.0.1/)
          end
        end

        context "with an invalid socket value" do
          let(:params) do
            {
              registration_url: 'http://127.0.0.1:8080/v1/scripts/DB121CFBA836F9493653:1434085200000:2ZOwUMd6fIzz44efikGhBP1veo',
              docker_socket: 'not a path'
            }
          end
          it do
            expect { is_expected.to contain_docker_exec('bootstrap rancher agent') }.to raise_error(Puppet::Error, /not an absolute path/)
          end
        end

        context "with a missing registration url" do
          it do
            expect { is_expected.to contain_docker_exec('bootstrap rancher agent') }.to raise_error(Puppet::Error)
          end
        end

        context "with invalid agent address" do
          let(:params) do
            {
              registration_url: 'http://127.0.0.1:8080/v1/scripts/DB121CFBA836F9493653:1434085200000:2ZOwUMd6fIzz44efikGhBP1veo',
              agent_address: 'not an ip address'
            }
          end
          it do
            expect { is_expected.to contain_docker_exec('bootstrap rancher agent') }.to raise_error(Puppet::Error, /not a valid IP address/)
          end
        end
      end
    end
  end
end
