#!/usr/bin/env sh

# Chmod /home/morello/workspace as morello:morello
chown morello:morello /home/morello/workspace

# Run bash to keep container alive
tail -f /dev/null
