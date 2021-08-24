#!/bin/sh
# Configure "Tree Style Tabs" Firefox plugin

die() {
    echo >&2 "$*"
    exit 1
}

prompt() {
    while :
    do
        read -p "$* (Y/n) " response
        case $response in
        [yY]*|'') return 0 ;;
        [nN]*)    return 1 ;;
        esac
    done
}

ffdir=$HOME/.mozilla/firefox
profiles=$ffdir/profiles.ini
[ -f "$profiles" ] ||
    die "Missing required file: $profiles"

# REVIEW: Is this always the corect thing to look for?
default=$ffdir/`awk -F= '
    $0 == "Name=default-default" { x = 1 }
    x && $1 == "Path" { print $2; exit }
' "$profiles"`
[ "$default" = "$ffdir/" ] &&
    die "Missing required pattern in $profiles: Name=default-default"

# REVIEW: Is this actually required to exist beforehand?
prefs=$default/prefs.js
[ -f "$prefs" ] ||
    die "Missing required file: $prefs"

# XXX: Only required for changing prefs.
pid=`pgrep firefox`
if [ "$pid" ]; then
    prompt "Kill firefox ($pid) to make config changes?" &&
        kill $pid ||
        die 'Cannot make config changes without killing firefox'
fi

# REVIEW: Why not just back up an existing file?
chrome=$default/chrome/userChrome.css
if [ -f "$chrome" ]
then prompt "Overwrite existing $chrome?" || die 'Aborting'
else mkdir -p "$default/chrome"
fi
cat >"$chrome" <<EOF
/* https://support.mozilla.org/en-US/questions/1297983 */
#main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
  opacity: 0;
  pointer-events: none;
}
#main-window:not([tabsintitlebar="true"]) #TabsToolbar {
    visibility: collapse !important;
}
/* https://www.reddit.com/r/FirefoxCSS/comments/97j48f/remove_border_from_tree_style_tab_panel/ */
.sidebar-splitter { display: none; }
EOF

# REVIEW: What about writing to user.js?
ed <<EOF
e $prefs
/user_pref("toolkit.legacyUserProfileCustomizations.stylesheets"/
s/,.*/, true);/
w
q
EOF

# REVIEW: Is there a more portable way to do this?
if [ "$pid" ] then
    firefox &
    bg %1
    disown %1
fi
