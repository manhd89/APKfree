#!/bin/bash

req() {
    wget --header="User-Agent: Mozilla/5.0" -nv -O "$@"
}

# Find max version
max() {
	local max=0
	while read -r v || [ -n "$v" ]; do
		if [[ ${v//[!0-9]/} -gt ${max//[!0-9]/} ]]; then max=$v; fi
	done
	if [[ $max = 0 ]]; then echo ""; else echo "$max"; fi
}

# Read highest supported versions from Revanced 
get_supported_version() {
    package_name=$1
    output=$(java -jar revanced-cli*.jar list-versions -f "$package_name" patch*.rvp)
    version=$(echo "$output" | tail -n +3 | sed 's/ (.*)//' | grep -v -w "Any" | max | xargs)
    echo "$version"
}

# Download necessary resources to patch from Github latest release 
download_resources() {
    for repo in revanced-patches revanced-cli; do
        githubApiUrl="https://api.github.com/repos/revanced/$repo/releases/latest"
        page=$(req - 2>/dev/null $githubApiUrl)
        assetUrls=$(echo $page | jq -r '.assets[] | select(.name | endswith(".asc") | not) | "\(.browser_download_url) \(.name)"')
        while read -r downloadUrl assetName; do
            req "$assetName" "$downloadUrl" 
        done <<< "$assetUrls"
    done
}

download_resources

package="com.google.android.youtube"
version="19.46.42"

url="https://androidapksfree.com/youtube/${package//./-}/old/"
version="${version:-$(get_supported_version "$package")}"
url=$(req - $url | grep -B1 "class=\"limit-line\">$version" | grep -oP 'href="\K[^"]+')
url=$(req - $url | grep 'class="buttonDownload box-shadow-mod"' | grep -oP 'href="\K[^"]+')
req youtube-v$version.apk $url
