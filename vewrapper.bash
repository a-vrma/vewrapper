#!/bin/bash
# -----------------------------------------------------------------------------
# Shell functions to act as wrapper for `python3 -m venv`
#
# Copyright (c) 2018 Christopher Sabater Cordero
# Copyright (c) 2018 - 2019 Aman Verma
# See LICENSE file for license details.
# -----------------------------------------------------------------------------

# Variables and helper functions
if [[ -z ${VENV_HOME} ]] || [[ ${VENV_HOME: -1} = '/' ]]; then
    echo >&2 "Please set your VENV_HOME to a valid string"
    echo >&2 "It needs to be non-empty, real (not a symlink), and not end with a slash"
    # we return non-error cause we don't want to crash the shell if -e is on
    return 0
fi

# create venv_home if it doesn't exist
mkdir -p "$VENV_HOME"

# command to use to trash venvs
VENV_rm='command trash'
# generic error message for when no environment name is given.
VENV_noenvname='Please give the name of an environment.'

acve() {
    if [[ $# -ne 1 ]]; then
        echo >&2 "$VENV_noenvname"
        return 1
    fi
    if [[ ! -d $VENV_HOME/$1 ]]; then
        echo >&2 "E: '$1' does not exist."
        return 1
    fi
    [[ -n $VIRTUAL_ENV ]] && deactivate

    source "$VENV_HOME/$1/bin/activate"
}

mkve() {
    if [[ $# -ne 1 ]]; then
        echo >&2 "$VENV_noenvname"
        return 1
    fi
    if [[ -d $VENV_HOME/$1 ]]; then
        echo >&2 "E: '$1' already exists"
        return 1
    fi
    # safer to create venvs on system python only.
    [[ -n $VIRTUAL_ENV ]] && deactivate

    python3 -m venv "$VENV_HOME/$1"
    source "$VENV_HOME/$1/bin/activate" || return 1
    # TODO: notify user of fail here and in rmve
    pip install -U pip setuptools
    echo "'$1' was created"
}

upve() {
    if [[ $# -ne 1 ]]; then
        echo >&2 "$VENV_noenvname"
        return 1
    fi
    if [[ ! -d $VENV_HOME/$1 ]]; then
        echo >&2 "E: '$1' does not exist."
        return 1
    fi
    # deactivate to make sure you are upgrading to system python.
    [[ -n $VIRTUAL_ENV ]] && deactivate

    python3 -m venv --upgrade "$VENV_HOME/$1" || return 1
    echo "'$1' was upgraded."
}

rmve() {
    if [[ $# -ne 1 ]]; then
        echo >&2 "$VENV_noenvname"
        return 1
    fi
    if [[ ! -d $VENV_HOME/$1 || $1 = '.' ]]; then
        echo >&2 "E: '$1' does not exist."
        return 1
    fi
    [[ $VIRTUAL_ENV = $VENV_HOME/$1 ]] && deactivate

    $VENV_rm "$VENV_HOME/$1" || return 1
    echo "'$1' was removed."
}

lsve() {
    # people often alias ls.
    command ls -1 "$VENV_HOME"
}
