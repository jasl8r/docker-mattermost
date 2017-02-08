# Changelog

This file only reflects the changes that are made in this image. Please refer to
the Mattermost [CHANGELOG](http://docs.mattermost.com/administration/changelog.html)
for the list of changes in Mattermost.

## 3.6.2

- mattermost 3.6.2
- add `MATTERMOST_LOG_CONSOLE_LEVEL`, `MATTERMOST_LOG_FILE_LEVEL` and
  `MATTERMOST_LOG_FILE_FORMAT`

## 3.5.1

- mattermost 3.5.1

## 3.4.0-1

- add error message to require upgrading to 3.0 or 3.1 before any higher version

## 3.4.0

- mattermost 3.4.0
- add `MATTERMOST_SITE_URL` and `MATTERMOST_ENABLE_EMAIL_BATCHING` variables
- add `MATTERMOST_WEBSERVER_MODE` variable to control static file handling
- add `MATTERMOST_ENABLE_CUSTOM_EMOJI` variable
- add `MATTERMOST_RESTRICT_DIRECT_MESSAGE` variable

## 3.1.0

- mattermost 3.1.0
- add MATTERMOST_SERVER_LOCALE, MATTERMOST_CLIENT_LOCALE and MATTERMOST_LOCALES variables
- add MATTERMOST_MAX_FILE_SIZE

## 3.0.2

- mattermost 3.0.2
- add version 3.0 migration solution, see [README](README.md) for details
- remove `MATTERMOST_TEAM_DIRECTORY`
- add `MATTERMOST_OPEN_SERVER` to enable user creation without an invite
- add `MATTERMOST_PUSH_FULL_MESSAGE` to configure push notification content
- use `MATTERMOST_EMAIL_SIGNIN` and `MATTERMOST_USERNAME_SIGNIN` variables

## 2.2.0

- mattermost 2.2.0
- change base image to alpine:3.3
- remove embedded nginx server
- add support for postgresql
- add nginx container sample

## 2.1.0

- mattermost 2.1.0
- support gitlab integration
- support most mattermost configuration parameters
