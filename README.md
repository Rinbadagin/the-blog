# README

## To set up 'in prod' on a recent ubuntu version with tmux:
If you would prefer to run this persistently and reliably in some other way, feel free to disregard these instructions. At some point this might be containerised. Don't hold your breath.

### Notes:
Remove any <> characters in commands unless directed otherwise.
Content after `#` in shell commands doesn't need to be input if you're typing it out. It won't do anything, so feel free to include if you're copy/pasting.

### Before you start:
You need a running VM/instance/server/whatever on a recent ubuntu version (24.04 LTS recommended) that you can run shell commands against as root. It should have A DNS records pointing `www.<YOUR DOMAIN>` and `<YOUR DOMAIN>` to an assigned ipv4 address.
Choose a branch to base your instance and or any future changes to this code on. `main` is the least maintained, `elizas-blog`, `fem-nz-blog`, and `klara-nz-blog` all have more recent changes. They differ in cosmetics and some internal things (e.g. fem-nz-blog has webring handling code). The branch you choose will be used in the initial setup of the server.

From a suitably permissioned shell run the following commands one-by-one (line separated)
```sh
sudo apt update && sudo apt upgrade
sudo apt install git tmux cron
```
Follow the instructions at [https://github.com/rbenv/rbenv?tab=readme-ov-file#basic-git-checkout](rbenv git install)
Open a new shell or run `source ~/.zshrc` // `source ~/.bashrc` (this should set up rbenv in the local shell, to test run `rbenv local` - the command should be successful)
Afterwards, clone your fork of this repository (or this repository) via git into a directory I will now refer to as `$BLOG_DIRECTORY`. 
<img width="838" height="728" alt="image" src="https://github.com/user-attachments/assets/ee409e84-b572-4da0-b1e8-2729e5019263" />
(click '< > Code' from the main repositroy view, then the copy icon \[tooltip 'copy url to clipboard' in the English UI] to copy the url and run `git clone <PASTE URL HERE> $BLOG_DIRECTORY`) 

You might like to set this in your shell so you can copy the following commands verbatim via running `export "BLOG_DIRECTORY=<insert your directory here, likely something like $(realpath ~/the-blog)>"`

Now, run the following commands in order (one-by-one, line separated, ignore content after `#` if typing):
```sh
cd $BLOG_DIRECTORY # changing dir into the directory so further commands are in that context
git checkout $BRANCH # The branch you chose earlier. This makes the version you have in this directory consistent with that
rbenv install # To install the required ruby version in .ruby-version
export RAILS_ENV=production # To run the following commands against the production rails environment
bin/rails db:migrate
chmod +x prod_startmux.sh # make prod_startmux executable
ln -s prod_startmux.sh ~/prod_blog_startmux.sh # symlink to home dir so that crontab is simpler, and startup file is visible in ls ~/
bin/rails console
```
You will now be in a Rails console, run `Article.new(body: "Sample index body", title: "Index page", visibility: true).save` to create the index article (loading the main site will fail without this).
In order to login to the site, you should also run `User.new(name: "your username to enter in the login page", password: "your password to enter in the login page").save`.
With luck, you should see the output `=> true` in the console for both of those. 

To update your password later, run `a = User.find(name: "your username")`, `a.password = "your new password"` and `a.save`. 
The site is not designed with multiple users in mind and may fail or have unexpected behaviour if you create multiple accounts.

You should also edit the file in `$BLOG_DIRECTORY/prod_blog_startmux.sh` to set your `$BLOG_DIRECTORY` variable appropriately (where it says `export BLOG_DIRECTORY="update this"`), using your editor of choice (nano should already be installed, you can run `nano $BLOG_DIRECTORY/prod_blog_startmux.sh` and use the keybinds at the bottom of the screen \[^ means the control key, e.g. ^X exit means pressing `control + x` will exit])

At this point, run `crontab -e`.
Add this line at the end (remember to update the `<YOUR USER>` sections):
`@reboot sleep 30 && /home/<YOUR USER>/prod_blog_startmux.sh 2>&1 /home/<YOUR USER>/prod_blog_startup.log`
And save the crontab. On every reboot, `prod_blog_startmux.sh` will run as your after a 30 second delay, logging output to `~/prod_blog_startup.log`.

In order to connect your blog to github actions (so push automatically updates) amend `deploy/run.sh` and/or `.github/workflows/xyz.yml` if they exist on your branch.

It is advisable to run this server behind a reverse proxy (e.g. nginx) to provide a layer of indirection and also provide https support.
To use nginx, run `sudo apt install nginx certbot python3-certbot-nginx` and `cd /etc/nginx/sites-enabled`
Create a file named after your site, e.g. `klara-nz` with the following content (substitute `YOUR SERVER` for your domain) - you may need to do so as root:
```nginx
server {
        server_name www.<YOUR SERVER> <YOUR SERVER>;
        autoindex on;
        client_max_body_size 500M;

        location / {
                proxy_pass http://127.0.0.1:<YOUR PORT>/;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto http;
                proxy_set_header X-Forwarded-Server $host;
                proxy_set_header Host $http_host;
                proxy_redirect off;
        }
}
```
And run `sudo nginx -t` to check the validity of your configuration (note the 'YOUR SERVER' and the 'YOUR PORT' parameter in `proxy_pass` \[this may depend on the branch you chose earlier - \[elizas-blog branch is 3000, fem-nz-blog is 6000, klara-nz-blog is 4000, by default]). When that works, run the following commands in order (remember to substitute YOUR DOMAIN):
```sh
sudo systemctl reload nginx # restart nginx with the new configuration
sudo ufw allow 'Nginx Full' # allow nginx traffic through the firewall
sudo ufw delete allow 'Nginx HTTP' # allow nginx traffic through the firewall
sudo certbot --nginx -d <YOUR DOMAIN> -d www.<YOUR DOMAIN> # get an https certificate for your site and reconfigure nginx appropriately
```
You probably want to redirect traffic to https if prompted.

Reboot the server (`reboot`), and wait 30 seconds. The site should be available if DNS records for your domain have been configured to point to a valid ipv4 address pointing to the instance you have configured (the earlier https certificate fetching stage would have failed if this was the case).

To manually bring your site up-to-date with any changes you have made to the branch and version you cloned, open a new shell on the instance:
```sh
cd $BLOG_DIRECTORY
export RAILS_ENV=production # changes apply to production database and assets
git pull # get the latest changes on your branch
bin/rails assets:precompile # setup assets if any have changed (e.g. new images)
bin/rails db:migrate # migrate db to the latest version if any migrations have been added
bin/rails restart # restart the server running in tmux with any new changes
```
To access the currently running server directly (e.g. to stop it manually)
```sh
tmux attach -t prod_blog
```
Any keyboard input (e.g. control + c to stop the currently running program) will be applied to the tmux context. To detach from tmux, press ^B (control + b). `tmux list-sessions` shows currently running sessions.
