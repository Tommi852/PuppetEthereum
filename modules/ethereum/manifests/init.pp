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
		owner => 'root',
		group => 'root',
		mode => '0755',
		notify => Exec['run_miner'],
	}
	
	exec { 'run_miner':
		command => '/tmp/puppetethereum/claymore/mine.sh',
	}
}
