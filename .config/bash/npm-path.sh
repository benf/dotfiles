export NPM_PACKAGES="${HOME}/.local/npm-packages"
export PATH="${PATH}:${NPM_PACKAGES}/bin"
export MANPATH="${MANPATH}:${NPM_PACKAGES}/share/man"
export NODE_PATH="${NPM_PACKAGES}/lib/node_modules:$NODE_PATH"
