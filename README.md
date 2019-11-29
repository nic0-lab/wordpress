# wordpress-update.sh

(c) Niki Kovacs 2019

The Bash shell script `wordpress-update.sh` manages automatic updates
on a secure WordPress installation using WP-CLI.

Before running the script, edit it to provide some basic information:

  * `HTUSER`: the name of the user running the httpd process

  * `HTGROUP`: the name of the group running the httpd process

  * `WPUSER`: the user owning the core WordPress installation

  * `WPGROUP`: the group owning the core WordPress installation

  * `WPROOT`: your web server's root directory (`/var/www`, etc.)

Copy the `wordpress-update.sh` script to a sensible location like your `~/bin`
directory and make sure it's executable.

# Discussion

WordPress can normally handle automatic updates, but only on configurations
with write permissions for the web server process, which is generally a bad
idea. 

That's where `wordpress-update.sh` comes in handy. It manages updates for the
WordPress core installation, themes and plugins even on secure installations,
e. g. with sane file permissions according to the official *Hardening
WordPress* documentation. 

The script automagically identifies all WordPress installations on the server.
Try it out manually at first:

```
$ sudo ./wordpress-update.sh 
Updating WP-CLI to the latest version.
Success: WP-CLI is at the latest version.
Found WordPress installation at: /var/www/slackbox-blog/html
Setting file permissions.
Updating WordPress core.
Success: WordPress is up to date.
Updating WordPress plugins.
Success: Plugin already updated.
Updating WordPress themes.
Success: Theme already updated.
```

Once the script runs as expected, you can use it in a cronjob:

```
$ sudo crontab -e
30 4 * * * /home/microlinux/bin/wordpress-update.sh 1> /dev/null
```



