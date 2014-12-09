# this theme is original.

# solarized_color_chart
# base03  : 234 background
# base02  : 235 background highlights
# base01  : 240 comments /secondary content
# base00  : 241
# base0   : 244 body text / default code / primary content
# base1   : 245 optional emphasized content
# base2   : 254
# base3   : 230
# yellow  : 136
# orange  : 166
# red     : 160
# magenta : 125
# violet  : 61
# blue    : 33
# cyan    : 37
# green   : 64

USER_NAME='%F{64}%n%f'
HOST_NAME='%F{64}%m%f'
CURRENT_DIRECTORY='%F{33}%~%f'
SEPARATOR1='%F{244}@%f'
SEPARATOR2='%F{244}:%f'
PROMPT_CHAR='%F{245}%# %f'
TIME='%F{240}[%*]%f'

# git
autoload -Uz VCS_INFO_get_data_git; VCS_INFO_get_data_git 2> /dev/null

function prompt-git-current-branch {
        local name st color gitdir action
        if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
                return
        fi

        name=`git rev-parse --abbrev-ref=loose HEAD 2> /dev/null`
        if [[ -z $name ]]; then
                return
        fi

        gitdir=`git rev-parse --git-dir 2> /dev/null`
        action=`VCS_INFO_git_getaction "$gitdir"` && action="($action)"

	if [[ -e "$gitdir/rprompt-nostatus" ]]; then
		echo "$name$action "
		return
	fi

  st=`git status 2> /dev/null`
	if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
		color=%F{64}
	elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
		color=%F{136}
	elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
    color=%B%F{160}
  else
    color=%F{160}
  fi

  echo " ( $color$name$action%f )"
}

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

# メインの表示
PROMPT=%K{235}'${USER_NAME}${SEPARATOR1}${HOST_NAME}${SEPARATOR2}${CURRENT_DIRECTORY}$(prompt-git-current-branch)%E%k
%F{245}$PROMPT_CHAR'
RPROMPT='${TIME}'
