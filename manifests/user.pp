# Define: mysql::user
#
# This module creates database user, and grants that user
# privileges to the database. 
#
# Since it requires class mysql::server, we assume to run all commands as the
# root mysql user against the local mysql server.
#
# Parameters:
#   [*title*]       - mysql user name.
#   [*password*]    - user's password.
#   [*host*]        - host for assigning privileges to user.
#   [*grant*]       - array of privileges to grant user.
#   [*ensure*]      - specifies if a database is present or absent.
#
# Actions:
#
# Requires:
#
#   class mysql::server
#
# Sample Usage:
#
#  mysql::user { 'mydb_user':
#    password => 'password',
#    host     => $::hostname,
#    grant    => 'all'
#  }
#
define mysql::user (
  $password,
  $database    = '*',
  $host        = 'localhost',
  $grant       = 'all',
  $ensure      = 'present'
) {

  $user = $name

  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql_password($password),
    provider      => 'mysql'
  }
  ensure_resource('database_user', "${user}@${host}", $user_resource)

  if $ensure == 'present' {
    database_grant { "${user}@${host}/${database}":
      privileges => $grant,
      provider   => 'mysql',
      require    => Database_user["${user}@${host}"],
    }
  }
}
