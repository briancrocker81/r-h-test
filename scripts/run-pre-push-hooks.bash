#!/usr/bin/env bash

echo "Running pre-push hook"
./scripts/run-rails-tests.bash

# $? stores exit value of the last command
if [ $? -ne 0 ]; then
 echo 'Test suite is not green'
 exit 1
fi