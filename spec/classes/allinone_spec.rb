# frozen_string_literal: true

require 'spec_helper'

describe 'graylog::allinone' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'opensearch' => {
            'version'  => '2.15.0',
            'settings' => {
              'setting_a' => 'value_b'
            }
          },
          'graylog' => {
            'major_version' => '6.1',
            'config'        => {
              'password_secret'    => 'super secret secret',
              'root_password_sha2' => '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
            }
          }
        }
      end

      # Because of an issue with the opensearch module,the allinone class will
      # always fail an RedHat family operating systems using modern facts.
      case os_facts[:os]['family']
      when 'Debian'
        it { is_expected.to compile.with_all_deps }
      when 'RedHat'
        it { is_expected.to compile.and_raise_error(%r{Could not find class ::yum.*}) }
      end
    end
  end
end
