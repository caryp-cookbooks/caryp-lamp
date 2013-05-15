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

# rs-app cookbook interface attributes
#

# By default listen on port 8000
default['rs-app']['port'] = "8000"
# By default listen on the first private IP
default['rs-app']['ip'] = nil
# The database schema name the app server uses
default['rs-app']['database_name'] = "myschema"


# rs-db cookbook interface attributes
#

# Default setting for DB FQDN
default['rs-db']['dns']['master']['fqdn'] = "localhost"

# Default settings for database administrator user and password
default['rs-db']['admin']['user'] = "root"
default['rs-db']['admin']['password'] = nil

default['rs-db']['application']['user'] = "appuser"
default['rs-db']['application']['password'] = nil

# PHP specific attributes
#

# List of additional php modules
default['ckp-lamp']['modules_list'] = []



