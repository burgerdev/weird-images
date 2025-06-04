# GID

This image has unusual POSIX group memberships:
There's a user `name` and a group `name` of which the user is a member, but the primary group of `name` is `daemon`.

This image is a demo for a containerd bug.
The running process should be in groups 1 (`daemon`) and 2 (`name`), but only 1 is picked up.

