#!/usr/bin/env bash
#
# The script for visualizing the list of changes to apt packages that need to be updated.
#
# Usage:
# ./changelog.sh [-d] [-l] [PACKAGE]...
#
# Options:
# -d        Do not show a description for each package (can increase performance)
# -l        Use `less` to display the changelog of each package
# PACKAGE   A package name. Can be specified several names separated by a space
#
# Version: 1.0.4
#
# Copyright (C) 2018, Vadim Kulagin
#
# This software is licensed under the MIT license.
# See the LICENSE file for details.
#
# https://github.com/VadimKulagin/apt-changelog

# Main parameters
USE_LESS=''
SHOW_DESCRIPTION='1'
SPECIFIED_PACKAGES=()

for ARG in "$@"; do
    case "$ARG" in
        '-l') USE_LESS='1' ;;
        '-d') SHOW_DESCRIPTION='' ;;
        *) SPECIFIED_PACKAGES+=("$ARG")
    esac
done

REPLACER='?'
LIST=$(apt list --upgradable 2>/dev/null | tail -n +2 | tr " " "$REPLACER")

for LINE in ${LIST}; do
    LINE=$(echo "$LINE" | tr "$REPLACER" " ")

    if [ -z "$LINE" ]; then
        echo "Error: empty line. List: $LIST"
        exit 1
    fi

    PKG=$(echo "$LINE" | grep -oP '^(.+)(?=\/)')

    # If the packages were specified.
    if [ -n "$SPECIFIED_PACKAGES" ]; then
        if ! [[ " ${SPECIFIED_PACKAGES[@]} " =~ " $PKG " ]]; then
            # If the current package was not specified, then we skip it.
            continue
        fi
    fi

    # Show the line with the name of the package, its new and old versions.
    echo "$LINE"

    # Display a brief description of the package, if necessary.
    if [ "$SHOW_DESCRIPTION" = '1' ]; then
        echo "$(apt show "$PKG" 2>/dev/null | grep -E '^Description: ')"
    fi

    CUR_VER=$(echo "$LINE" | grep -oP '(?<=\: )\d.+(?=\]$)')
    echo "Current version: $CUR_VER"
    IS_FULL_VERSION=1

    if [ -n "$PKG" ] && [ -n "$CUR_VER" ]; then

        # Use "apt-get" instead of "apt" for compatibility with debian 8
        CHANGELOG="$(apt-get changelog "$PKG" 2>/dev/null | tail -n +2)"
        LOG=''

        # If the original version string was not found in the changelog
        # then we cut out the distro-specific tail from the version string.
        if ! (echo "$CHANGELOG" 2>/dev/null | grep -q "$CUR_VER"); then
            CUR_VER="$(echo ${CUR_VER} | grep -oiP '\d.+(?=(?:[+]|ubuntu).*)')"
            echo "Short current version: $CUR_VER"
            IS_FULL_VERSION=0
        fi

        for i in 1 2; do
            if [ -n "$CUR_VER" ]; then
                if ! (echo "$CHANGELOG" 2>/dev/null | grep -q "$CUR_VER"); then
                    # If the version string was not found in the changelog
                    # then we cut out the last part of the version string.
                    CUR_VER="$(echo ${CUR_VER} | grep -oP '.+(?=[.\-\+].+)')"
                    echo "Very short current version: $CUR_VER"
                else
                    break
                fi
            fi
        done

        # We scan the changelog in the reverse order for
        # grabbing all the lines after the first occurrence
        # of the version string.
        # And finally we reverse the result back to the original order.
        LOG="$(echo "$CHANGELOG" | tac | sed "1,/$CUR_VER/d" | tac)"

        echo ''

        if [ "$USE_LESS" ]; then
            echo "$LOG" | less
        else
            echo "$LOG"
            printf "\n=====================================================\n\n"
        fi
    fi
done
