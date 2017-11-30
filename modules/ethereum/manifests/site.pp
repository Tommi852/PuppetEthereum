class ethereum {
	exec{'retrieve_driver':
		command => "/usr/bin/wget --referer=http://support.amd.com https://www2.ati.com/drivers/linux/ubuntu/amdgpu-pro-17.10-414273.tar.xz -O ~/home/ajuri",
		creates => "/home/ajuri",
	}
	
	file{'/home/ajuri':
		mode => 0755,
		require => Exec["retrieve_driver"],
	}

	
}
