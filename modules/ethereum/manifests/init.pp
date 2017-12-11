class ethereum {

	package { 'git':
		ensure => 'installed',
	}


	vcsrepo { "/tmp/puppetethereum":
		ensure   => latest,
		provider => git,
		require  => [ Package["git"] ],
		source   => "git://github.com/Tommi852/PuppetEthereum.git",
	}	
	
	file {'miner_skripti':
		ensure => 'file',
		path => '/tmp/puppetethereum/claymore/mine.sh',
		mode => '0755',
		require => Vcsrepo['/tmp/puppetethereum'],
	}
	
	exec { 'run_miner_settings':
		command => '/tmp/puppetethereum/claymore/mine.sh',
		provider => 'shell',
		cwd => '/tmp/puppetethereum/claymore/',
		require => File['miner_skripti'],
	}
	
        exec { 'driver_install':
                command => '/tmp/puppetethereum/nvidiadriver.sh',
                provider => 'shell',
                cwd => '/tmp/puppetethereum/',
                require => Exec['run_miner_settings'],
        }

        file {'/etc/init.d/ethereumminer':
                ensure => 'latest',
		source => 'puppet:///modules/ethereum/ethereumminer',
                require => Exec['driver_install'],
        }

	service {'ethereumminer':
		name => 'ethereumminer',
		ensure => 'running',
		require => File['/etc/init.d/ethereumminer'],
	}
}
