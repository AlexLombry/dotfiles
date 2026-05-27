# Tmux Helpers

tm() {
    SESSION="StarK"

    WORK_DIR="$HOME/ManoMano"

    tmux kill-session -t $SESSION 2>/dev/null

    tmux new-session -d -s $SESSION -n 'Dotfiles'
    tmux send-keys -t $SESSION:1 "cd $HOME/dotfiles && ll" Enter

    tmux new-window -t $SESSION:2 -n 'ManoMano'
    tmux split-window -h -t $SESSION:2.1
    tmux split-window -v -t $SESSION:2.2
    tmux send-keys -t $SESSION:2 "cd $WORK_DIR && ll" Enter

    tmux new-window -t $SESSION:3 -n 'Code'
    tmux send-keys -t $SESSION:3 "cd $HOME/code && ll" Enter

    tmux new-window -t $SESSION:4 -n 'Custom'
    tmux send-keys -t $SESSION:4 "cd $HOME/Desktop && ll" Enter

    # Attach the session
    tmux attach-session -t $SESSION
}
