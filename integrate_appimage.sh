#!/bin/bash
#
# Install an AppImage into ~/.local/bin and add its desktop entry and icon
# to the user's application menu.
#
# Usage: ./integrate_appimage.sh /path/to/Application.AppImage

set -euo pipefail

LOCAL_DIR="$HOME/.local"
BIN_DIR="$LOCAL_DIR/bin"
APPS_DIR="$LOCAL_DIR/share/applications"
ICONS_DIR="$LOCAL_DIR/share/icons/hicolor"

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

warn() {
    printf 'warning: %s\n' "$*" >&2
}

usage() {
    cat <<EOF
Usage: $(basename "$0") /path/to/Application.AppImage

Copies the AppImage to $BIN_DIR (if it is not already there), then installs
its .desktop file and icon under $LOCAL_DIR/share and refreshes the desktop
database.
EOF
}

if [[ $# -eq 1 && ( $1 == "-h" || $1 == "--help" ) ]]; then
    usage
    exit 0
fi

if [[ $# -ne 1 ]]; then
    usage >&2
    exit 2
fi

source_arg=$1
[[ -f $source_arg ]] || die "not a file: $source_arg"
[[ -r $source_arg ]] || die "cannot read: $source_arg"
source_file=$(readlink -f -- "$source_arg") || die "cannot resolve: $source_arg"

app_name=$(basename -- "$source_file")
target="$BIN_DIR/$app_name"
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/appimage-install.XXXXXX")
trap 'rm -rf -- "$work_dir"' EXIT

mkdir -p "$BIN_DIR" "$APPS_DIR" "$ICONS_DIR"

# Install the AppImage first; extraction then always runs from the final path.
if [[ $source_file -ef $target ]]; then
    chmod u+x -- "$target"
else
    install -m 0755 -- "$source_file" "$target"
fi
printf 'AppImage: %s\n' "$target"

# --appimage-extract is handled by the AppImage runtime itself and does not
# need FUSE. Extract everything because the desktop file and icons can live in
# different places depending on how the AppImage was built.
if ! (cd "$work_dir" && "$target" --appimage-extract) >/dev/null; then
    die "failed to extract $app_name (is it a type 2 AppImage?)"
fi
root="$work_dir/squashfs-root"
[[ -d $root ]] || die "extraction did not produce squashfs-root"

# Find the top-level desktop file. Fall back to usr/share/applications for
# AppImages that do not follow the usual top-level layout.
desktop_files=()
while IFS= read -r -d '' file; do
    desktop_files+=("$file")
done < <(find "$root" -maxdepth 1 -type f -name '*.desktop' -print0)

if [[ ${#desktop_files[@]} -eq 0 && -d "$root/usr/share/applications" ]]; then
    while IFS= read -r -d '' file; do
        desktop_files+=("$file")
    done < <(find "$root/usr/share/applications" -maxdepth 1 -type f -name '*.desktop' -print0)
fi

[[ ${#desktop_files[@]} -gt 0 ]] || die "no .desktop file found inside $app_name"

# Prefer a desktop file whose name matches the AppImage, otherwise take the
# first one and tell the user when there was ambiguity.
desktop_file=${desktop_files[0]}
app_stem=${app_name%.AppImage}
app_stem=${app_stem%.appimage}
for file in "${desktop_files[@]}"; do
    file_stem=$(basename -- "$file" .desktop)
    if [[ ${file_stem,,} == "${app_stem,,}" ]]; then
        desktop_file=$file
        break
    fi
done

if [[ ${#desktop_files[@]} -gt 1 ]]; then
    warn "multiple .desktop files found; using $(basename -- "$desktop_file")"
fi

grep -q '^\[Desktop Entry\]' "$desktop_file" ||
    die "$(basename -- "$desktop_file") has no [Desktop Entry] section"

desktop_name=$(basename -- "$desktop_file")
desktop_dest="$APPS_DIR/$desktop_name"
desktop_stem=${desktop_name%.desktop}

# Read a key from the [Desktop Entry] group.
desktop_value() {
    local key=$1 line section=

    while IFS= read -r line || [[ -n $line ]]; do
        line=${line%$'\r'}
        if [[ $line == \[*\] ]]; then
            section=${line:1:${#line}-2}
            continue
        fi
        if [[ $section == "Desktop Entry" && $line == "$key="* ]]; then
            printf '%s\n' "${line#*=}"
            return 0
        fi
    done < "$desktop_file"

    return 1
}

# Quote one argument for the Exec key (Desktop Entry Specification, "The Exec
# key"). In particular, % is doubled because it is a field-code character.
quote_exec() {
    local value=$1 result= char i

    for ((i = 0; i < ${#value}; i++)); do
        char=${value:i:1}
        case $char in
            '\' | '"' | '`' | '$') result+="\\$char" ;;
            '%') result+='%%' ;;
            *) result+=$char ;;
        esac
    done

    printf '"%s"' "$result"
}

# Return everything in an Exec value after its first (possibly quoted) word.
strip_first_exec_arg() {
    local value=$1 i=0 len=${#1} char quote=

    while ((i < len)) && [[ ${value:i:1} == [[:space:]] ]]; do
        ((++i))
    done

    if ((i < len)) && [[ ${value:i:1} == '"' || ${value:i:1} == "'" ]]; then
        quote=${value:i:1}
        ((++i))
        while ((i < len)); do
            char=${value:i:1}
            if [[ $quote == '"' && $char == '\' ]]; then
                ((i += 2))
                continue
            fi
            ((++i))
            [[ $char == "$quote" ]] && break
        done
    else
        while ((i < len)); do
            char=${value:i:1}
            if [[ $char == '\' ]]; then
                ((i += 2))
                continue
            fi
            [[ $char == [[:space:]] ]] && break
            ((++i))
        done
    fi

    while ((i < len)) && [[ ${value:i:1} == [[:space:]] ]]; do
        ((++i))
    done

    printf '%s' "${value:i}"
}

# Locate the icon referenced by Icon=. Try the top-level icon first, then
# .DirIcon, then the icon directories inside the image.
has_icon_key=0
if desktop_value Icon >/dev/null; then
    has_icon_key=1
fi
icon_key=$(desktop_value Icon || true)
icon_key=${icon_key#"${icon_key%%[![:space:]]*}"}
icon_key=${icon_key%"${icon_key##*[![:space:]]}"}

icon_base=${icon_key##*/}
icon_stem=$icon_base
case ${icon_stem,,} in
    *.png | *.svg | *.xpm) icon_stem=${icon_stem%.*} ;;
esac
[[ -n $icon_stem ]] || icon_stem=$desktop_stem

icon_source=
if [[ $icon_key == /* && -f "$root$icon_key" ]]; then
    icon_source="$root$icon_key"
fi

if [[ -z $icon_source && -n $icon_base ]]; then
    for candidate in \
        "$root/$icon_base" \
        "$root/$icon_stem.png" \
        "$root/$icon_stem.svg" \
        "$root/$icon_stem.xpm"; do
        if [[ -f $candidate ]]; then
            icon_source=$candidate
            break
        fi
    done
fi

if [[ -z $icon_source && -f "$root/.DirIcon" ]]; then
    icon_source="$root/.DirIcon"
fi

if [[ -z $icon_source ]]; then
    # Prefer the highest-resolution file when several hicolor sizes exist.
    icon_source=$(find -L "$root/usr/share/icons" -type f \
        \( -name "$icon_stem.png" -o -name "$icon_stem.svg" -o -name "$icon_stem.xpm" \
           -o -name "$icon_base" \) \
        -print 2>/dev/null | sort -V | tail -n 1 || true)
fi

if [[ -z $icon_source ]]; then
    icon_source=$(find "$root" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.svg' -o -iname '*.xpm' \) \
        -print -quit 2>/dev/null || true)
fi

desktop_icon=
if [[ -n $icon_source ]]; then
    # Resolve .DirIcon and other symlinks so its extension and hicolor size
    # can be determined from the actual file.
    icon_source=$(readlink -f -- "$icon_source") || icon_source=

    icon_ext=
    case ${icon_source,,} in
        *.png) icon_ext=png ;;
        *.svg) icon_ext=svg ;;
        *.xpm) icon_ext=xpm ;;
    esac

    if [[ -z $icon_ext && -n $icon_source ]]; then
        case $(file -Lb --mime-type -- "$icon_source" 2>/dev/null || true) in
            image/png) icon_ext=png ;;
            image/svg+xml) icon_ext=svg ;;
            image/x-xpixmap | image/x-xpm) icon_ext=xpm ;;
        esac
    fi

    if [[ -n $icon_ext ]]; then
        if [[ $icon_source =~ /hicolor/([0-9]+x[0-9]+)/ ]]; then
            icon_size=${BASH_REMATCH[1]}
        elif [[ $icon_ext == svg ]]; then
            icon_size=scalable
        elif [[ $icon_ext == xpm ]]; then
            icon_size=48x48
        else
            # Most AppImages put a 256x256 PNG at the image root.
            icon_size=256x256
        fi

        icon_dest="$ICONS_DIR/$icon_size/apps/$icon_stem.$icon_ext"
        install -d -m 0755 -- "$ICONS_DIR/$icon_size/apps"
        install -m 0644 -- "$icon_source" "$icon_dest"
        desktop_icon=$icon_stem
        printf 'Icon: %s\n' "$icon_dest"
    else
        warn "could not determine the format of $icon_source"
    fi
else
    warn "no icon matching '${icon_key:-$icon_stem}' found; leaving Icon= unchanged"
fi

# Rewrite Exec/TryExec so the menu entry runs the installed AppImage, not the
# temporary mount path or a bare executable name. Exec lines in desktop-action
# groups are rewritten too.
rewritten="$work_dir/$desktop_name"
section=
while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}

    if [[ $line == \[*\] ]]; then
        section=${line:1:${#line}-2}
        printf '%s\n' "$line"
        if [[ $section == "Desktop Entry" && -n $desktop_icon && $has_icon_key -eq 0 ]]; then
            printf 'Icon=%s\n' "$desktop_icon"
        fi
        continue
    fi

    in_app_group=0
    if [[ $section == "Desktop Entry" || $section == "Desktop Action "* ]]; then
        in_app_group=1
    fi

    if ((in_app_group)) && [[ $line == Exec=* ]]; then
        args=$(strip_first_exec_arg "${line#Exec=}")
        printf 'Exec='
        quote_exec "$target"
        if [[ -n $args ]]; then
            printf ' %s' "$args"
        fi
        printf '\n'
    elif ((in_app_group)) && [[ $section == "Desktop Entry" && $line == TryExec=* ]]; then
        printf 'TryExec=%s\n' "$target"
    elif ((in_app_group)) && [[ $section == "Desktop Entry" && -n $desktop_icon && $line == Icon=* ]]; then
        printf 'Icon=%s\n' "$desktop_icon"
    else
        printf '%s\n' "$line"
    fi
done < "$desktop_file" > "$rewritten"

install -m 0644 -- "$rewritten" "$desktop_dest"
printf 'Desktop entry: %s\n' "$desktop_dest"

# Refresh the desktop and icon caches when the helpers are available.
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q -t -f "$ICONS_DIR" >/dev/null 2>&1 || true
fi

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    warn "$BIN_DIR is not in PATH"
fi

printf 'Desktop integration complete.\n'
