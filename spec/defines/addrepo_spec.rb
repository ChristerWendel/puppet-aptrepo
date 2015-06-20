require 'spec_helper'

describe 'aptrepo::addrepo', :type => :define do
  let(:title) { 'aptrepo::addrepo' }

  context 'minimal parameters' do
    let(:title) { 'debian' }
    let(:params) do
      { :location => 'http://ftp.debian.org/debian',
      }
    end

    it { should contain_file('debian')
        .with_ensure('present')
        .with_path('/etc/apt/sources.list.d/debian.list')
        .with_content(/deb http:\/\/ftp.debian.org\/debian stable main/)
        .with_owner('root')
        .with_group('root')
        .with_mode('0644')
        .that_notifies('Exec[apt-get http://ftp.debian.org/debian]')
    }

    it { should_not contain_exec('add_key') }

    it { should contain_exec('apt-get http://ftp.debian.org/debian')
        .with_command('/usr/bin/apt-get update')
        .with_refreshonly(true)
    }
  end

  context 'key => http://ftp.debian.org/debian-public.key' do
    let(:title) { 'debian' }
    let(:params) do
      { :location => 'http://ftp.debian.org/debian',
        :key      => 'http://ftp.debian.org/debian-public.key',
      }
    end

    it { should contain_file('debian')
        .that_notifies('Exec[add_key http://ftp.debian.org/debian]')
    }

    it { should contain_exec('add_key http://ftp.debian.org/debian')
        .with_command('/usr/bin/wget -q http://ftp.debian.org/debian-public.key -O- | /usr/bin/apt-key add -')
        .with_refreshonly(true)
        .that_subscribes_to('File[debian]')
        .that_notifies('Exec[apt-get http://ftp.debian.org/debian]')
    }
  end

  context 'release => stable' do
    let(:title) { 'debian' }
    let(:params) do
      { :location => 'http://ftp.debian.org/debian',
        :release  => 'unstable'
      }
    end

    it { should contain_file('debian')
        .with_content(/deb http:\/\/ftp.debian.org\/debian unstable main/)
    }
  end
end
