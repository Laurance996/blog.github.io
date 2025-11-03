#!/usr/bin/env bash
 
base_url=https://sm.ms/api/v2
post_path=upload
token=eY8YLlwVV0kzcLDLx55RTdVX2Y0CLxqR
 
##################################
 
post_img_path="$base_url/$post_path"
 
function postimg(){
    if [ "$token"x == ""x ]; then
        curl $post_img_path -F "smfile=@$upload_file" -s
    else
        curl $post_img_path -H "Authorization: $token" \
            -F "smfile=@$upload_file" -s
    fi
}
function echoUrl(){
    if [ "$json_v"x == ""x ]; then
        return
    fi
    imageUrl=`echo "$json_v" |jq -r '.images'`
    if [ "$imageUrl"x == "null"x -o "$imageUrl"x == ""x ]; then
        imageUrl=`echo "$json_v" |jq -r '.data|.url'`
    fi
    if [ "$imageUrl"x != "null"x -a "$imageUrl"x != ""x ]; then
        echo "[$upload_file] remote url: [$imageUrl]"
    else
        echo "post image:[$upload_file] error info: "
        echo "$json_v"
    fi
}
 
for arg in "$@"; do 
    upload_file=$arg
    if [ ! -f "$upload_file" ]; then
        continue
    fi
 
    json_v=`postimg`
    # 使用 jq 格式化输出 url
    # 如果未安装 jq 则直接输出整个信息
    which "jq" >/dev/null 2>&1
    if [ ! $? -eq 0 ]; then
        echo "$json_v"
    else
        echoUrl
    fi
done
