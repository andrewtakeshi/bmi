# IcingaWeb2 Dependency Module Configuration

This is only necessary if you're using MySQL as the database for the dependency information. Apparently (I haven't tried this) it works fine on PostgreSQL.
- Clone the repository, found [here](https://github.com/visgence/icinga2-dependency-module) into ```/usr/share/icingaweb2/modules```, then rename via ```mv icinga2-dependency-module dependency_plugin```. 
- Create a new mysql database and apply necessary migrations
  - ```mysql -e "CREATE DATABASE dependencies CHARACTER SET 'utf8'; GRANT ALL ON dependencies.* TO dependencies@localhost IDENTIFIED BY 'dependencies';"```
  - ```mysql -U dependencies -D dependencies > /usr/share/icingaweb2/modules/dependency_plugin/application/schema/init.sql```
  - ```mysql -U dependencies -D dependencies > /usr/share/icingaweb2/modules/dependency_plugin/application/schema/01-migration.sql```
  - ```mysql -e "USE dependencies; UPDATE plugin_settings SET api_host = 'localhost' WHERE api_host IS NULL;"```
- Follow the rest of the instructions (i.e. add the newly created database as a resource in IcingaWeb2 and then follow the kickstart for the actual dependency plugin). 

This is only necessary because the instructions don't mention applying the 01-migration schema, which is also inherently broken for mysql which leads to setting a new default value for api_host. If you fail to do this the dependency plugin won't work, which is a shame because it's super cool and does a lot of fun stuff pretty easily. 
