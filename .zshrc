# Initialize Starship prompt if installed
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    echo "Starship not found. Install with: curl -sS https://starship.rs/install.sh | sh"
fi

# History Configuration
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS

# Initialize zinit with error handling
ZINIT_HOME="${HOME}/.zinit"
if [[ ! -f ${ZINIT_HOME}/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing zinit…%f"
    command mkdir -p "${ZINIT_HOME}"
    command git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}/bin" || {
        print -P "%F{160}Failed to clone zinit. Please check your internet connection.%f"
        return 1
    }
fi
source "${ZINIT_HOME}/bin/zinit.zsh"

# Enhanced Fish-like autosuggestions configuration
zinit ice wait lucid atload'!_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_USE_ASYNC=true
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
export ZSH_AUTOSUGGEST_COMPLETION_IGNORE="git *;ssh *"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080,bold"

# Load essential plugins
zinit wait lucid for \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-syntax-highlighting \
    zsh-users/zsh-history-substring-search \
    zsh-users/zsh-completions \
    MichaelAquilina/zsh-you-should-use \
    agkozak/zsh-z \
    hlissner/zsh-autopair

# Enhanced completion system
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Fish-like completion styles
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:commands' rehash 1
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %d'
zstyle ':completion:*:corrections' format '%F{green}%d (errors: %e)%f'

# Modern CLI tool aliases with existence checks
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never --style=numbers,changes,header'
    export BAT_THEME="Dracula"
fi

if command -v lsd &> /dev/null; then
    alias ls='lsd --group-dirs first'
    alias ll='lsd -l --group-dirs first'
    alias la='lsd -la --group-dirs first'
    alias lt='lsd --tree'
    alias lta='lsd --tree -a'
    alias ltd='lsd --tree --depth'
    alias lsize='lsd -l --total-size'
    alias lsort='lsd -l --total-size --sort size'
    alias ldate='lsd -l --total-size --sort date'
    alias lext='lsd -l --total-size --sort extension'
fi

if command -v rg &> /dev/null; then
    alias grep='rg --smart-case'
fi

if command -v fd &> /dev/null; then
    alias find='fd'
fi

if command -v btop &> /dev/null; then
    alias top='btop'
fi

# Git aliases with emoji indicators
alias g='git'
alias gst='echo "📊" && git status -sb'
alias ga='echo "➕" && git add'
alias gaa='echo "📦" && git add --all'
alias gc='echo "💾" && git commit'
alias gcm='echo "📝" && git commit -m'
alias gp='echo "⬆️" && git push'
alias gl='echo "⬇️" && git pull'
alias gd='echo "👀" && git diff --color'
alias gco='echo "🔄" && git checkout'
alias gcom='git checkout main'
alias glog='echo "📜" && git log --oneline --decorate --graph --color'
alias gbr='git branch'
alias gf='git fetch --all'

# Docker aliases with status checks
if command -v docker &> /dev/null; then
    alias d='docker'
    alias dps='echo "🐳" && docker ps'
    alias dpsa='docker ps -a'
    alias dimg='echo "📦" && docker images'
    alias drm='docker rm'
    alias drmi='docker rmi'
    alias dcup='echo "🚀" && docker-compose up -d'
    alias dcdown='echo "🔽" && docker-compose down'
fi

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Enhanced Functions
function extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1"     ;;
            *.tar.gz)  tar xzf "$1"     ;;
            *.bz2)     bunzip2 "$1"     ;;
            *.rar)     unrar x "$1"     ;;
            *.gz)      gunzip "$1"      ;;
            *.tar)     tar xf "$1"      ;;
            *.tbz2)    tar xjf "$1"     ;;
            *.tgz)     tar xzf "$1"     ;;
            *.zip)     unzip "$1"       ;;
            *.Z)       uncompress "$1"  ;;
            *.7z)      7z x "$1"        ;;
            *)        echo "❌ Cannot extract '$1': unrecognized file extension" ;;
        esac
    else
        echo "❌ '$1' is not a valid file"
    fi
}

function mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

# Enhanced project creation function
function project() {
    if [[ -z "$1" ]]; then
        echo "❌ Please provide a project name"
        return 1
    fi
    
    local proj_dir="$1"
    mkdir -p "${proj_dir}"/{src,docs,tests,config}
    cd "${proj_dir}" || return 1
    
    # Initialize git with main branch
    git init -b main
    
    # Create comprehensive README
    cat > README.md << EOF
# ${proj_dir}

## Project Structure
📁 \`src/\`: Source code
📚 \`docs/\`: Documentation
🧪 \`tests/\`: Test suite
⚙️ \`config/\`: Configuration files

## Getting Started
1. Clone this repository
2. [Add your setup instructions here]
3. [Add your usage instructions here]

## Contributing
[Add contribution guidelines here]

## License
[Add license information here]
EOF
    
    # Create initial .gitignore
    cat > .gitignore << EOF
# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/
.idea/
*.swp
*.swo

# Dependencies
node_modules/
vendor/

# Build output
dist/
build/
*.log
EOF
    
    if command -v code &> /dev/null; then
        code .
    fi
    echo "🎉 Project ${proj_dir} created successfully!"
}

# Enhanced note-taking function
function note() {
    local note_dir="${HOME}/notes"
    local date=$(date +%Y-%m-%d)
    local time=$(date +%H:%M)
    local note_file="${note_dir}/${date}.md"
    
    mkdir -p "${note_dir}"
    
    if [[ ! -f "${note_file}" ]]; then
        echo "# Notes for ${date}" > "${note_file}"
        echo "" >> "${note_file}"
    fi
    
    echo "## ${time} - $(date +%A)" >> "${note_file}"
    echo "$*" >> "${note_file}"
    echo "✍️ Note added to ${note_file}"
}

# FZF Configuration with improved aesthetics
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_OPTS="
        --height 60% 
        --layout=reverse 
        --border rounded 
        --preview 'bat --color=always --style=numbers {}' 
        --preview-window=right:60%:wrap 
        --marker='✓' 
        --pointer='▶' 
        --prompt='🔍 '
    "
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    
    [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
fi

# Environment Variables
export EDITOR='vim'
export VISUAL='vim'
export MANPAGER='bat -l man -p'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color

# Enhanced Key Bindings (Fish-like)
bindkey '^ ' autosuggest-accept     # Ctrl+Space to accept suggestion
bindkey '^[[C' autosuggest-accept   # Right arrow to accept suggestion
bindkey '^f' autosuggest-accept     # Ctrl+F to accept suggestion (Fish-like)
bindkey '^n' autosuggest-next       # Ctrl+N to get next suggestion
bindkey '^p' autosuggest-previous   # Ctrl+P to get previous suggestion
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^R' history-incremental-search-backward
bindkey '^[[Z' reverse-menu-complete
bindkey '^P' up-history
bindkey '^N' down-history

# Additional Zsh Options
setopt AUTO_CD              # Change directory without cd
setopt AUTO_PUSHD          # Make cd push old directory onto directory stack
setopt PUSHD_IGNORE_DUPS   # Don't push multiple copies of same directory onto stack
setopt PUSHD_SILENT        # Don't print directory stack after pushd or popd
setopt CORRECT             # Spell check commands
setopt EXTENDED_GLOB       # Use extended globbing syntax
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell

# NVM Configuration with lazy loading
export NVM_DIR="${HOME}/.nvm"
if [[ -d "${NVM_DIR}" ]]; then
    export NVM_LAZY_LOAD=true
    export NVM_COMPLETION=true
    [[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
    [[ -s "${NVM_DIR}/bash_completion" ]] && source "${NVM_DIR}/bash_completion"
fi

# Load local configurations if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Final setup message
echo "🚀 Zsh configuration loaded successfully!"
