# frozen_string_literal: true

require 'spec_helper'

describe 'graylog::server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        'class { graylog::repository: }'
      end
      let(:params) do
        {
          'config' => {
            'password_secret'    => 'super secret secret',
            'root_password_sha2' => '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
          }
        }
      end

      # Test that the class doesn't error when given expected params
      it { is_expected.to compile.with_all_deps }

      # Ensure that the class has the graylog-server package and that it is
      # installed
      it {
        is_expected.to contain_package('graylog-server')
          .with_ensure('installed')
      }

      # Tests that the server config is managed and has expected content
      it {
        is_expected.to contain_file('/etc/graylog/server/server.conf')
          .with_ensure('file')
          .with_owner('graylog')
          .with_group('graylog')
          .with_mode('0640')
          .with_content(sensitive(%r{password_secret = super secret secret}))
          .with_content(sensitive(%r{root_password_sha2\s\=\s[a-f0-9]{64}}))
      }

      # Ensure that the java params are being managed and contain expected
      # content
      case os_facts[:os]['family']
      when 'Debian'
        it {
          is_expected.to contain_file('/etc/default/graylog-server')
            .with_ensure('file')
            .with_owner('graylog')
            .with_group('graylog')
            .with_mode('0640')
            .with_content(%r{-Xms1g})
            .with_content(%r{-Xmx1g})
        }
      when 'RedHat'
        it {
          is_expected.to contain_file('/etc/sysconfig/graylog-server')
            .with_ensure('file')
            .with_owner('graylog')
            .with_group('graylog')
            .with_mode('0640')
            .with_content(%r{-Xms1g})
            .with_content(%r{-Xmx1g})
        }
      end

      # Ensure that the service is being managed
      it {
        is_expected.to contain_service('graylog-server')
          .with_ensure('running')
          .with_enable(true)
          .with_hasstatus(true)
          .with_hasrestart(true)
      }
    end

    context "on #{os} without password_secret" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'config' => {
            'root_password_sha2' => '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
          }
        }
      end

      it {
        is_expected.to compile.and_raise_error(%r{Missing .*?password_secret})
      }
    end

    context "on #{os} without root_password_sha2" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'config' => {
            'password_secret' => 'super secret secret',
          }
        }
      end

      it {
        is_expected.to compile.and_raise_error(%r{Missing .*root_password_sha2})
      }
    end

    context "on #{os} with invalid root_password_sha2" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'config' => {
            'password_secret'    => 'super secret secret',
            'root_password_sha2' => 'this is an invalid hash',
          }
        }
      end

      it {
        is_expected.to compile.and_raise_error(%r{root_password_sha2 parameter does not look like a SHA256 checksum})
      }
    end
  end
end
