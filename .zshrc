# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

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

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Homebrew (site-functions for zsh)
if [[ $(command -v brew) != "" ]]; then
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
fi

# ZSH Config
autoload -U zmv
autoload -Uz compinit && compinit

# Antidote
if [[ $(command -v brew) == "" ]]; then
  source "$HOME/.antidote/antidote.zsh"
else
  source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
fi

antidote load

# vi mode
# bindkey -v
# bindkey "^F" vi-cmd-mode

# bindkey "^A" beginning-of-line
# bindkey "^E" end-of-line

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

# PyEnv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
# Miniconda 3
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

# Golang
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"

# fzf
export FZF_DEFAULT_OPTS='--layout=reverse --border --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 --bind alt-j:down,alt-k:up'
eval "$(fzf --zsh)"

# zoxide
eval "$(zoxide init zsh)"

# pfetch
if [ -f /usr/bin/pfetch ]; then
  /usr/bin/pfetch
fi
