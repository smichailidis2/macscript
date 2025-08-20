# Create (or reuse) a tmux session with two panes (left: fastfetch+prompt, right: btop).

# Make Homebrew tools discoverable (for GUI/launchd shells)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

SESSION="auto"
TMUX_BIN="$(command -v tmux || echo /opt/homebrew/bin/tmux)"
FASTFETCH_BIN="$(command -v fastfetch || echo /opt/homebrew/bin/fastfetch)"
BTOP_BIN="$(command -v btop || echo /opt/homebrew/bin/btop)"

if [ ! -x "$TMUX_BIN" ]; then
  echo "Error: tmux not found. Install with: brew install tmux"; exit 1
fi

# Create session + layout only once
if ! "$TMUX_BIN" has-session -t "$SESSION" 2>/dev/null; then
  "$TMUX_BIN" new-session -d -s "$SESSION"

  # LEFT pane (pane 0): clear and show fastfetch once (ignore error if not installed)
  "$TMUX_BIN" send-keys -t "$SESSION":0.0 'clear' C-m
  "$TMUX_BIN" send-keys -t "$SESSION":0.0 "$FASTFETCH_BIN || true" C-m

  # Split vertically (creates RIGHT pane = 1)
  "$TMUX_BIN" split-window -h -t "$SESSION":0

  # RIGHT pane: run btop (if missing, print message instead of failing)
  "$TMUX_BIN" send-keys -t "$SESSION":0.1 "$BTOP_BIN || echo \"Install btop with: brew install btop\"" C-m

  # Optionally widen the right pane a bit
  "$TMUX_BIN" resize-pane -t "$SESSION":0.1 -R 10

  # Return focus to LEFT pane for typing
  "$TMUX_BIN" select-pane -t "$SESSION":0.0
fi

exec "$TMUX_BIN" attach -t "$SESSION"

