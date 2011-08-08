#!/usr/bash
#
# This file will install Drupal the OC way.

# if there's an error, don't continue
set -e

# Clear out stuff from the shovel repo
#rm -rf .git README.mkd
# And download Drupal and contrib stuff
drush make shovel.make -y

echo "
  So you want to set up a fresh Drupal install, eh? Ok, we'll start by getting
  some information about the database. Whatever database name you enter will
  be dropped and then re-created, so make sure you not to do something stupid.
  You'll also be asked for confirmation before everything goes down for real.
"
until read -p "What database would you like Drupal installed into? " dbname && [[ $dbname ]]; do
  echo "
  You have to enter a database name. I'll give you another shot.
  "
done

read -p "And what is your mysql username? " mysqluser
read -s -p "And what is your mysql password? " mysqlpasswd
[[ $mysqlpasswd ]] && mysqlpasswd=":$mysqlpasswd"

echo "
  Great, now we need some information for the Drupal side of things.
"

read -p "What's this site called? [OrangeCoat Site Install] " sitename
[[ $sitename ]] || sitename="OrangeCoat Site Install"

read -p "What would you like the admin email to be? [support@orangecoat.com] " email
[[ $email ]] || email="support@orangecoat.com"

read -p "What would you like the admin username to be? [drupalMaster] " username
[[ $username ]] || username="drupalMaster"

until read -s -p "What would you like the admin password to be? " passwd && [[ $passwd ]]; do
  echo "
  You have to enter a password for the Drupal admin account.
  I'll give you another shot.
  "
done

drush site-install dirt\
  --db-url=mysql://$mysqluser$mysqlpasswd@localhost/$dbname\
  --account-name=$username\
  --account-pass=$passwd\
  --account-mail=$email\
  --site-mail=$email\
  --site-name=$sitename\
  --sites-subdir=oc-dev

chmod 777 sites/oc-dev/files
