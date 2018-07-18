#!/usr/bin/env bash
#
# The script for visualizing the list of changes to apt packages that need to be updated.
#
# Options:
# -l    use `less` for each package
#
# Usage:
# ./changelog.sh [-l]
#
# Version: 1.0.0
#
# Copyright (C) 2018, Vadim Kulagin
#
# This software is licensed under the MIT license.
# See the LICENSE file for details.
#
# https://github.com/VadimKulagin/apt-changelog

[ "$1" = "-l" ] && USE_LESS="1" || USE_LESS=""

REPLACER='?'
LIST=$(apt list --upgradable 2>/dev/null | tail -n +2 | tr " " "$REPLACER")

for LINE in $LIST; do
    LINE=$(echo "$LINE" | tr "$REPLACER" " ")

    echo "$LINE"

    if [ -z "$LINE" ]; then
        echo "Error: empty line. List: $LIST"
        exit 1
    fi


    PKG=$(echo "$LINE" | grep -oP '^(.+)(?=\/)')


    CUR_VER=$(echo "$LINE" | grep -oP '(?<=\: )\d.+(?=\]$)')
    echo "Current version: $CUR_VER"
    IS_FULL_VERSION=1


    if [ -n "$PKG" ] && [ -n "$CUR_VER" ]; then

        # Use "apt-get" instead of "apt" for compatibility with debian 8
        CHANGELOG="$(apt-get changelog "$PKG" 2>/dev/null | tail -n +2)"


        # If the original version string was not found in the changelog
        # then we cut out the distro-specific tail from the version string.
        if ! echo "$CHANGELOG" | grep -q "$CUR_VER"; then
            CUR_VER="$(echo $CUR_VER | grep -oiP '\d.+(?=ubuntu.*)')"
            echo "Short current version: $CUR_VER"
            IS_FULL_VERSION=0
        fi


        LOG=''


        if [ -n "$CUR_VER" ]; then

            if echo "$CHANGELOG" | grep -q "$CUR_VER"; then
                if [ "$IS_FULL_VERSION" = 1 ]; then
                    LOG=$(echo "$CHANGELOG" | sed "/($CUR_VER)/q")
                else
                    LOG=$(echo "$CHANGELOG" | sed "/($CUR_VER/q")
                fi
            else
                # If the version string was not found in the changelog
                # then we cut out the last part of the version string.
                # And then we scan changelog in reverse order for
                # grabbing all lines after the first occurrence
                # of the version string.
                # And finally we reverse the result back to the original order.
                CUR_VER="$(echo $CUR_VER | grep -oP '.+(?=[.-].+)')"
                echo "Very short current version: $CUR_VER"
                LOG="$(echo "$CHANGELOG" | tac | sed "1,/$CUR_VER/d" | tac)"
            fi
        fi


        if [ "$USE_LESS" ]; then
            echo "$LOG" | less
        else
            echo "$LOG"
            printf "\n=====================================================\n\n"
        fi
    fi
done