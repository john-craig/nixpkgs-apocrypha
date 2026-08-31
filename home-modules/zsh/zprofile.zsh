# ~/.zprofile

if [[ -f /etc/environment ]]; then
  source /etc/environment
fi

[[ -f ~/.zshrc ]] && . ~/.zshrc
