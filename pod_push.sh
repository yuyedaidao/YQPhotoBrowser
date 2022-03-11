#!/bin/bash
while [ -n "$1" ]
do
  case "$1" in
    -m)
        echo "commit message $2"
        MESSAGE=$2
        shift
        ;;
    -t)
        echo "tag $2"
        TAG=$2
        shift
        ;;
  esac
  shift
done
git tag -d "$TAG"
git push -d origin "$TAG"
git add -A
if [ "$MESSAGE" = "" ]
then
MESSAGE="$TAG"
fi
git commit -m "$MESSAGE"
git push 
git tag "$TAG"
git push --tags
# pod lib lint
pod trunk push --allow-warnings