#!/bin/bash
### NOTE: 使用bash而不能是sh, 否则uploadFile会有signature不匹配

# ==================== Config ====================

accessKeyId="LTAIQGvJcHdwXeeZ"
accessKeySecret=$ALI_OSS_SECRET
endpoint="oss-cn-beijing.aliyuncs.com"
bucket="focus-resource"
cloudFolder="docs/crimson-sdk"

# ================================================

declare -a result=()
encodeFilename=""

function uploadFile() {
  path="$cloudFolder/$1"

  contentType=$(file -b --mime-type "$1")
  dateValue="$(TZ=GMT env LANG=en_US.UTF-8 date +"%a, %d %b %Y %H:%M:%S GMT")"
  stringToSign="PUT\n\n$contentType\n$dateValue\n/$bucket/$path"
  signature=$(echo -en "$stringToSign" | openssl sha1 -hmac "$accessKeySecret" -binary | base64)
  log "uploadFile, $1 => $path"
  url="https://$bucket.$endpoint/$path"

  curl -i -q -X PUT -T "$1" \
      -H "Content-Type: $contentType" \
      -H "Host: $bucket.$endpoint" \
      -H "Date: $dateValue" \
      -H "Authorization: OSS $accessKeyId:$signature" \
      $url

  result+=($url)
}

function urlEncode() {
  encodeFilename=""
  local length="${#1}"
  for (( i = 0; i < length; i++ ))
  do
    local c="${1:i:1}"
    case $c in 
      [a-zA-Z0-9.~_-]) 
        encodeFilename=$encodeFilename$(printf "$c")
        ;;
      *) 
        encodeFilename=$encodeFilename$(printf "$c" | xxd -p -c1 | 
        while read x
        do 
          printf "%%%s" "$x"
        done)
    esac
  done
}

log() {
  time=$(date "+%Y-%m-%d %H:%M:%S")
  text=$1
  echo "[$time] $text"
  # echo "\033[42;30m [$time] $text \033[0m"
}

uploadFile _sidebar.md
uploadFile README.md
uploadFile index.html

uploadFile zh/_sidebar.md
uploadFile zh/overview.md
uploadFile zh/faq.md
uploadFile zh/core_function.md
uploadFile zh/README.md
uploadFile zh/android.md
uploadFile zh/ios.md
uploadFile zh/c.md
uploadFile zh/csharp.md
uploadFile zh/python.md
uploadFile zh/node_electron.md
uploadFile zh/node.md

uploadFile en/_sidebar.md
uploadFile en/overview.md
uploadFile en/faq.md
uploadFile en/README.md
uploadFile en/android.md
uploadFile en/ios.md
uploadFile en/c.md
uploadFile en/csharp.md
uploadFile en/python.md
uploadFile en/node_electron.md
uploadFile en/node.md
uploadFile en/chrome_extension.md

uploadFile flutter/headband-sdk.md

for res in "${result[@]}"; do
  log "$res"
done