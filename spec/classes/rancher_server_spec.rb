require 'spec_helper'

describe 'rancher::server' do
  context 'on supported operating system' do
    on_supported_os.each do |os, facts|
      context "#{os}" do
        let(:facts) do
          facts
        end

        context "with no params" do
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_class('rancher::params')
            is_expected.to contain_docker__image('rancher/server')
            is_expected.to contain_docker__run('rancher-server')
              .with_ensure('present')
              .with_image('rancher/server')
              .with_ports(['8080:8080'])
          end
        end

        context "with a custom port" do
          let(:params) { { port: 9090 } }
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_docker__run('rancher-server')
              .with_ports(['9090:8080'])
          end
        end

        context "with ensure absent" do
          let(:params) { { ensure: 'absent' } }
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_docker__run('rancher-server')
              .with_ensure('absent')
          end
        end

        context "with invalid ensure value" do
          let(:params) { { ensure: 'invalid' } }
          it do
            expect { is_expected.to contain_docker_run('rancher-server') }.to raise_error(Puppet::Error, /ensure should be present or absent/)
          end
        end

        context "with invalid port value" do
          let(:params) { { port: 'invalid' } }
          it do
            expect { is_expected.to contain_docker_run('rancher-server') }.to raise_error(Puppet::Error, /Expected first argument to be an Integer/)
          end
        end
      end
    end
  end
end
