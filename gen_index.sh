#!/bin/bash

set -eu

# urlencode : return urlencoded string via printf
urlencode () {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%s' "$c" | xxd -p -c1 |
                   while read c; do printf '%%%s' "$c"; done ;;
        esac
    done
}

get_sites () {
    local shortcut_file=$1
    local sites_csv=""
    while IFS=',' read -r name shortcut url
    do
        sites_csv="${sites_csv},${name}"
    done < ${shortcut_file} 
    # remove first comma
    sites_csv="${sites_csv:1}"
    echo "${sites_csv}"
}

# create_links : create link from csv
create_links () {
    local shortcut_file=$1
    local links=""
    while IFS="," read -r name shortcut url
    do
        # urlencode strings
        local name_enc=$(urlencode "${name}")
        local url_enc=$(urlencode "${url}")
        local link="alfred://customsearch/${name_enc}/${shortcut}/utf8/nospace/${url_enc}"
        links="${links},${link}"
    done < ${shortcut_file}
    links="${links:1}"
    echo "${links}"
}

# generate_index_html : generate index file using vars
generate_index_html () {
    general_sites=$(get_sites "./shortcuts.csv")
    general_links=$(create_links "./shortcuts.csv")
    SITES=${general_sites} GENERATED_LINKS=${general_links} erb index.html.erb
}

echo "generate links from csv"
echo "$(generate_index_html)" > index.html

