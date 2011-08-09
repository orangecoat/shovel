#!/bin/bash
#
# This file will install Drupal the OC way.

# if there's an error, don't continue
set -e

echo "
  This script will walk you through the process of getting a new Drupal project
  installed and configured, the OrangeCoat way. It's going to

    1. Delete the .git folder and README.mkd file that comes in the shovel repo
    2. Download Drupal to the current directory
    3. Help you set up a database
    4. Set up some pre-configured, best-practice-style options
    5. Set you up with a theme skeleton for your custom theming needs
"
read -p "Does all this sound ok? [n] " proceed
if [[ $proceed =~ ^[Yy]$ ]]; then

  echo "
  ¡Muy bien! Let's download Drupal...
  "
  # Clear out stuff from the shovel repo
  rm -rf .git README.mkd
  # And download Drupal and contrib stuff
  drush make shovel.make -y

  echo "
  Let's set up the database, shall we? You should know, though, that whatever
  database name you choose will be dropped and then re-created, so make sure
  you're not going to overwrite something important.  You'll also be asked for
  confirmation before everything goes down for real.
  "
  until read -p "What database would you like Drupal installed into? " dbname && [[ $dbname ]]; do
    echo "
  You have to enter a database name. I'll give you another shot.
    "
  done

  read -p "And what is your mysql username? " mysqluser
  read -s -p "And what is your mysql password? " mysqlpasswd
  [[ $mysqlpasswd ]] && mysqlpasswd=":$mysqlpasswd"
  echo

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

  echo "
  While this is installing, make sure that password is safe somewhere! Go!
  "

  drush site-install dirt\
    --db-url="mysql://$mysqluser$mysqlpasswd@localhost/$dbname"\
    --account-name="$username"\
    --account-pass="$passwd"\
    --account-mail="$email"\
    --site-mail="$email"\
    --site-name="$sitename"\
    --sites-subdir="oc-dev"

  chmod -R 777 sites/oc-dev/files

  echo "
  Well that went surprisingly well. Now let's set up the custom theme.
  "

  path=`pwd`
  subdir=`basename $path`
  read -p "Human-readable theme name: [$subdir] " themename
  [[ $themename ]] || themename=$subdir
  read -p "Machine-readable theme name: [$subdir] " themename_machine
  [[ $themename_machine ]] || themename_machine=$themename
  echo

  themedir=sites/all/themes/$themename_machine
  git clone git://github.com/orangecoat/skeleton.git $themedir
  rm -rf $themedir/.git
  mv $themedir/skeleton.info $themedir/$themename_machine.info
  sed -i -e "s/Skeleton/$themename/g" $path/$themedir/$themename_machine.info
  echo

  read -p "Set the custom theme as default? [n] " enabletheme
  if [[ $enabletheme =~ ^[Yy]$ ]]; then
    drush en $themename_machine -l oc-dev -y
    drush vset theme_default $themename_machine -l oc-dev --yes
    drush dis bartik -l oc-dev -y
  fi

  echo "
  Now for some finishing touches...
  "

  read -p "Would you like to enable securepages? [y] " usessl
  if [[ $usessl =~ ^[Yy]$ ]]; then
    drush vset securepages_enable 1 -l oc-dev --yes
  fi
  echo

  read -p "What is your api key for textcaptcha.com? " textcaptcha_api_key
  if [[ $textcaptcha_api_key ]]; then
    drush vset textcaptcha_api_key $textcaptcha_api_key -l oc-dev --yes
  fi

  echo "
  Congrats! It looks like everything went well. Don't forget to set up
  symlinks for the sites directory.
  "
fi
