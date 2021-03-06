function precmd {
local TERMWIDTH
(( TERMWIDTH = ${COLUMNS} - 1 ))


###
# Truncate the path if it's too long.

PR_FILLBAR=""
PR_PWDLEN=""

local promptsize=${#${(%):------()--}}
local host=`hostname`
local hostpromptsize=${#host}
local pwdsize=${#${(%):-%~}}

if [[ "$promptsize + $hostpromptsize + $pwdsize" -gt $TERMWIDTH ]]; then
  ((PR_PWDLEN=$TERMWIDTH - $promptsize))
else
  PR_FILLBAR="\${(l.(($TERMWIDTH - 2 - ($promptsize + $hostpromptsize + $pwdsize)))..${PR_HBAR}.)}"
fi

}


setopt extended_glob
preexec () {
  if [[ "$TERM" == "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
  fi
}


setprompt () {
  ###
  # Need this so the prompt will work.

  setopt prompt_subst


  ###
  # See if we can use colors.

  autoload colors zsh/terminfo
  if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
  fi
  for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GREY; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
  done
  PR_NO_COLOUR="%{$terminfo[sgr0]%}"

  ###
  # Modify Git prompt
  ZSH_THEME_GIT_PROMPT_PREFIX="($PR_LIGHT_BLUE%{$reset_color%}%{$fg[green]%}"
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}$PR_BLUE)"
  ZSH_THEME_GIT_PROMPT_STATUS_PREFIX="[%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_STATUS_SUFFIX="$PR_BLUE]"
  ZSH_THEME_GIT_PROMPT_DIRTY=""
  ZSH_THEME_GIT_PROMPT_CLEAN=""
  ZSH_THEME_GIT_PROMPT_SHA_BEFORE="[%{$reset_color%}$PR_CYAN"
  ZSH_THEME_GIT_PROMPT_SHA_AFTER="$PR_BLUE]"

  ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚ "
  ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹ "
  ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖ "
  ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜ "
  ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═ "
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭ "

  ###
  # See if we can use extended characters to look nicer.

  typeset -A altchar
  set -A altchar ${(s..)terminfo[acsc]}
  PR_SET_CHARSET="%{$terminfo[enacs]%}"
  PR_SHIFT_IN="%{$terminfo[smacs]%}"
  PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
  PR_HBAR=${altchar[─]:--}
  PR_ULCORNER=${altchar[┐]:--}
  PR_LLCORNER=${altchar[└]:--}
  PR_LRCORNER=${altchar[┘]:--}
  PR_URCORNER=${altchar[┐]:--}


  ###
  # Decide if we need to set titlebar text.

  case $TERM in
    xterm*)
      PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
      ;;
    screen)
      PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
      ;;
    *)
      PR_TITLEBAR=''
      ;;
  esac


  ###
  # Decide whether to set a screen title
  if [[ "$TERM" == "screen" ]]; then
    PR_STITLE=$'%{\ekzsh\e\\%}'
  else
    PR_STITLE=''
  fi


  ###
  # Finally, the prompt.

  PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_CYAN$PR_SHIFT_IN$PR_ULCORNER$PR_HBAR$PR_SHIFT_OUT$PR_LIGHT_BLUE(\
%{$reset_color%}$PR_LIGHT_YELLOW%$PR_PWDLEN<...<%~%<<\
$PR_LIGHT_BLUE)[%M]$PR_CYAN\
$PR_SHIFT_IN$PR_HBAR$PR_HBAR${(e)PR_FILLBAR}$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_URCORNER$PR_SHIFT_OUT\

$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_HBAR$PR_SHIFT_OUT\
>$PR_NO_COLOUR '

    # display exitcode on the right when >0
  return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"
  RPROMPT=' $return_code$PR_BLUE\
$PR_BLUE\
`git_prompt_info`\
`git_prompt_short_sha`\
|$PR_SHIFT_IN$PR_CYAN$PR_HBAR$PR_LRCORNER$PR_SHIFT_OUT\
$PR_NO_COLOUR'

  PS2='$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_LIGHT_GREEN%_$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
}

setprompt
