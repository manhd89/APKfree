#!/bin/bash

req() {
    wget --header="User-Agent: Mozilla/5.0" -nv -O "$@"
}

url="https://androidapksfree.com/youtube/com-google-android-youtube/old/"

url=$(req - $url | grep 'class="limit-line">19.47.53' -B1 | grep -oP 'href="\K[^"]+')
echo $url
