_env_init() {
  # init version manager without rehash on startup
  local SHELL_NAME="zsh"
  local init_args=(- --no-rehash zsh)
  local zshrc="$HOME/.zshrc"

  # pyenv: skip init if a venv is activated by poetry or pipenv
  if [[ -z $POETRY_ACTIVE ]] && [[ -z $PIPENV_ACTIVE ]]; then
    cache_file="${TMPDIR:-/tmp}/pyenv-cache.$UID.${SHELL_NAME}"
    if [[ "${commands[pyenv]}" -nt "$cache_file" \
      || "$zshrc" -nt "$cache_file" \
      || ! -s "$cache_file"  ]]; then

      # Cache init code.
      pyenv init "${init_args[@]}" >| "$cache_file" 2>/dev/null
    fi

    source "$cache_file"
    unset cache_file

    # pyenv-virtualenv init
    init_args=(- zsh)

    cache_file="${TMPDIR:-/tmp}/pyenv-virtualenv-cache.$UID.${SHELL_NAME}"
    if [[ "${commands[pyenv-virtualenv]}" -nt "$cache_file" \
      || "$zshrc" -nt "$cache_file" \
      || ! -s "$cache_file"  ]]; then

      pyenv virtualenv-init "${init_args[@]}" >| "$cache_file" 2>/dev/null
    fi

    source "$cache_file"

    autoload -Uz add-zsh-hook
    add-zsh-hook -D precmd _pyenv_virtualenv_hook

    unset cache_file
  fi

  unset init_args
}
