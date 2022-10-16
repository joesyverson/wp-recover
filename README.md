# wp-recover

Clone a remote Wordpress and use for local staging environment.

## Background

Some very nice friends of mine have a Wordpress deployed through a cloud provider.

## Purpose

The purpose of this project is to backup that Wordpress instance with all of its data and use it to create a local staging environment.

This will allow my friends to stage changes and upgrades, and give them more freedom to change providers if they choose.

## Comments

This project will use as few advanced tools as possible to maximize it's compatibility with Windows and Macintosh.

I may end up incorporating this procedure into other projects (with appropriate adjustments).

## Requirements

**Software:**

- BASh
- GNU Make
- Docker
- Docker Compose

**Data:**

- `.env`
- `.ssh/`

Note: this has not been tested on Windows or Mac. Mac compatibility might require a few tweaks but I'm currently uncertain if Windows will work at all, even PowerShell, given the difference of path naming conventions.

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

To stop the containers without removing them: `make containers-stop`
