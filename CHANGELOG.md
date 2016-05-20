# Changelog

This file only reflects the changes that are made in this image. Please refer to
the Mattermost [CHANGELOG](http://docs.mattermost.com/administration/changelog.html)
for the list of changes in Mattermost.

## 3.0.2

- mattermost 3.0.2
- add version 3.0 migration solution, see [README](README.md) for details
- remove `MATTERMOST_TEAM_DIRECTORY`
- add `MATTERMOST_OPEN_SERVER` to enable user creation without an invite
- add `MATTERMOST_PUSH_FULL_MESSAGE` to configure push notification content

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
