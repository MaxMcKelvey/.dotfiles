# Set black background and white text
printf '\e]11;#000000\007'  # Black background
printf '\e]10;#ffffff\007'  # White text

# Function: smart truncation of PWD
smart_pwd() {
    local full="$PWD"
    local home="$HOME"
    local base="$(basename "$full")"
    local dir="$(dirname "$full")"

    # Replace $HOME with ~
    if [[ $full == $home* ]]; then
        dir="~${dir#$home}"
    fi

    # Truncate middle if too long (>30 chars)
    if ((${#dir} > 30)); then
        local start="${dir:0:15}"
        local end="${dir: -15}"
        dir="${start}…${end}"
    fi

    # Print path
    printf "%s/%s" "$dir" "$base"
}

# Function: get only the directory containing the active .venv
venv_dir() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        printf "%s" "$(basename "$(dirname "$VIRTUAL_ENV")")"
    fi
}

# Prompt: smart path + venv directory in yellow
export PS1='\[\e[32m\]$(smart_pwd)\[\e[0m\]\n> '

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias n='nvim'
alias c='clear'
alias ll='ls -la --color'
alias la='ls -a --color'
alias git-clean-branches='git branch --merged main | grep -v "\*" | grep -v "main" | xargs -n 1 git branch -d'

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"
