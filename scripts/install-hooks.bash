#!/usr/bin/env bash

GIT_DIR=$(git rev-parse --git-dir)

echo 'Installing git hooks...'
ln -s ../../scripts/run-pre-push-hooks.bash $GIT_DIR/hooks/pre-push
echo 'Installed!'