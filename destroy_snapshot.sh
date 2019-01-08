#!/bin/sh

[ -n "$DO_TOKEN" ] && DO_TOKEN_TEMP="$DO_TOKEN"
[ -z "$DO_TOKEN" ] && echo "Digital Ocean Token not found. Enter here: " && read DO_TOKEN_TEMP
echo "======================================================================="
echo "Using: $DO_TOKEN_TEMP" 
echo "======================================================================="
echo "(exporting to DO_TOKEN for future caching)"
export DO_TOKEN="$DO_TOKEN_TEMP"

echo ""
echo "Making requests to retrieve snapshot ID"
SNAPSHOT=`curl -s -X GET -H 'Content-Type: application/json' -H "Authorization: Bearer $DO_TOKEN_TEMP" "https://api.digitalocean.com/v2/snapshots?page=1&per_page=1&resource_type=droplet" | jq -r '.snapshots[0].id'`

NAME=`curl -s -X GET -H 'Content-Type: application/json' -H "Authorization: Bearer $DO_TOKEN_TEMP" "https://api.digitalocean.com/v2/snapshots?page=1&per_page=1&resource_type=droplet" | jq -r '.snapshots[0].name'`
echo "Deleting snapshot: $NAME [$SNAPSHOT]"

curl -X DELETE -H 'Content-Type: application/json' -H "Authorization: Bearer $DO_TOKEN_TEMP" "https://api.digitalocean.com/v2/snapshots/$SNAPSHOT"
echo ""
