# Simple Mastodon Docker Guide

Mastodon is the federated Twitter alternative you can host yourself. I wanted to do just that, but there isn't an official guide for doing it. There are other guides out there, many of them seem unnecessarily complicated, so here's my simple take. It sets up Mastodon, but also nginx and SSH certificates with Let's Encrypt, 

This guide also includes instructions for how to backup and restore your Mastodon server, so you know your data is safe.

## Requirements

- A Linux machine with at least 1 CPU core, 1 Gb of RAM, and however much disk space you plane on tweeting. A basic Linode VPS will do. You can use whatever distro you like, I use Ubuntu 20.04 LTS.
- A relatively recent version of docker and docker-compose, for the latter I have 25.0.3-1, if you're running an older version you need to run your containers in privileged mode, which is always good to avoid.
- Port 80 and 443 available, so no Nginx or Apache etc.
- A domain with a DNS.
- Access to an SMTP account. I use Amazon, Mastodon suggests Mailgun.

## Setup

- Create a directory somewhere on your machine to host Mastodon, f.egs

      mkdir /srv/mastodon
      cd /srv/mastodon
  
- Create a text file

      nano docker-compose.yml

  and copy/paste the content of /docker-compose.yml to that file. Save and exit.

- create an empty settings file, the Mastodon setup wizards requires this.

      touch .env.production

- Start the setup wizard. It's clunky and weird, but we need to live with it

      docker-compose run --rm web bundle exec rake mastodon:setup

  Note that the wizard doesn't care about the contents of .env.production, it will always run through the same steps.

      Domain : egs : mastodon.yourdomain.com
      Single user mode : if you select no, other people will be able to create accounts on your machine.  
      Run in Docker : yes
      All Postgres questions : select default answers, if you get an error, you're likely on an outdated version of docker 
      All Redis questions : ditto
      Upload to cloud : no, Mastodon supports saving media to S3, I'm assuming you're saving locally
      Emails from localhost: no, we want to use external SMTP
      All SMTP questions: enter whatever fits your SMTP service
      Emails from : notificaations@<some address your smtp service lets you send from>
      Send test email : always good to confirm your service works
      periodic checks : whatever, I always say no
      Save config : YES. The wizard will print output to screen, copy and paste this into .env.production in another terminal window and save before proceeding.
      Prepare db : yes

 At this point Mastodon will populate your DB, and this is where things can get hairy.
  
      Create admin user : yes
      Name : <user name for your account>
      Email: email address to send password reset to

  At this point Mastodon will attempt to set up your user, and very likely fail trying to contact Redis. If it does, don't panic, your user will likely have been created. If it does't fail, you'll be given a random password to login in with. Save this. If you get the Redis error, proceed any way.

- Now some final set up for Nginx. In your current directory, you will now have a `/proxy/conf.d` directory, to create a redirect

      nano /proxy/conf.d/mastodon.conf

  Copy the contents of /nginx.conf in this repo to it, then change two occurences of `mastodon.yourdmain.com` in that file to whatever domain or subdomain you're using for your server. Save and exit.

- We need to set some file permissions so mastodon can save media to disk. Get your mastodon container user id


      docker exec mastodon-web id -u mastodon

  this returns `991` for me. Then

     chdown 991 -R ./public

- Restart everything

      docker-compose down
      docker-compose up -d

  All containers should start and stay up, and your should be able to access your instance in a browser. Note that Mastodon can take a few seconds to start.  If you managed to get a password out of the wizard without it throwing a Redis   error, you can log in with it and and set a real password. If not, you can request a password reset email and login that way.

- Once in Mastodon, set your profile image under Preferences > Public Profile > Profile Image and ensure that it can save, if you get an error, you haven't set the permissions on the 
 `./public` directory properly.



  
  

  

       
