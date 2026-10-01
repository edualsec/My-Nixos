#!/usr/bin/env bash
if [ -n "$1" ]; then
    cliphist decode "$1" | wl-copy
fi
