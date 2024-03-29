# wp-recover

Clone a remote Wordpress and use for local staging environment.

## Background

Some very nice friends of mine have a Wordpress deployed through a cloud provider.

## Purpose

The purpose of this project is to backup that Wordpress instance with all of its data and use it to create a local staging environment.

This will allow my friends to stage changes and upgrades, and give them more freedom to change providers if they choose.

![General diagram of functionality](./docs/diagram/diagram.svg)

## Comments

This project will use as few advanced tools as possible to maximize it's compatibility with Windows and Macintosh.

I may end up incorporating this procedure into other projects (with appropriate adjustments).

## Requirements

**Software:**

- BASh
- GNU Make
- Docker / Compose

*Run the following commands to grant your user access to the* `docker` *command (Linux, Mac):*

```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Ignored Data:**

You need several of the list below to run this successfully. They're ignored from Git, so they must be given to you by someone who has the data if you intend to use the code in this repository successfully.

- `.env`
- `.my.cnf`
- `.notes`
- `_site/`
- `.ssh/`
- `backups-mysql/`
- `backups-wp/`

**Note:** this has not been tested on Windows or Mac. Mac compatibility might require a few tweaks but I'm currently uncertain if Windows will work at all, even PowerShell, given the difference of path naming conventions.

## How to Use

```bash
make init

# this currently requires repeated password input for multiple server logins -- working on it
make server-backup

make containers-stage
make containers-up
make db-update-links
```

Visit `localhost` in your browser.

I recommend doing so in a private tab because of strange WordPress caching stuff that I haven't fully resolved.

From there, you can do experiments, such as installations and updates otherwise risky on the live site.

If you break something and want to start fresh, or you want to work with a newer backup you made, just delete the containers and restage.

```bash
# this will stop and remove the container
make containers-down
make containers-stage
make db-update-links
```

To stop the containers without removing them: `make containers-stop`.

### Restoring other versions

You can specify an alternative backup with `make containers-stage`. First, figure out what backup you want to restore by running `make versions-list`. It will output timestamps like so:

```
2022-12-11_15-53
2023-01-01_16-39
2023-01-01_16-58
2023-01-01_17-09
```

Decide the date of the backup you want to use and pass it to `make containers-stage`. For example: `make containers-stage VERSION=2023-01-01_16-58`.

## Useability problem

The traditional backup requires multiple SSH logins and the server has a password. It's annoying to sit and watch output just so that when the next login occurs, you're there to enter the server password again.

- **Chosen solution:** this repository now contains an Ansible playbook and assets to log into the server without manual password input. **Drawback**: you have to install Ansible, an additional dependency.

- **Alternate solution:** configure SSH to use automatically use the login password on connection attempt. **Forbidden:** SSH does not permit a password configuration option. An additional **drawback** would accompany this solution anyway: it would require changes to the user's computer and also move the organization's assets outide of the project directory.

- **Alternate solution:** gather all remote assets into a directory and update the current back-up procedure to send all of them at once, update the remote paths to pair a complete backup (a WP and MySQL backup with the same timestamp), and retrieve the backups recursively. **Drawbacks:** This would involve the time-consuming task of changing and testing already-stable technology. It would also only reduce the amount of logins to three, not completely eliminate having to log in multiple times.
