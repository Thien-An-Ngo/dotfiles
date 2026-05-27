# --- Tmux autostart (WSL) ---
# Attach to existing "main" session or create a new one.
# Skips if already inside tmux or running non-interactively.
if [ -z "$TMUX" ] && [ -t 0 ] && [ "$TERM_PROGRAM" != "vscode" ]; then
    exec tmux new-session -A -s main
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git pyenv)

fpath+=~/.zfunc
autoload -Uz compinit && compinit

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias cd="z"

agy() {
  local AG_EXE="/mnt/c/Users/Labor-Client18/AppData/Local/Programs/Antigravity/bin/antigravity"
  # This flag is critical for the 2026 'mirrored' networking
  "$AG_EXE" --remote wsl+"$WSL_DISTRO_NAME" "$(readlink -f "${1:-.}")"
}

autoload -U bashcompinit
bashcompinit

eval "$(register-python-argcomplete pipx)"


# Created by `pipx` on 2026-02-19 09:51:48
export PATH="$PATH:/home/labor-client18/.local/bin"
export PATH="/home/labor-client18/.lando/bin:$PATH"; #landopath

# run agent system
export devteam="/home/labor-client18/workspace/dev_team.sh"

#nvim
export PATH="$PATH:/opt/nvim/"

# bun completions
[ -s "/home/labor-client18/.bun/_bun" ] && source "/home/labor-client18/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.cargo/bin:$PATH"


# ============================================================
# WSL SETUP — Pastel Powerline (from wsl_setup/SETUP.md)
# ============================================================

# --- Better tool defaults (install: see SETUP.md) ---
command -v lsd  &>/dev/null && alias ls='lsd'
command -v lsd  &>/dev/null && alias ll='lsd -la'
command -v lsd  &>/dev/null && alias lt='lsd --tree'
command -v bat  &>/dev/null && alias cat='bat'
command -v rg   &>/dev/null && alias grep='rg'
command -v fd   &>/dev/null && alias find='fd'
command -v btop &>/dev/null && alias top='btop'
command -v dust &>/dev/null && alias du='dust'
command -v procs &>/dev/null && alias ps='procs'

# --- Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- Tmux shortcuts ---
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux ls'
alias tk='tmux kill-session -t'

# --- Quick config edits ---
alias zshrc='${EDITOR:-nvim} ~/.zshrc'
alias nanorc='nano ~/.nanorc'
alias vimrc='${EDITOR:-nvim} ~/.config/nvim/init.lua'
alias tmuxrc='${EDITOR:-nvim} ~/.tmux.conf'

# --- Git shortcuts (additive — Oh My Zsh git plugin covers some) ---
alias g='git'
alias glog='git log --oneline --graph --decorate'

# --- WSL clipboard ---
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command Get-Clipboard'

# --- misc shortcuts ---
alias ff=fastfetch

# --- FZF integration (Dracula/pastel colour scheme) ---
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f'
export FZF_DEFAULT_OPTS='
  --color=fg:#f8f8f2,bg:#21222c,hl:#9A348E
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#DA627D
  --color=info:#FCA17D,prompt:#DA627D,pointer:#9A348E
  --color=marker:#86BBD8,spinner:#FCA17D,header:#6272a4
  --height 40% --border --reverse
'
# Ctrl+R: fuzzy history  Ctrl+T: fuzzy file  Alt+C: fuzzy cd
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && \
  source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && \
  source /usr/share/doc/fzf/examples/completion.zsh

export ENCORE_INSTALL="/home/labor-client18/.encore"
export PATH="$ENCORE_INSTALL/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# setup copy file
fclip() {
    cat "$1" | clip.exe
}
export PATH="$PATH:/opt/mssql-tools18/bin"


export PATH="$PATH:/mnt/c/Users/Labor-Client18/AppData/Local/Programs/cursor/resources/app/bin"
export PATH="$HOME/.thefuck-env/bin:$PATH"
eval "$(~/.thefuck-env/bin/thefuck --alias fuck)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# OpenClaw Completion
source "/home/labor-client18/.openclaw/completions/openclaw.zsh"

# Machine-local secrets and overrides — never committed (see ~/.zshrc.local)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
