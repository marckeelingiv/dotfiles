# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
alias supabase='npx supabase'

# Prefer uv for interactive Python workflows.
alias python='uv run python'
alias python3='uv run python'
alias py='uv run python'
alias pip='uv pip'
alias pip3='uv pip'
alias venv='uv venv'
alias uvr='uv run'
alias uvs='uv sync'

workon() {
  if [[ -f .venv/bin/activate ]]; then
    source .venv/bin/activate
  else
    echo "No .venv found in $(pwd). Run: uv venv"
    return 1
  fi
}
