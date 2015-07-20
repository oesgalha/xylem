Exec { path => [ "/usr/local/sbin/", "/usr/local/bin/", "/usr/sbin", "/usr/bin", "/sbin/", "/bin/" ] }

# apt-get update
exec { "apt-update":
  command => "apt-get update"
}

Exec["apt-update"] -> Package <| provider == "apt" |>

# Install ruby dependecies
$ruby_deps = [ "software-properties-common" ]
package { $ruby_deps:
  ensure  => "installed",
  provider => "apt"
}

# Add rubies repo
exec { "apt-add-repository ppa:brightbox/ruby-ng":
  alias => "add-ruby-repo",
  creates => "/etc/apt/sources.list.d/brightbox-ruby-ng-trusty.list"
}

# Install rubies
$ruby_packages = ["ruby-switch", "ruby2.2"]
package { $ruby_packages:
  ensure  => "installed",
  provider => "apt",
  require => Exec["add-ruby-repo"]
}

# Ruby switch
exec { "ruby-switch --set ruby2.2":
  alias => "switch ruby2.2",
  require => Package[$ruby_packages]
}

# Install bundler
package { "bundler":
  ensure   => "installed",
  provider => "gem",
  require => Exec["switch ruby2.2"]
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
