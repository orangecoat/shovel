#!/bin/bash
#
# This file will install Drupal the OC way.

# if there's an error, don't continue
set -e

# Clear out stuff from the shovel repo
rm -rf .git README.mkd
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

chmod -R 777 sites/oc-dev/files

path=`pwd`
subdir=`basename $path`
read -p "What should the custom theme be named? (Human readable) [$subdir] " themename
[[ $themename ]] || themename=$subdir
read -p "What should the machine-name of the custom theme be? (lowercase and underscores only) [$subdir] " themename_machine
[[ $themename_machine ]] || themename_machine=$themename

themedir=sites/all/themes/$themename_machine
git clone git://github.com/orangecoat/skeleton.git $themedir
rm -rf $themedir/.git
mv $themedir/skeleton.info $themedir/$themename_machine.info
sed -i -e "s/Skeleton/$themename/g" $path/$themedir/$themename_machine.info

echo "
  Well that went surprisingly well. Now let's take care of a few things. Just
  icing on the cake, really.
"

read -p "Would you like to enable securepages? (Beware, you'll regret this if you don't have SSL already set up properly) [y] " usessl
if [[ $usessl =~ ^[Yy]$ ]]; then
  drush vset securepages_enable 1 -l oc-dev --yes
fi
echo

read -p "What is your api key for textcaptcha.com? " textcaptcha_api_key
if [[ $textcaptcha_api_key ]]; then
  drush vset textcaptcha_api_key $textcaptcha_api_key -l oc-dev --yes
fi
