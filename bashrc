shopt -s histappend

export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.bash_eternal_history

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PROMPT_DIRTRIM=2

#coloring
function restore() {
  if [ "$PS1" != "$PROMPT" ]; then
    PS1=$PROMPT
    PROMPT_COMMAND=""
  fi
}
PROMPT_COMMAND=restore

if [ -z "$IN_NIX_SHELL" ]; then
  PROMPT="\[\e[40;0;37m\][\u@\h:\w\$(parse_git_branch)]$ \[\e[40;0;37m\]"
else
  if [ "$IN_NIX_SHELL" = impure ]; then
    PROMPT="\[\e[40;0;33m\][nix-shell:\w$(parse_git_branch)]$ \[\e[40;0;37m\]"
  else
    PROMPT="\[\e[40;0;32m\][nix-shell:\w$(parse_git_branch)]$ \[\e[40;0;37m\]"
  fi
fi
export PS1=$PROMPT

#binding utilities
bind -m emacs-standard '"\er": redraw-current-line'
bind -m vi-command '"\C-z": emacs-editing-mode'
bind -m vi-insert '"\C-z": emacs-editing-mode'
bind -m emacs-standard '"\C-z": vi-editing-mode'

#rebinding "clear"
bind -x '"\C-l": clear'

#fzf helper
__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ,${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

#file selection
__fzf_select__() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) --preview 'bat {}' -m "$@" | while read -r item; do
    printf '%q ' "$item"
  done
  echo
}
fzf-file-widget() {
  local selected="$(__fzf_select__)"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}
bind -x '"\C-t": fzf-file-widget'

#C-p: editing files
stty lnext undef
fzfEdit() { $EDITOR $(__fzf_select__); }
fzfEdit() { $VISUAL $(__fzf_select__); }
bind -x '"\C-p": fzfEdit'

__fzf_history__() {
  local output
  output=$(
    builtin fc -lnr -2147483648 |
      last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e 'BEGIN { getc; $/ = "\n\t"; $HISTCMD = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCMD - $. . "\t$_" if !$seen{$_}++' |
      FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS +m --read0" $(__fzfcmd) --query "$READLINE_LINE"
  ) || return
  READLINE_LINE=${output#*$'\t'}
  if [ -z "$READLINE_POINT" ]; then
    echo "$READLINE_LINE"
  else
    READLINE_POINT=0x7fffffff
  fi
}
bind -x '"\C-r": __fzf_history__'

#C-v: fzf jumping
alias fzf-jump=cd
_fuzzyJump_ () {
    local cmd dir
    if [ "$PWD" == "$HOME" ]
    then
        cmd="fasd -dl | grep home";
    else
        cmd="command find -L . -mindepth 1 \
          \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o \
          -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
          -o -type d -print 2> /dev/null | cut -b3-"
    fi
    dir=$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)
    printf 'fzf-jump %q' "$dir"
}
bind -m emacs-standard '"\C-v": " \C-b\C-k \C-u`_fuzzyJump_`\e\C-e\er\C-m\C-y\C-a\e \C-y\ey\C-x\C-x\C-d"'
bind -m vi-command '"\C-v": "\C-z\C-v\C-z"'
bind -m vi-insert '"\C-v": "\C-z\C-v\C-z"'

#C-s: insert nix-shell
stty stop undef
_insertNixShell_ () {
    printf 'nix-shell'
}
bind -m emacs-standard '"\C-s": " \C-b\C-k \C-u`_insertNixShell_`\e\C-e\er\C-m\C-y\C-a\e \C-y\ey\C-x\C-x\C-d"'
bind -m vi-command '"\C-s": "\C-z\C-s\C-z"'
bind -m vi-insert '"\C-s": "\C-z\C-s\C-z"'

#C-n: jumping
nnn-jump ()
{
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, remove the "export" as in:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # NOTE: NNN_TMPFILE is fixed, should not be modified
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    nnn -x -c "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}
bind -m emacs-standard '"\C-n": " \C-b\C-k \C-unnn-jump\e\C-e\er\C-m\C-y\C-a\e \C-y\ey\C-x\C-x\C-d"'
bind -m vi-command '"\C-n": "\C-z\C-n\C-z"'
bind -m vi-insert '"\C-n": "\C-z\C-n\C-z"'

#C-a: cd backwards
back-jump () {
    cd ..;
}
bind -m emacs-standard '"\C-h": " \C-b\C-k \C-uback-jump\e\C-e\er\C-m\C-y\C-a\e \C-y\ey\C-x\C-x\C-d"'
bind -m vi-command '"\C-h": "\C-z\C-h\C-z"'
bind -m vi-insert '"\C-h": "\C-z\C-h\C-z"'

if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi
