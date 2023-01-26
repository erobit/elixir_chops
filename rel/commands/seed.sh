#!/bin/sh
# should only ever be run initially to migrate and seed the database
# otherwise, we'll be using migrate exclusively on subsequent deploys
release_ctl eval "Store.ReleaseTasks.seed()"