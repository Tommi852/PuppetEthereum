# Ethereum miner puppet moduuli

## Kuinka se toimii?

### Pohjustus

Asensin master palvelimelleni vcsrepon komennolla:
```
sudo puppet module install puppetlabs-vcsrepo --version 2.2.0
´´´

Vcsrepo on valmis moduuli puppettiin, joka osaa hakea ja ylläpitää git projekteja. Käytän sitä miner tiedostojen päivittämiseen.

Ketjutin skriptin vaiheet käyttämällä jokaisessa kohdassa requirea.

### Käydään moduulin scripti vaiheittain

```
package { 'git':
		ensure => 'installed',
	}


	vcsrepo { "/tmp/puppetethereum":
		ensure   => latest,
		provider => git,
		require  => [ Package["git"] ],
		source   => "git://github.com/Tommi852/PuppetEthereum.git",
	}	
```
Tässä kohti skriptiä varmistetaan, että git on asennettuna kohde koneella, jonka jälkeen vcsrepo hakee koneelle uusimman version mineriin käytettävistä tiedostoista.


```
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

```
Miner_skripti varmistaa, että mine.sh tiedosto on oikeassa paikassa, jonka jälkeen run_miner_settings pyöräyttää kyseisen skriptin. 

mine.sh näyttää sisällöltään tältä:
```
#!/bin/sh
export GPU_FORCE_64BIT_PTR=0

export GPU_MAX_HEAP_SIZE=100

export GPU_USE_SYNC_OBJECTS=1

export GPU_MAX_ALLOC_PERCENT=50

export GPU_SINGLE_ALLOC_PERCENT=50
```
mine.sh skriptin ainut tarkoitus on asettaa rajat näytönohjaimen tehojen käytölle. Tässä tapauksessa vain 50% näytön ohjaimen tehoista käytetään.


```
 exec { 'driver_install':
                command => '/tmp/puppetethereum/nvidiadriver.sh',
                provider => 'shell',
		user => root,
                cwd => '/tmp/puppetethereum/',
		returns => [0,126],
                require => Exec['run_miner_settings'],
        }
```

Tässä vaiheessa pyöräytetään skripti, joka lataa ja asentaa kaikki minerin tarvitsemat ohjelmat sekä näytönohjaimen ajurit.
Tämä skripti olisi tarkoitus siirtää puppetin hoidettavaksi, mutta ajan puutteen vuoksi jouduin suorittamaan sen execillä.
Resurssiin oli myös lisättävä returns => [0,126], sillä ensimmäisellä pyöräytys kerralla skripti palauttaa lopetus koodi nollan, mutta myöhemmillä kerroilla se antaa puppetille tuntemattoman exit coden 126, joka piti erikseen hyväksyä.

```
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
```
Tässä vaiheessa luodaan kohde koneelle init skripti, jolla mineriä voidaan ohjata servicenä ja annetaan minerille, sekä skriptille oikeat oikeudet niiden pyöritykseen.
Miner oli pakko muuttaa serviceksi, sillä se pyörii normaalisti bash scriptin kautta ja puppet ei osannut ottaa exit koodia bashista, joka ei koskaan lopeta pyörimistä.
Tällä myös varmistetaan, ettei miner pyöri useampaan otteeseen, vaan puppet osaa varmistaa, että palvelu on päällä.

```
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
```
Viimeiseksi puppet vielä lataa daemonit uudestaan, jotta lisäämäni minerin service init skripti tulee näkyviin servicenä.
Tämän jälkeen puppet varmistaa, että skripti on päällä.

Moduulissa on vielä paljon paranneltavaa, kuten execien muuntaminen parempiin käytäntöihin, mutta nyt se toimii haluamallani tavalla.


