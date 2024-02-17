# pi-server ansible playbook

This is a set of ansible roles I've written to automate my raspberry-pi server
setup and installation so it can survive bad sdcards and make it easy to spin
a new pi-server in another location.

The reason for this is not to have a full-fledged generic playbook for all use
cases but to quickly set-up my use cases. I also work on this on waves, so it's
possible that there's times with lots of updates followed by years of not even
looking at it until I have to run it again and find out that's broken.

All roles are fairly self-explanatory and I manage to run all of them even on a
raspberry pi zero 2 at the time of initial commit. The rclone_backup role
requires the docker-backup script in this same git repo and all the extra files
it's missing.

The variables replaced by placeholders with "\<CHANGEME\>" are often secrets and
it's suggested to be stored in a vault somewhere and replaced.

Use at your own risk.
