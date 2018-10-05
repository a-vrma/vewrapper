################################################################################
#   Python Venv Wrapper
################################################################################

if [ "${VENV_HOME:-}" = "" ]
then
    export VENV_HOME="$HOME/.venv" # default
fi

# create if doesn't exist
[[ -d "$VENV_HOME" ]] || mkdir "$VENV_HOME"

echoerr() {
    # print to stderr
    printf "%s\n" "$*" >&2;
}

actvenv() {
    if [[ ! -d "$VENV_HOME/$1" ]]; then
        echoerr "E: Environment '$VENV_HOME/$1' does not contain an activate script."
        return 1
    fi

    source "$VENV_HOME/$1/bin/activate"
}

lsvenv() {
    command ls "$VENV_HOME" | tr '\n' '\0' | xargs -0 -n 1 basename 2>/dev/null
}

mkvenv() {
    if [[ -d "$VENV_HOME/$1" ]]; then
        echoerr "$1 already exists in $VENV_HOME."
        return 1
    fi
    python3 -m venv "$VENV_HOME/$1"
    source "$VENV_HOME/$1/bin/activate"
    [[ $? = 0 ]] && echo "Python venv created at $VENV_HOME/$1."
}

rmvenv() {
    if [[ ! -d "$VENV_HOME/$1" ]]; then
        echoerr "E: Environment '$VENV_HOME/$1' does not exist."
        return 1
    fi
    if [[ "$VIRTUAL_ENV" == "$VENV_HOME/$1" ]]; then
        deactivate
    fi
    rm -r "$VENV_HOME/$1"
    [[ $? = 0 ]] && echo "Python venv removed at $VENV_HOME/$1."
}
