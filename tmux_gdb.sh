GDB=${GDB:-'gdb'}

function tmux_outer() {
    tmux new -sdevs -ndevw -- ./tmux_gdb.sh "$@"
}

function tmux_inner() {
    tmux splitw -dh
    tmux splitw -dh
    tmux select-layout even-horizontal
    tmux killp -t1
    tmux splitw -dv
    tmux splitw -dh
    tmux swapp -s0 -t2
    tmux resizep -t2 -D
    tmux resizep -t2 -D
    tmux resizep -t2 -D
    tmux selectp -t2
    local tty0=`tmux display -t0 -p '#{pane_tty}'`
    local tty1=`tmux display -t1 -p '#{pane_tty}'`
    local tty3=`tmux display -t3 -p '#{pane_tty}'`
    $GDB -ex "dashboard -output $tty3" -ex "dashboard source -output $tty0" -ex "dashboard assembly -output $tty1" "$@"
    tmux killp -a
}

function main() {
    if [[ -n $TMUX ]]; then
        tmux_inner "$@"
    else
        tmux_outer "$@"
    fi
}
main "$@"
