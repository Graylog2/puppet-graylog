# frozen_string_literal: true

require 'spec_helper'

describe 'graylog::repository' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      case os_facts[:os]['family']
      when 'Debian'
        it {
          is_expected.to contain_class('graylog::repository::apt')
        }
        it {
          is_expected.to contain_package('apt-transport-https')
        }
        it {
          is_expected.to contain_file('/etc/apt/trusted.gpg.d/graylog-keyring.gpg')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0444')
            .with_source('puppet:///modules/graylog/graylog-keyring.gpg')
            .that_notifies('Exec[apt_update]')
        }
        it {
          is_expected.to contain_apt__source('graylog')
            .with_ensure('present')
            .with_comment('The official Graylog package repository')
            .with_location('https://downloads.graylog.org/repo/debian/')
            .with_release('stable')
            .with_repos('6.1')
            .with_include({ 'deb' => true, 'src' => false })
            .that_requires(
              [
                'File[/etc/apt/trusted.gpg.d/graylog-keyring.gpg]',
                'Package[apt-transport-https]',
              ],
            )
            .that_notifies('Exec[apt_update]')
        }
        it {
          is_expected.to contain_file('/etc/apt/apt.conf.d/01_graylog_proxy')
            .with_ensure('file')
        }
        it {
          is_expected.to contain_file_line('Remove graylog config from apt proxy file')
            .with_ensure('absent')
            .with_path('/etc/apt/apt.conf.d/01_graylog_proxy')
            .with_match('graylog')
            .with_match_for_absence(true)
            .with_multiple(true)
        }
      when 'RedHat'
        it {
          is_expected.to contain_class('graylog::repository::yum')
        }
        it {
          is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-graylog')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0444')
            .with_source('puppet:///modules/graylog/RPM-GPG-KEY-graylog')
        }
        it {
          is_expected.to contain_yumrepo('graylog')
            .with_descr('The official Graylog package repository')
            .with_baseurl('https://downloads.graylog.org/repo/el/stable/6.1/$basearch/')
            .with_enabled(true)
            .with_gpgcheck(true)
            .that_requires(['File[/etc/pki/rpm-gpg/RPM-GPG-KEY-graylog]'])
        }
      end
    end
  end
end
