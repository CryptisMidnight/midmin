# name: Midlite
# Based on agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for FISH
#
# In order for this theme to render correctly, you will need a
# [PL or Nerd font](https://gist.github.com/1595572)(https://www.nerdfonts.com/font-downloads).

## Set this options in your config.fish (if you want to :])
set -g theme_display_user yes
# set -g theme_hide_hostname yes
# set -g theme_hide_hostname no
# set -g default_user your_normal_user
# set -g theme_svn_prompt_enabled yes

set -g current_bg NONE
set hard_space \u2060
set icon_root \uf484
set icon_home \uf7db
set icon_arrow \uf739\u3000
set prompt_text \uf739

set -q scm_prompt_blacklist; or set scm_prompt_blacklist
# style suggestions \ue0b0 \ue0c8 \ue0cc \ue0c6 \ue0c4 \ue0c0
set segment_separator \ue0b0
set dir_sep \u0020\ue0b1\u00a0
set segment_splitter \ue0b1
set right_segment_separator \ue0b0

# ===========================
# Color setting

# You can set these variables in config.fish like:
# set -g drct_bg_clr red
# If not set, default color will be used.
# ===========================

set -q lct_tx_clr; or set lct_tx_clr yellow
set -q ssh_lct_tx_clr; or set ssh_lct_tx_clr cyan
set -q arrw_tx_clr; or set arrw_tx_clr purple
set -q drct_tx_clr; or set drct_tx_clr yellow
set -q hg_chng_tx_clr; or set hg_chng_tx_clr brblue
set -q hg_tx_clr; or set hg_tx_clr blue
set -q gt_drt_tx_clr; or set gt_drt_tx_clr cyan
set -q gt_tx_clr; or set gt_tx_clr bryellow
set -q svn_tx_clr; or set svn_tx_clr blue
set -q bd_tx_clr; or set bd_tx_clr red
set -q gd_tx_clr; or set gd_tx_clr brgreen
set -q spr_tx_clr; or set spr_tx_clr yellow
set -q jbs_tx_clr; or set jbs_tx_clr cyan
set -q prvt_tx_clr; or set prvt_tx_clr purple

# ===========================
# Git settings

# You can set these variables in config.fish like:
# set -g __fish_git_prompt_char_untrackedfiles " "
# If not set, the defaults will be used.
# ===========================

set -q __fish_git_prompt_char_stateseparator; or set __fish_git_prompt_char_stateseparator \u0020\u0020
set -q __fish_git_prompt_char_upstream_ahead; or set __fish_git_prompt_char_upstream_ahead \uf062\u0020
set -q __fish_git_prompt_char_upstream_behind; or set __fish_git_prompt_char_upstream_behind \uf063\u0020
set -q __fish_git_prompt_char_upstream_prefix; or set __fish_git_prompt_char_upstream_prefix ""
set -q __fish_git_prompt_char_stagedstate; or set __fish_git_prompt_char_stagedstate \uf417\u0020
set -q __fish_git_prompt_char_dirtystate; or set __fish_git_prompt_char_dirtystate \ue20e\u0020
set -q __fish_git_prompt_char_untrackedfiles; or set __fish_git_prompt_char_untrackedfiles \uf721\u0020
set -q __fish_git_prompt_char_conflictedstate; or set __fish_git_prompt_char_conflictedstate \ue269\u0020
set -q __fish_git_prompt_char_cleanstate; or set __fish_git_prompt_char_cleanstate \uf09b\u0020

# ===========================
# Configure __fish_git_prompt

set -g __fish_git_prompt_showdirtystate true
#set -g __fish_git_prompt_show_informative_status 
set -g __fish_git_prompt_showuntrackedfiles true
#set -g __fish_git_prompt_showupstream "informative"

# ===========================
# Subversion settings

set -q theme_svn_prompt_enabled; or set theme_svn_prompt_enabled no

# ===========================
# Helper methods
# ===========================

function parse_git_dirty
  if [ $__fish_git_prompt_showdirtystate = true ]
    set git_dirty (command git status --porcelain)
    if [ -n "$git_dirty" ]
        echo -n "$__fish_git_prompt_char_dirtystate"
    else
        echo -n "$__fish_git_prompt_char_cleanstate"
    end
  end
end

function cwd_in_scm_blacklist
  for entry in $scm_prompt_blacklist
    pwd | grep "^$entry" -
  end
end

# ===========================
# Theme components
# ===========================

#function prompt_loct -d "switches at and ssh"
#  if [ "$SSH_TTY" = "" ]
#    prompt_segment $lct_bg_clr $lct_tx_clr \uf1fa
#  else
#    prompt_segment $ssh_lct_bg_clr $ssh_lct_tx_clr \uf502\u0020
#  end
#end
#
#function prompt_host -d "Set current hostname"
#  set -g HOST (uname -n)
#  prompt_segment $hst_bg_clr $hst_tx_clr $HOST
#end

function prompt_dir -d "Display the current directory"
  set_color $drct_tx_clr
  echo -n -s " " (string trim (string join "$dir_sep" (string split '/' (string replace -r '^\/$' "$icon_root$hard_space" (string replace -r '^\/(.+?)' "$icon_root/\$1" (string replace -r '^\~' "$icon_home$hard_space" (string trim (basename (prompt_pwd)))))))))
end


function prompt_hg -d "Display mercurial state"
  set -l branch
  set -l state
  if command hg id >/dev/null 2>&1
      set branch (command hg id -b)
      # We use `hg bookmarks` as opposed to `hg id -B` because it marks
      # currently active bookmark with an asterisk. We use `sed` to isolate it.
      set bookmark (hg bookmarks | sed -nr 's/^.*\*\ +\b(\w*)\ +.*$/:\1/p')
      set state (hg_get_state)
      set revision (command hg id -n)
      set branch_symbol \uE0A0
      set prompt_text "$branch_symbol $branch$bookmark:$revision"
      if [ "$state" = "0" ]
          set_color $hg_chng_tx_clr
          echo -n -s $prompt_text " ±"
      else
          set_color $hg_tx_clr
          echo -n -s $prompt_text
      end
  end
end

function hg_get_state -d "Get mercurial working directory state"
  if hg status | grep --quiet -e "^[A|M|R|!|?]"
    echo 0
  else
    echo 1
  end
end


function prompt_git -d "Display the current git state"
  set -l ref
  set -l dirty
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set dirty (parse_git_dirty)
    set ref (command git symbolic-ref HEAD 2> /dev/null)
    if [ $status -gt 0 ]
      set -l branch (command git show-ref --head -s --abbrev |head -n1 2> /dev/null)
      set ref "➦ $branch "
    end
    set branch_symbol \ue0a0
    set -l branch (string join " $segment_splitter " (string split '/' (echo $ref | sed  "s-refs/heads/-$branch_symbol -")))
    if [ "$dirty" = "$__fish_git_prompt_char_dirtystate" ]
      set_color $gt_drt_tx_clr
      echo -n -s " $branch $dirty"
    else
      set_color $gt_tx_clr
      echo -n -s " $branch $dirty"
    end
  end
end


function prompt_svn -d "Display the current svn state"
  set -l ref
  if command svn info >/dev/null 2>&1
    set_color $svn_tx_clr
    set branch (svn_get_branch)
    set branch_symbol \uE0A0
    set revision (svn_get_revision)
    echo -n -s "$branch_symbol $branch:$revision"
  end
end

function svn_get_branch -d "get the current branch name"
  svn info 2> /dev/null | awk -F/ \
      '/^URL:/ { \
        for (i=0; i<=NF; i++) { \
          if ($i == "branches" || $i == "tags" ) { \
            print $(i+1); \
            break;\
          }; \
          if ($i == "trunk") { print $i; break; } \
        } \
      }'
end

function svn_get_revision -d "get the current revision number"
  svn info 2> /dev/null | sed -n 's/Revision:\ //p'
end

function prompt_status -d "the symbols for a non zero exit status, root and background jobs"
    if [ $RETVAL -ne 0 ]
      set_color $bd_tx_clr
      echo -n -s \u0020\ue231\u0020
    else
      set_color $gd_tx_clr
      echo -n -s \u0020\ue23a\u0020
    end

    if [ "$fish_private_mode" ]
      set_color $prvt_tx_clr
      pecho -n -s \u0020\uf023\u0020
    end

    # if superuser (uid == 0)
    set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
      set_color $spr_tx_clr
      echo -n -s \u0020\uf0e7\u0020
    end

    # Jobs display
    if [ (jobs -l | wc -l) -gt 0 ]
      set_color $jbs_tx_clr
      echo -n -s \u0020\uf013\u0020
    end
end

function prompt_arrow
  set_color $arrw_tx_clr
  echo -n $icon_arrow
end

# ===========================
# Apply theme
# ===========================

function fish_prompt
  set -g RETVAL $status
  #prompt_os
  #prompt_virtual_env
  #prompt_user
  #prompt_loct
  #prompt_host
  prompt_dir
  if [ (cwd_in_scm_blacklist | wc -c) -eq 0 ]
    type -q hg;  and prompt_hg
    type -q git; and prompt_git
    if [ "$theme_svn_prompt_enabled" = "yes" ]
      type -q svn; and prompt_svn
    end
  end
  prompt_status
  #prompt_finish\
  prompt_arrow
  #prompt_finish
end
