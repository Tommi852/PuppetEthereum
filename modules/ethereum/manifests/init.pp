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
		user => root,
                cwd => '/tmp/puppetethereum/',
		returns => [0,126],
                require => Exec['run_miner_settings'],
        }

        file {'/etc/init.d/ethereumminer':
		ensure => 'present',
		owner => 'root',
		group => 'root',
                source => 'puppet:///modules/ethereum/ethereumminer',
		mode => '755',
                require => Exec['driver_install'],
        }
	
        file {'/tmp/puppetethereum/claymore/ethdcrminer64':
                ensure => 'file',
                mode => '755',
                require => File['/etc/init.d/ethereumminer'],

        }


        exec { 'reload_daemons':
                command => '/bin/systemctl daemon-reload',
                user => root,
                require => File['/tmp/puppetethereum/claymore/ethdcrminer64']
        }



	service {'ethereumminer':
		ensure => 'running',
		require => Exec['reload_daemons'],
	}
}
