class aegir {

  include drush

  exec {'get key':
    command => "/usr/bin/wget -nc -P files http://debian.aegirproject.org/key.asc",
    unless => "/bin/ls files| /bin/grep 'key.asc'",
  }

  exec {'add key':
    command => "/usr/bin/apt-key add files/key.asc",
    require => Exec["get key"],
  }

  exec { 'apt_update':
    command => '/usr/bin/apt-get update && /usr/bin/apt-get autoclean',
    require => File["aegir-stable.list"],
  }

  file { "aegir-stable.list": 
    path    => "/etc/apt/sources.list.d/aegir-stable.list",
    source  => "/tmp/vagrant-puppet/modules-0/aegir/files/aegir-stable.list", 
    require => Exec ['add key'],
  }

 package { "aegir":
   ensure  => installed,
   notify  => Exec['login link'],
   require => [Package['drush'], File['aegir-stable.list'], Exec['apt_update']],
 }

 include aegir::login_link

}
