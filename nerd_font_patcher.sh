#!/usr/bin/env sh

git clone                                       \
    --filter=blob:none                          \
    --no-checkout                               \
    --depth 1                                   \
    https://github.com/ryanoasis/nerd-fonts.git \
    nerd-font-patcher
cd nerd-font-patcher && git sparse-checkout init

# Ignore everything by default. Follow the same syntax as ".gitignore" files
cat > .git/info/sparse-checkout << EOF
!/*

/readme.md
/font-patcher

/images/

/src/config.sample.json
/src/glyphs/
EOF

git checkout
