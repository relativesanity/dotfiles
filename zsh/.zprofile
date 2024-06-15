if [[ $(arch) == 'i386' ]]; then
  eval $(/usr/local/bin/brew shellenv)
else
  eval $(/opt/homebrew/bin/brew shellenv)
fi
