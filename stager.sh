#!/bin/bash

stager() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "❌ fzf not found. Install with: brew install fzf"
    return 1
  fi

  STAGED=$(git diff --cached --name-only)

  FILES=$(git status --porcelain=1 -z | while IFS= read -r -d '' line; do
    STATUS=${line:0:2}
    FILE=${line:3}

    # Skip staged files
    if echo "$STAGED" | grep -qx "$FILE"; then
      continue
    fi

    case "$STATUS" in
      " D") LABEL="[D]" ;;
      " M") LABEL="[M]" ;;
      "??") LABEL="[N]" ;;
      *) continue ;;
    esac

    echo "$LABEL $FILE"
  done)

  if [ -z "$FILES" ]; then
    echo "✅ No unstaged files to add."
    return 0
  fi

  SELECTED=$(echo "$FILES" | fzf --multi --reverse --prompt="Select files to stage: ")
  if [ -z "$SELECTED" ]; then
    echo "⚠️ No files selected."
    return 1
  fi

  echo "$SELECTED" | while read -r line; do
    FILE=$(echo "$line" | cut -d' ' -f2-)

    if [[ "$line" == "[D]"* ]]; then
      git add -u "$FILE"
    else
      git add "$FILE"
    fi

    echo "✅ Added: $FILE"
  done
}

# If the script is being run directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  stager
fi