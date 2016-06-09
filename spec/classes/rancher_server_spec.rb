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
              .with_image_tag('latest')
            is_expected.to contain_docker__run('rancher-server')
              .with_ensure('present')
              .with_image('rancher/server')
              .with_ports(['8080:8080'])
              .with_env([])
              .with_depends([])
              .with_links([])
              .with_dns([])
              .with_dns_search([])
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

        context "with a custom image tag" do
          let(:params) { { image_tag: 'v1.0.1' } }
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_docker__image('rancher/server')
              .with_image_tag('v1.0.1')
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

        context "with an custom container name" do
          let(:params) { { container_name: 'rancher' } }
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_docker__run('rancher')
          end
        end

        context "with an external database" do
          let(:params) { { db_password: 'test' } }
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_docker__run('rancher-server')
              .with_links(['rancher-db'])
              .with_depends(['rancher-db'])
              .with_env([
                'CATTLE_DB_CATTLE_MYSQL_HOST=rancher-db',
                'CATTLE_DB_CATTLE_MYSQL_PORT=3306',
                'CATTLE_DB_CATTLE_MYSQL_NAME=rancher',
                'CATTLE_DB_CATTLE_USERNAME=rancher',
                'CATTLE_DB_CATTLE_PASSWORD=test',
              ])
          end
        end

        context "with a custom DNS server" do
          let(:params) { { dns: ['8.8.8.8'] } }
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_docker__run('rancher-server')
              .with_dns(['8.8.8.8'])
          end
        end

        context "with a custom DNS search domain" do
          let(:params) { { dns_search: ['domain.local'] } }
          it do
            is_expected.to compile.with_all_deps
            is_expected.to contain_docker__run('rancher-server')
              .with_dns_search(['domain.local'])
          end
        end

      end
    end
  end
end
