# Ghostty shell integration
if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  builtin source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi
export SNACKS_GHOSTTY=true

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

typeset -U path PATH

# XDG configuration
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Global GitIgnore
export GIT_IGNORE_FILE="$XDG_CONFIG_HOME/git/ignore"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Homebrew specifics
if command -v brew >/dev/null 2>&1; then
  # add /opt/homebrew/share/
  export XDG_DATA_DIRS="/opt/homebrew/share:${XDG_DATA_DIRS}"
  # site-functions for zsh
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
fi

# ZSH Config
autoload -U zmv
autoload -Uz compinit && compinit

# Antidote
if command -v brew >/dev/null 2>&1; then
  # ...using Homebrew version
  source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
else
  # this is the generic (linux) version
  source "$HOME/.antidote/antidote.zsh"
fi

antidote load

# vi mode
bindkey -v
bindkey "^F" vi-cmd-mode

bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

export HISTSIZE=4096
export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE
export HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# vi-mode cursor
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q'  # Block cursor
  elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]]; then
    echo -ne '\e[6 q'  # Line cursor
  fi
}
function zle-line-init {
  echo -ne '\e[6 q'  # Line cursor
}
zle -N zle-line-init
zle -N zle-keymap-select

# Set the cursor to line shape when starting Zsh
echo -ne '\e[6 q'  # Line cursor

# allow case-insensitive completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# oh my posh
eval "$(oh-my-posh init zsh --config ~/.config/theme.omp.toml)"

# Aliases
alias n=nvim
alias k=kubectl

# Volta
if command -v volta >/dev/null 2>&1; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
fi

# PyEnv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
# Miniconda 3
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

# Golang
# golang env
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"
if command -v brew >/dev/null 2>&1; then
  export GOROOT=$(brew --prefix go)/libexec
  export PATH="$GOROOT/bin:$PATH"
fi

# Rust
export CARGOPATH="$HOME/.cargo"
export PATH="$CARGOPATH/bin:$PATH"

# fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=fg:#e0def4,bg:#191724,hl:#eb6f92 --color=fg+:#e0def4,bg+:#403d52,hl+:#eb6f92 --color=info:#f6c177,prompt:#31748f,pointer:#c4a7e7 --color=marker:#c4a7e7,spinner:#f6c177,header:#524f67 --bind alt-j:down,alt-k:up'
eval "$(fzf --zsh)"

# zoxide
eval "$(zoxide init zsh)"

# local/ssh based config
if [[ -n "$SSH_CONNECTION" ]]; then
  # Load additional SSH-specific configuration
  source ~/.zshrc_ssh
else
  source ~/.zshrc_local
fi

