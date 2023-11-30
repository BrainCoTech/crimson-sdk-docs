#!/bin/bash
### NOTE: 使用bash而不能是sh, 否则uploadFile会有signature不匹配

# ==================== Config ====================

accessKeyId="LTAI5tFNW3QivvhSM1U2zWSy"
accessKeySecret=$ALI_OSS_SECRET_HZ
endpoint="oss-cn-hangzhou.aliyuncs.com"
bucket="brainco-hz-com"
cloudFolder="docs/crimson-sdk"

# ================================================

declare -a result=()
encodeFilename=""

function uploadFile() {
  path="$cloudFolder/$2"

  contentType=$(file -b --mime-type "$1")
  # Fix: js, css文件contentType返回text/plain
  if [[ "$1" == *.js ]]; then
    contentType="text/javascript"
  elif [[ "$1" == *.css ]]; then
    contentType="text/css"
  fi
  dateValue="$(TZ=GMT env LANG=en_US.UTF-8 date +"%a, %d %b %Y %H:%M:%S GMT")"
  stringToSign="PUT\n\n$contentType\n$dateValue\n/$bucket/$path"
  signature=$(echo -en "$stringToSign" | openssl sha1 -hmac "$accessKeySecret" -binary | base64)
  log "uploadFile, $1 => $path"
  # return
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
  for ((i = 0; i < length; i++)); do
    local c="${1:i:1}"
    case $c in
    [a-zA-Z0-9.~_-])
      encodeFilename=$encodeFilename$(printf "$c")
      ;;
    *)
      encodeFilename=$encodeFilename$(printf "$c" | xxd -p -c1 |
        while read x; do
          printf "%%%s" "$x"
        done)
      ;;
    esac
  done
}

log() {
  time=$(date "+%Y-%m-%d %H:%M:%S")
  text=$1
  echo "[$time] $text"
  # echo "\033[42;30m [$time] $text \033[0m"
}

directory="./docs/.vuepress/dist"

# 遍历指定目录下的所有文件
find "$directory" -type f ! -name ".DS_Store" | while read -r file; do
  relative_path="${file#$directory/}" # 去掉目录前缀部分
  # echo "Processing file: $file $relative_path"
  uploadFile $file $relative_path
  # break
done

log "done"