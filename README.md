[![Docker Repository on Quay.io](https://quay.io/repository/jasl8r/mattermost/status "Docker Repository on Quay.io")](https://quay.io/repository/jasl8r/mattermost) [![](https://badge.imagelayers.io/jasl8r/mattermost:latest.svg)](https://imagelayers.io/?images=jasl8r/mattermost:latest 'Get your own badge on imagelayers.io')

# Docker Mattermost

- [Introduction](#introduction)
    - [Changelog](Changelog.md)
- [Contributing](#contributing)
- [Issues](#issues)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
    - [Data Store](#data-store)
    - [Database](#database)
        - [MySQL](#mysql)
            - [External MySQL Server](#external-mysql-server)
            - [Linking to MySQL Container](#linking-to-mysql-container)
    - [Mail](#mail)
    - [SSL](#ssl)
        - [Using HTTPS with a load balancer](#using-https-with-a-load-balancer)
    - [GitLab Integration](#gitlab-integration)
    - [Available Configuration Parameters](#available-configuration-parameters)
- [Maintenance](#maintenance)
    - [Upgrading](#upgrading)
    - [Shell Access](#shell-access)
- [References](#references)

# Introduction

Dockerfile to build a [Mattermost](https://www.mattermost.org/) container image.

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/jasl8r/docker-mattermost/issues) they may encounter

# Issues

Please file a issue request on the [issues](https://github.com/jasl8r/docker-mattermost/issues) page.

# Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/jasl8r/mattermost) and is the recommended method of installation.

> **Note**: Builds are also available on [Quay.io](https://quay.io/repository/jasl8r/mattermost)

```bash
docker pull jasl8r/mattermost:2.1.0
```

You can also pull the `latest` tag which is built from the repository *HEAD*

```bash
docker pull jasl8r/mattermost:latest
```

Alternatively you can build the image locally.

```bash
docker build -t jasl8r/mattermost github.com/jasl8r/docker-mattermost
```

# Quick Start

The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/).

```bash
wget https://raw.githubusercontent.com/jasl8r/docker-mattermost/master/docker-compose.yml
```

Generate and assign random strings to the `MATTERMOST_SECRET_KEY`, `MATTERMOST_LINK_SALT`, `MATTERMOST_RESET_SALT` and `MATTERMOST_INVITE_SALT` environment variables. Once set you should not change these values and ensure you backup these values.

> **Tip**: You can generate a random string using `pwgen -Bsv1 64`.

Start Mattermost using:

```bash
docker-compose up
```

Alternatively, you can manually launch the `mattermost` container and the supporting `mysql` and `redis` containers by following this three step guide.

Step 1. Launch a mysql container

```bash
docker run --name mattermost-mysql -d \
    --env 'MYSQL_USER=mattermost' --env 'MYSQL_PASSWORD=password' \
    --env 'MYSQL_DATABASE=mattermost' --env 'MYSQL_ROOT_PASSWORD=password' \
    --volume /srv/docker/mattermost/mysql:/var/lib/mysql
    mysql:latest
```

Step 2. Launch the mattermost container

```bash
docker run --name mattermost -d \
    --link mattermost-mysql:mysql \
    --publish 8080:80 \
    --env 'MATTERMOST_SECRET_KEY=long-and-random-alphanumeric-string' \
    --env 'MATTERMOST_LINK_SALT=long-and-random-alphanumeric-string' \
    --env 'MATTERMOST_RESET_SALT=long-and-random-alphanumeric-string' \
    --env 'MATTERMOST_INVITE_SALT=long-and-random-alphanumeric-string' \
    --volume /srv/docker/mattermost/mattermost:/opt/mattermost/data \
    jasl8r/mattermost:2.1.0
```

*Please refer to [Available Configuration Parameters](#available-configuration-parameters) to understand `MATTERMOST_PORT` and other configuration options*

__NOTE__: Please allow a couple of minutes for the Mattermost application to start.

Point your browser to `http://localhost:8080` and create your administrator account.

You should now have the Mattermost application up and ready for testing. If you want to use this image in production the please read on.

*The rest of the document will use the docker command line. You can quite simply adapt your configuration into a `docker-compose.yml` file if you wish to do so.*

# Configuration

## Data Store

Mattermost stores data in the file system for features like file uploads and avatars.  To avoid losing this data you should mount a volume at,

* `/opt/mattermost/data`

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /srv/docker/mattermost/mattermost
sudo chcon -Rt svirt_sandbox_file_t /srv/docker/mattermost/mattermost
```

Volumes can be mounted in docker by specifying the `-v` option in the docker run command.

```bash
docker run --name mattermost -d \
    --volume /srv/docker/mattermost/mattermost:/opt/mattermost/data \
    jasl8r/mattermost:2.1.0
```

## Database

Mattermost uses a database backend to store its data. You can configure this image to use MySQL.

### MySQL

#### External MySQL Server

The image can be configured to use an external MySQL database. The database configuration should be specified using environment variables while starting the Mattermost image.

Before you start the Mattermost image create a user and database for mattermost.

```sql
CREATE USER 'mattermost'@'%.%.%.%' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS `mattermost` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT ALL PRIVILEGES ON `mattermost`.* TO 'mattermost'@'%.%.%.%';
```

We are now ready to start the Mattermost application.

*Assuming that the mysql server host is 192.168.1.100*

```bash
docker run --name mattermost -d \
    --env 'DB_ADAPTER=mysql' --env 'DB_HOST=192.168.1.100' \
    --env 'DB_NAME=mattermost' \
    --env 'DB_USER=mattermost' --env 'DB_PASS=password' \
    --volume /srv/docker/mattermost/mattermost:/opt/mattermost/data \
    jasl8r/mattermost:2.1.0
```

#### Linking to MySQL Container

You can link this image with a mysql container for the database requirements. The alias of the mysql server container should be set to **mysql** while linking with the mattermost image.

If a mysql container is linked, only the `DB_ADAPTER`, `DB_HOST` and `DB_PORT` settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the `DB_NAME`, `DB_USER`, `DB_PASS` and so on.

To illustrate linking with a mysql container, we will use the official [mysql](https://hub.docker.com/_/mysql/) image. When using mysql in production you should mount a volume for the mysql data store.

First, lets pull the mysql image from the docker index.

```bash
docker pull mysql:latest
```

For data persistence lets create a store for the mysql and start the container.

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /srv/docker/mattermost/mysql
sudo chcon -Rt svirt_sandbox_file_t /srv/docker/mattermost/mysql
```

The run command looks like this.

```bash
docker run --name mattermost-mysql -d \
    --env 'MYSQL_USER=mattermost' --env 'MYSQL_PASSWORD=password' \
    --env 'MYSQL_DATABASE=mattermost' --env 'MYSQL_ROOT_PASSWORD=password' \
    --volume /srv/docker/mattermost/mysql:/var/lib/mysql
    mysql:latest
```

The above command will create a database named `mattermost` and also create a user named `mattermost` with the password `password` with full/remote access to the `mattermost` database.

We are now ready to start the Mattermost application.

```bash
docker run --name mattermost -d --link mattermost-mysql:mysql \
    --volume /srv/docker/mattermost/mattermost:/opt/mattermost/data \
    jasl8r/mattermost:2.1.0
```

Here the image will also automatically fetch the `MYSQL_DATABASE`, `MYSQL_USER` and `MYSQL_PASSWORD` variables from the mysql container as they are specified in the `docker run` command for the mysql container. This is made possible using the magic of docker links and works with the following images:

 - [mysql](https://hub.docker.com/_/mysql/)
 - [sameersbn/mysql](https://quay.io/repository/sameersbn/mysql/)
 - [centurylink/mysql](https://hub.docker.com/r/centurylink/mysql/)
 - [orchardup/mysql](https://hub.docker.com/r/orchardup/mysql/)

### Mail

The mail configuration should be specified using environment variables while starting the Mattermost image.

If you are using Gmail then all you need to do is:

```bash
docker run --name mattermost -d \
    --env 'SMTP_USER=USER@gmail.com' --env 'SMTP_PASS=PASSWORD'
    --env 'SMTP_DOMAIN=www.gmail.com' \
    --env 'SMTP_HOST=smtp.gmail.com' --env 'SMTP_PORT=587' \
    --volume /srv/docker/mattermost/mattermost:/opt/mattermost/data \
    jasl8r/mattermost:2.1.0
```

Please refer the [Available Configuration Parameters](#available-configuration-parameters) section for the list of SMTP parameters that can be specified.

### SSL

Access to the Mattermost application can be secured using SSL so as to prevent unauthorized access to the data in your repositories.

#### Using HTTPS with a load balancer

Load balancers like nginx/haproxy/hipache talk to backend applications over plain http and as such the installation of ssl keys and certificates are not required and should **NOT** be installed in the container. The SSL configuration has to instead be done at the load balancer.

However, when using a load balancer you **MUST** set `MATTERMOST_HTTPS` to `true`. 

With this in place, you should configure the load balancer to support handling of https requests. But that is out of the scope of this document. Please refer to [Using SSL/HTTPS with HAProxy](http://seanmcgary.com/posts/using-sslhttps-with-haproxy) for information on the subject.

When using a load balancer, you probably want to make sure the load balancer performs the automatic http to https redirection. Information on this can also be found in the link above.

In summation, when using a load balancer, the docker command would look for the most part something like this:

```bash
docker run --name mattermost -d \
    --publish 8080:80 --env 'MATTERMOST_HTTPS=true' \
    --volume /srv/docker/mattermost/mattermost:/opt/mattermost/data \
    jasl8r/mattermost:2.1.0
```


### GitLab Integration

Mattermost allows users to sign in using GitLab as an OAuth provider. Configuring GitLab does not prevent standard Mattermost authentication from continuing to work.  Users can choose to sign in using any of the configured mechanisms.

Refer to the Mattermost [documentation](http://docs.mattermost.com/deployment/sso-gitlab.html) for additional information.

To enable GitLab SSO you must register your application with GitLab. GitLab will generate a Client ID and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/gitlab.html) for the procedure to generate the Client ID and secret with GitLab.

Once you have the Client ID and secret generated, configure the SSO credentials using the `GITLAB_ID`, `GITLAB_SECRET`, `GITLAB_SCOPE`, `GITLAB_AUTH_ENDPOINT`, `GITLAB_TOKEN_ENDPOINT` and `GITLAB_API_ENDPOINT` environment variables.

### Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command. Alternatively you can use docker-compose.*

Below is the complete list of available options that can be used to customize your Mattermost installation.

- **DEBUG**: Set this to `true` to enable entrypoint debugging.
- **MATTERMOST_NAME**: The name of the Mattermost server. Defaults to `Mattermost`.
- **MATTERMOST_HOST**: The hostname of the Mattermost server. Defaults to `localhost`.
- **MATTERMOST_ENABLE_EMAIL_SIGNUP**: Enable or disable user signup via email. Defaults to `true`.
- **MATTERMOST_SECRET_KEY**: Used to encrypt sensitive fields in the database. Ensure that you don't lose it. You can generate one using `pwgen -Bsv1 64`. No defaults.
- **MATTERMOST_RESET_SALT**: Salt used to sign password reset emails. No defaults.
- **MATTERMOST_INVITE_SALT**: Salt used to sign email invites. No defaults.
- **MATTERMOST_MAX_LOGIN_ATTEMPTS**: Number of attempts a user may enter a password before being required to reset it. Defaults to `10`.
- **MATTERMOST_SEGMENT_KEY**: Segment API key for tracking metrics. No defaults.
- **MATTERMOST_GOOGLE_KEY**: Google API key for embeddeding YouTube videos. No defaults.
- **MATTERMOST_ENABLE_ADMIN_INTEGRATIONS**: Disable to allow any user to add integrations. Defaults to `true`.
- **MATTERMOST_ENABLE_SLASH_COMMANDS**: Enable to allow users to create custom slash commands. Defaults to `false`.
- **MATTERMOST_ENABLE_INCOMING_WEBHOOKS**: Enable to allow incoming webhooks. Defaults to `false`.
- **MATTERMOST_ENABLE_OUTGOING_WEBHOOKS**: Enable to allow outgoing webhooks. Defaults to `false`. 
- **MATTERMOST_WEBHOOK_OVERRIDE_USERNAME**: Enable to allow webhooks to set the username for a post. Defaults to `false`.
- **MATTERMOST_WEBHOOK_OVERRIDE_ICON**: Enable to allow webhooks to set the icon for a post. Defaults to `false`.
- **MATTERMOST_ENABLE_ALERTS**: Send administrators an email if security fixes are announced. Defaults to `true`.
- **MATTERMOST_ENABLE_INSECURE_CONNECTIONS**: Allow outgoing self-signed HTTPS connections. Defaults to `false`.
- **MATTERMOST_CORS_DOMAINS**: Domains allowed for HTTP cross-origin requests. Set to `*` to allow CORS from any domain. No defaults.
- **MATTERMOST_WEB_SESSION_DAYS**: Session duration in days for web clients. Defaults to `30`.
- **MATTERMOST_MOBILE_SESSION_DAYS**: Session duration in days for mobile clients. Defaults to `30`.
- **MATTERMOST_SSO_SESSION_DAYS**: Days until an SSO session expires. Defaults to `30`.
- **MATTERMOST_SESSION_CACHE**: Session cache duration in minutes. Defaults to `10`.
- **MATTERMOST_MAX_USERS**: Maximum number of users allowed per team. Defaults to `50`.
- **MATTERMOST_CREATE_TEAMS**: Allow users to create teams. Defaults to `true`.
- **MATTERMOST_CREATE_USERS**: Allow user signup. Defaults to `true`.
- **MATTERMOST_USER_DOMAINS**: Restrict user signup to emails belonging to the list of domains. No defaults.
- **MATTERMOST_RESTRICT_TEAM_NAMES**: Restrict the names for new teams. Defaults to `true`.
- **MATTERMOST_TEAM_DIRECTORY**: Enable to show teams on the main page for teams that opt-in to be listed. Defaults to `false`.
- **MATTERMOST_EMAIL_SIGNIN**: Allow users to sign in with their email. Defaults to `true`.
- **MATTERMOST_USERNAME_SIGNIN**: Allow users to sign in with their username. Defaults to `false`.
- **MATTERMOST_PUSH_SERVER**: Location of the Mattermost Push Notification Service (MPNS). No defaults.
- **MATTERMOST_ENABLE_PUSH_NOTIFICATIONS**: Enable to send push notifications. Defaults to `true` if `MATTERMOST_PUSH_SERVER` is set.
- **MATTERMOST_LINK_SALT**: Salt used to sign public image links. No defaults.
- **MATTERMOST_ENABLE_PUBLIC_LINKS**: Enable to allow public image links. Defaults to `true` if `MATTERMOST_LINK_SALT` is set.
- **MATTERMOST_ENABLE_RATE_LIMIT**: Throttle API access according to `MATTERMOST_RATE_LIMIT_QPS`, `MATTERMOST_RATE_LIMIT_SESSIONS`, `MATTERMOST_RATE_LIMIT_BY_IP` and `MATTERMOST_RATE_LIMIT_HEADERS`. Defaults to `true`.
- **MATTERMOST_RATE_LIMIT_QPS**: Queries per second allowed by rate limiter. Defaults to `10`.
- **MATTERMOST_RATE_LIMIT_SESSIONS**: Maximum number of user sessions connected determined by `MATTERMOST_RATE_LIMIT_BY_IP` and `MATTERMOST_RATE_LIMIT_HEADERS`. Defaults to `10000`.
- **MATTERMOST_RATE_LIMIT_BY_IP**: Enforce rate limit by IP address. Defaults to `true`.
- **MATTERMOST_RATE_LIMIT_HEADERS**: Enforce rate limit by the provided HTTP headers. No defaults.
- **MATTERMOST_SHOW_EMAIL**: Show user email addresses. Defaults to `true`.
- **MATTERMOST_SHOW_NAME**: Show full name of users. Defaults to `true`.
- **DB_ADAPTER**: The database type. Only supports `mysql`. Defaults to `mysql`.
- **DB_HOST**: The database server hostname. No defaults.
- **DB_PORT**: The database server port. Defaults to `3306` for mysql.
- **DB_NAME**: The database database name. Defaults to `mattermost`.
- **DB_USER**: The database database user. Defaults to `root`.
- **DB_PASS**: The database database password. Defaults to no password.
- **SMTP_HOST**: SMTP hostname. No defaults.
- **SMTP_PORT**: SMTP port. No defaults.
- **SMTP_USER**: SMTP username. No defaults.
- **SMTP_PASS**: SMTP password. No defaults.
- **SMTP_SECURITY**: SMTP connection security. Leave unset for no encryption. Supports `TLS` or `STARTTLS`. No defaults.
- **MATTERMOST_EMAIL**: The email address for the Mattermost server. Defaults to value of `SMTP_USER`, else defaults to `example@example.com`.
- **MATTERMOST_SUPPORT_EMAIL**: The email address listed for feedback or support requests. Defaults to `support@example.com`.
- **MATTERMOST_EMAIL_NOTIFICATIONS**: Send email notifications. Defaults to `true` if `SMTP_HOST` is configured.
- **MATTERMOST_EMAIL_VERIFICATION**: Enable to require email verification prior to logging in. Defaults to `true` if `SMTP_HOST` is configured.
- **GITLAB_SECRET**: GitLab API secret. No defaults.
- **GITLAB_ID**: GitLab API ID. No defaults.
- **GITLAB_SCOPE**: GitLab API scope. No defaults.
- **GITLAB_AUTH_ENDPOINT**: GitLab API authentication endpoint. No defaults.
- **GITLAB_TOKEN_ENDPOINT**: GitLab API token endpoint. No defaults.
- **GITLAB_API_ENDPOINT**: GitLab API endpoint. No defaults.
- **MATTERMOST_HTTPS**: Set to `true` to indicate that Mattermost is served over HTTPS. Defaults to `false`.

# Maintenance

## Upgrading

Mattermost releases new versions on the 16th of every month.  I will update this project shortly after a release is made.

To upgrade to newer Mattermost releases, simply follow this 4 step upgrade procedure.

- **Step 1**: Update the docker image.

```bash
docker pull jasl8r/mattermost:2.1.0
```

- **Step 2**: Stop and remove the currently running image

```bash
docker stop mattermost
docker rm mattermost
```

- **Step 3**: Create a backup

Backup your database and local file storage by your preferred backup method.  All of the necessary data is located under `/srv/docker/mattermost` if the docker volume conventions of this guide are followed.

- **Step 4**: Start the image

```bash
docker run --name mattermost -d [OPTIONS] jasl8r/mattermost:2.1.0
```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it mattermost bash
```

# References

* https://github.com/mattermost/platform
* http://docs.mattermost.com/
* https://github.com/sameersbn/docker-gitlab
