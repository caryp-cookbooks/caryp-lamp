#
# Cookbook Name:: ckp-lamp
#
# Copyright (C) 2013 RightScale
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

SCHEMA_NAME = 'app_test'

#
# Deploy mysql database
#
include_recipe 'mysql::server'
include_recipe 'database::mysql'

if Chef::Config[:solo]
  if node['rs-db']['application']['password'].nil?
    Chef::Application.fatal!([
        "You must set node['rs-db']['application']['password'] in chef-solo mode.",
        "For more information, see TBD" #TODO
      ].join(' '))
  end
else
  # generate application user and password
  node.set_unless['rs-db']['application']['password'] = secure_password
  node.save
end

mysql_connection_info = {
    :host => 'localhost',
    :username => 'root',
    :password => node['mysql']['server_root_password']
  }

mysql_database SCHEMA_NAME do
  connection mysql_connection_info
  action :create
end


#
# Deploy PHP application
#
include_recipe 'php::module_mysql'
include_recipe 'git'

application 'phpvirtualbox' do

  path '/usr/local/www/sites/phpvirtualbox'
  owner node['apache']['user']
  group node['apache']['user']
  repository 'git://github.com/rightscale/examples.git'
  revision 'unified_php'
  #deploy_key '...'
  packages ['php-soap']

  # populate the database from a dumpfile in the code repo
  migrate true
  cmd = "gunzip < #{SCHEMA_NAME}.sql.gz | mysql -u#{mysql_connection_info[:username]} -p#{mysql_connection_info[:password]}  #{SCHEMA_NAME}"
  migration_command cmd

  php 'phpvirtualbox' do
    app_root '/unified_php'

    # database configuration
    write_settings_file true
    local_settings_file 'config/db.php'
    settings_template 'db.php.erb'

    # link shared file to release dir
    symlink_before_migrate({
      'config/db.php' => 'config/db.php'
    })

    database do
      host     mysql_connection_info[:host]
      user     'appuser'
      password 'apppass'
      schema   SCHEMA_NAME
    end
  end

  mod_php_apache2 do
    webapp_template 'php.conf.erb'
  end

end


# grant select,update,insert privileges to all tables in foo db from all hosts
mysql_database_user node['rs-db']['application']['user'] do
  connection mysql_connection_info
  password node['rs-db']['application']['password']
  database_name SCHEMA_NAME
  host mysql_connection_info['host']
  #privileges [:select,:update,:insert]
  action :grant
end