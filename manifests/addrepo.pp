# == Type: aptrepo::addrepo
#
# Add a debian repository and update the list of packages
#
# === Parameters
# [implicit]
#   The name of the repository
#
# ["location"]
#   Base URL of repository
#
# ["release"]
#   Which release to use, defaults to 'stable'
#
# ["key"]
#   URL of the repository signing key

define aptrepo::addrepo($location, $release = 'stable', $key = '') {
  file { $title:
    ensure  => 'present',
    path    => "/etc/apt/sources.list.d/${title}.list",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('aptrepo/source.erb'),
  } ~> Exec['apt-get']

  if $key != '' {
    exec { 'add_key':
      command     => "/usr/bin/wget -q ${key} -O- | /usr/bin/apt-key add -",
      refreshonly => true,
      subscribe   => File[$title],
    } ~> Exec['apt-get']
  }

  exec { 'apt-get':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
  }
}
