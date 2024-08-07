# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.8
source ~/.zsh-plugins/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

clear
pfetch

# syntax highlighting
source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# HISTORY
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.cache/zsh/history
setopt HIST_IGNORE_ALL_DUPS  # do not put duplicated command into history list
setopt HIST_SAVE_NO_DUPS  # do not save duplicated command
setopt HIST_REDUCE_BLANKS  # remove unnecessary blanks
setopt INC_APPEND_HISTORY_TIME  # append command to history file immediately after execution
setopt EXTENDED_HISTORY  # record command start time
bindkey -v
bindkey '^R' history-incremental-search-backward

# Basic auto/tab complete
CASE_SENSITIVE="false"
autoload -Uz compinit
compinit
zstyle ':completion:*' menu yes select
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
export KEYTIMEOUT=1


# Prefer vi shortcuts
DEFAULT_VI_MODE=viins
KEYTIMEOUT=1

__set_cursor() {
    local style
    case $1 in
        reset) style=0;; # The terminal emulator's default
        blink-block) style=1;;
        block) style=2;;
        blink-underline) style=3;;
        underline) style=4;;
        blink-vertical-line) style=5;;
        vertical-line) style=6;;
    esac

    [ $style -ge 0 ] && print -n -- "\e[${style} q"
}

# Set your desired cursors here...
__set_vi_mode_cursor() {
    case $KEYMAP in
        vicmd)
          __set_cursor block
          ;;
        main|viins)
          __set_cursor vertical-line
          ;;
    esac
}

__get_vi_mode() {
    local mode
    case $KEYMAP in
        vicmd)
          mode=NORMAL
          ;;
        main|viins)
          mode=INSERT
          ;;
    esac
    print -n -- $mode
}

zle-keymap-select() {
    __set_vi_mode_cursor
    zle reset-prompt
}

zle-line-init() {
    zle -K $DEFAULT_VI_MODE
}

zle -N zle-line-init
zle -N zle-keymap-select

# Optional: allows you to open the in-progress command inside of $EDITOR
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line
zle -N edit-command-line

# PROMPT_SUBST enables functions and variables to re-run everytime the prompt
# is rendered
setopt PROMPT_SUBST

# Single quotes are important so that function is not run immediately and saved
# in the variable
RPROMPT='$(__get_vi_mode)'

f() {}

# aliases
alias dev="cd /home/goncrust/Documents/dev"
alias nas="cd /mnt/goncrust-nas"
alias rm="rm -I"
alias mv="mv -v"
#alias ls="ls --color=auto"
alias ls="eza --header --color always --icons --git --group"
alias lst="ls --tree"
alias lst2="ls --tree --level=2"
alias lst3="ls --tree --level=3"
alias cd='f() { cd $1 ; ls -a };f'
alias clear="clear;pfetch;ls -a"
alias vim="nvim"
alias grep="grep --color=auto"
alias video='f() { mpv $1 & disown };f'
alias img='f() { nomacs $1 & disown };f'
alias pdf='f() { zathura $1 & disown };f'
alias rss="newsboat &"
alias prtsc="flameshot gui & disown"
alias email="thunderbird & disown"
alias md="glow"
alias fm="ranger"

# asahi (add user to video group)
alias backlight="light -s sysfs/leds/kbd_backlight -S"
alias brightness="light -s sysfs/backlight/apple-panel-bl -S"
alias volume="amixer sset Master"
