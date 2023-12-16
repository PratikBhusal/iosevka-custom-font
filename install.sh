#!/usr/bin/env sh

if ! [ -x "$(command -v git)" ]; then
    echo 'Error! Please install git' >&2
    exit 1
fi

if ! [ -x "$(command -v  docker)" ]; then
    echo "Error! Please install docker to compile Iosevka font"
    exit 2
fi

if ! [ -x "$(command -v  fontforge)" ]; then
    echo "Error! Please install fontforge to utilize nerdfont patches"
    exit 3
fi

# Setup Base Font {{{

# Check for dist/ folder reuse {{{
if [ -d dist/ ]; then
    echo "Base Iosevka compile dist folder already exists."
    printf "Delete folder and re-compile? Saying no re-uses folder. (y/N): "
    read -r confirmation

    if [ "$confirmation" ] && echo "$confirmation" | grep -E '^[Yy]$' > /dev/null; then
        echo "Deleting compiled base Iosevka fonts"
        \rm -rf dist/ || exit

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
/bin/scripts/name_parser/FontnameParser.py
/bin/scripts/name_parser/FontnameTools.py
EOF

git checkout
# Download nerd-font-patcher if necessary }}}

# Apply nerd-font-patcher {{{
for style in regular bold italic; do
    ./font-patcher       \
        --makegroups 6   \
        --progressbars   \
        --fontawesome    \
        --fontawesomeext \
        --fontlogos      \
        --octicons       \
        --material       \
        ../iosevka-custom-$style.ttf
done
# Apply nerd-font-patcher }}}

# Move fonts to user font directory {{{
mv -i \
    "IosevkaNerdFontPlusFontAwesomePlusFontAwesomeExtensionPlusOcticonsPlusFontLogosPlusMaterialDesignIcons-Regular.ttf" \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/fonts/TTF/iosevka-custom-nerd-fonts-regular.ttf

mv -i \
    "IosevkaNerdFontPlusFontAwesomePlusFontAwesomeExtensionPlusOcticonsPlusFontLogosPlusMaterialDesignIcons-Bold.ttf" \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/fonts/TTF/iosevka-custom-nerd-fonts-bold.ttf

mv -i \
    "IosevkaNerdFontPlusFontAwesomePlusFontAwesomeExtensionPlusOcticonsPlusFontLogosPlusMaterialDesignIcons-Italic.ttf" \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/fonts/TTF/iosevka-custom-nerd-fonts-italic.ttf
# Move fonts to user font directory }}}
