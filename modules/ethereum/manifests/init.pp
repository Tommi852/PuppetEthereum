class ethereum {
	exec{'retrieve_driver':
		command => "wget --referer=http://support.amd.com https://www2.ati.com/drivers/linux/ubuntu/amdgpu-pro-17.10-414273.tar.xz -O ~/home/ajuri.tar.xz",
		creates => "/home/ajuri.tar.xz",
	}
	
}
