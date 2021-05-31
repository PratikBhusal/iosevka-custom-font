#!/usr/bin/env sh

# Setup Base Font {{{

# Check for dist/ folder reuse {{{
if [ -d dist/ ]; then
    echo "Base Iosevka compile dist folder already exists."
    printf "Delete folder and re-compile? Saying no re-uses folder. (y/N): "
    read -r confirmation

    if [ "$confirmation" ] && echo "$confirmation" | grep -E '^[Yy]$' > /dev/null; then
        echo "Deleting compiled base Iosevka fonts"
        \rm -rf dist/

    fi
fi
# Check for dist/ folder reuse }}}

# Compile Base Iosevka Font {{{
if [ ! -d dist/ ]; then

    printf "Please specify the version you wish to compile (no input will use latest version): "
    read -r version

    if [  -z "$version" ]; then
        docker run -it -v "$(pwd)":/build avivace/iosevka-build ttf::iosevka-custom
    else
        docker run -e FONT_VERSION="$version" -it -v "$(pwd)":/build avivace/iosevka-build ttf::iosevka-custom
    fi

fi
# Compile Base Iosevka Font }}}

# Setup Base Font }}}

# Copy wanted fonts {{{
cp dist/iosevka-custom/ttf/iosevka-custom-regular.ttf .
cp dist/iosevka-custom/ttf/iosevka-custom-bold.ttf .
cp dist/iosevka-custom/ttf/iosevka-custom-italic.ttf .
# Copy wanted fonts }}}

# Download nerd-font-patcher if necessary {{{
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

/src/glyphs/
EOF

git checkout
# Download nerd-font-patcher if necessary }}}

# Apply nerd-font-patcher {{{
for style in regular bold italic; do
    ./font-patcher             \
        --windows              \
        --progressbars         \
        --fontawesome          \
        --fontawesomeextension \
        --fontlogos            \
        --octicons             \
        ../iosevka-custom-$style.ttf
done
# Apply nerd-font-patcher }}}

# Move fonts to user font directory {{{
mv -i \
    "Iosevka Nerd Font Plus Font Awesome Plus Font Awesome Extension Plus Octicons Plus Font Logos (Font Linux) Windows Compatible.ttf" \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/fonts/TTF/iosevka-custom-nerd-fonts-regular.ttf

mv -i \
    "Iosevka Bold Nerd Font Plus Font Awesome Plus Font Awesome Extension Plus Octicons Plus Font Logos (Font Linux) Windows Compatible.ttf" \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/fonts/TTF/iosevka-custom-nerd-fonts-bold.ttf

mv -i \
    "Iosevka Italic Nerd Font Plus Font Awesome Plus Font Awesome Extension Plus Octicons Plus Font Logos (Font Linux) Windows Compatible.ttf" \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/fonts/TTF/iosevka-custom-nerd-fonts-italic.ttf
# Move fonts to user font directory }}}
