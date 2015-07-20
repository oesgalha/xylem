Exec { path => [ "/usr/local/sbin/", "/usr/local/bin/", "/usr/sbin", "/usr/bin", "/sbin/", "/bin/" ] }

$ruby_version = "2.2"
$ruby_version_full = "2.2.2"

$ruby_tmp_folder = "/home/vagrant/tmp/ruby-src/"

$ruby_extracted_tmp_folder = "${$ruby_tmp_folder}ruby-${$ruby_version_full}/"

# apt-get update
exec { "apt-update":
  command => "apt-get update"
}

Exec["apt-update"] -> Package <| provider == "apt" |>

# Install ruby dependecies
$ruby_deps = [ "build-essential", "curl", "git-core", "libcurl4-openssl-dev", "libffi-dev", "libreadline-dev", "libsqlite3-dev", "libssl-dev", "libxml2-dev", "libxslt1-dev", "libyaml-dev", "python-software-properties", "sqlite3", "zlib1g-dev" ]
package { $ruby_deps:
  ensure  => "installed",
  provider => "apt"
}

# Install ruby from source
exec { "download ruby":
  command => "wget -P ${$ruby_tmp_folder} http://cache.ruby-lang.org/pub/ruby/${$ruby_version}/ruby-${$ruby_version_full}.tar.gz",
  creates => "${$ruby_tmp_folder}ruby-${$ruby_version_full}.tar.gz",
  unless  => "ruby -v | grep -q ${ruby_version_full}",
  require => Package[$ruby_deps]
}
exec { "clean failed ruby":
  command => "rm -rf ruby-${$ruby_version_full}",
  onlyif  => "test -d ruby-${$ruby_version_full}",
  unless  => "ruby -v | grep -q ${ruby_version_full}",
  cwd     => "${$ruby_tmp_folder}",
  require => Exec["download ruby"]
}
exec { "extract ruby":
  command => "tar -xvzf ruby-${$ruby_version_full}.tar.gz",
  cwd     => "${$ruby_tmp_folder}",
  creates => "${$ruby_extracted_tmp_folder}",
  unless  => "ruby -v | grep -q ${ruby_version_full}",
  require => Exec["clean failed ruby"]
}
exec { "configure ruby":
  command => "${$ruby_extracted_tmp_folder}configure --disable-install-doc",
  creates => "${$ruby_extracted_tmp_folder}Makefile",
  cwd     => "${$ruby_extracted_tmp_folder}",
  unless  => "ruby -v | grep -q ${ruby_version_full}",
  require => Exec["extract ruby"]
}
exec { "make ruby":
  command => "make",
  timeout => 0,
  unless  => "ruby -v | grep -q ${ruby_version_full}",
  cwd     => "${$ruby_extracted_tmp_folder}",
  require => Exec["configure ruby"]
}
exec { "make install ruby":
  command => "make install",
  timeout => 0,
  unless  => "ruby -v | grep -q ${ruby_version_full}",
  cwd     => "${$ruby_extracted_tmp_folder}",
  require => Exec["make ruby"]
}

# Install bundler
package { 'bundler':
  ensure   => "installed",
  provider => "gem",
  require => Exec["make install ruby"]
}

# Add postgres repo
file { "/etc/apt/sources.list.d/pgdg.list":
  content => "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main"
}

# Add postgres key
exec { "wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -":
  alias => "postgres-key",
  unless => "apt-key list | grep -q PostgreSQL"
}

# Install postgres
$postgres_packages = [ "postgresql-common", "postgresql-9.3", "libpq-dev" ]
package { $postgres_packages:
  ensure  => "installed",
  provider => "apt",
  require => [ File["/etc/apt/sources.list.d/pgdg.list"], Exec["postgres-key"] ]
}

# Create superuser xylem in postgres
$xylem_role = "xylem"
$xylem_pass = "xylemsecret"
exec { "sudo -u postgres createuser ${xylem_role} -s && sudo -u postgres psql -c \"ALTER USER ${xylem_role} WITH PASSWORD '${xylem_pass}';\"":
  unless => "sudo -u postgres psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${xylem_role}'\" | grep -q 1",
  require => Package[$postgres_packages]
}
