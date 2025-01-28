# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'init class' do
  context 'applying graylog server class works' do
    let(:pp) do
      <<-CODE
        class { 'graylog::repository':
          version => '6.1'
        }
        -> class { 'graylog::server':
          config          => {
            'password_secret'    => 'super secret secret',
            'root_password_sha2' => '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
          }
        }
      CODE
    end

    it 'behaves idempotently' do
      idempotent_apply(pp)
    end

    if os[:family] == 'redhat'

      # Ensure the yum repo exists and is enabled
      describe yumrepo('graylog') do
        it { is_expected.to exist }
        it { is_expected.to be_enabled }
      end

      # Ensure the package is found
      describe command('dnf -q search graylog-server') do
        its(:stdout) { is_expected.to match(%r{Name Exactly Matched: graylog\-server}) }
        its(:exit_status) { is_expected.to eq 0 }
      end

      describe file('/etc/sysconfig/graylog-server') do
        it { is_expected.to be_file }
        its(:content) { is_expected.to match(%r{\-Xms1g}) }
        its(:content) { is_expected.to match(%r{\-Xmx1g}) }
        its(:content) { is_expected.to match(%r{GRAYLOG_SERVER_ARGS=""}) }
      end
    elsif ['debian', 'ubuntu'].include?(os[:family])

      # Ensure the repo exists on the filesystem
      describe file('/etc/apt/sources.list.d/graylog.list') do
        it { is_expected.to be_file }
        its(:content) { is_expected.to match(%r{https://downloads.graylog.org/repo/debian}) }
      end

      # Ensure the package is found
      describe command('apt-cache search graylog-server') do
        its(:stdout) { is_expected.to match(%r{graylog-server - Graylog server}) }
        its(:exit_status) { is_expected.to eq 0 }
      end

      # Ensure the environment vars file is present on disk and looks correct
      describe file('/etc/default/graylog-server') do
        it { is_expected.to be_file }
        its(:content) { is_expected.to match(%r{\-Xms1g}) }
        its(:content) { is_expected.to match(%r{\-Xmx1g}) }
        its(:content) { is_expected.to match(%r{GRAYLOG_SERVER_ARGS=""}) }
      end
    end

    describe package('graylog-server') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/graylog/server/server.conf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match(%r{root_password_sha2\s\=\s[a-f0-9]{64}}) }
    end
  end
end
