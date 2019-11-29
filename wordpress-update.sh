#!/bin/bash
#
# wordpress-update.sh
#
# (c) Niki Kovacs 2019 <info@microlinux.fr>
#
# This script updates one or multiple WordPress installations.

# WP-CLI
WP='/usr/local/bin/wp'

# Download
DOWNLOAD='http://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar'

# Apache
HTUSER='apache'
HTGROUP='apache'

# User
WPUSER='microlinux'
WPGROUP='microlinux'

# Webroot
WPROOT='/var/www'

# Search depth
DEPTH=4

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
  echo 'Please run with sudo or as root.' >&2
  exit 1
fi

# Test if WP-CLI is installed on the system.
if [ ! -x ${WP} ]
then
  echo "Installing WP-CLI on this system." 
  wget -c ${DOWNLOAD}/wp-cli.phar > /dev/null 2>&1
  if [ "${?}" -ne 0 ]
  then
    echo "Could not download WP-CLI." >&2
    exit 1
  fi
  mv wp-cli.phar ${WP}
  chmod 0755 ${WP}
fi

# Update WP-CLI itself
echo "Updating WP-CLI to the latest version."
${WP} cli update
if [ "${?}" -ne 0 ]
then
  echo "Could not update WP-CLI." >&2
  exit 1
fi

# Find all WordPress installations on the server
WPDIRS=$(dirname $(find ${WPROOT} -maxdepth ${DEPTH} \
  -type f -name 'wp-config.php'))

for WPDIR in ${WPDIRS}
do
  echo "Found WordPress installation at: ${WPDIR}"
  cd ${WPDIR}
  # Set permissions
  echo "Setting file permissions."
  chown -R ${WPUSER}:${WPGROUP} ${WPDIR}
  find ${WPDIR} -type d -exec chmod 0755 {} \;
  find ${WPDIR} -type f -exec chmod 0644 {} \;
  chown -R ${WPUSER}:${HTGROUP} ${WPDIR}/wp-content
  find ${WPDIR}/wp-content -type d -exec chmod 0775 {} \;
  find ${WPDIR}/wp-content -type f -exec chmod 0664 {} \;
  # Update WordPress core
  echo "Updating WordPress core."
  su -c "${WP} core update" ${WPUSER}
  # Update WordPress plugins
  echo "Updating WordPress plugins."
  su -c "${WP} plugin update --all" ${WPUSER}
  # Update Wordpress themes
  echo "Updating WordPress themes."
  su -c "${WP} theme update --all" ${WPUSER}
done

exit 0
