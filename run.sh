#!/bin/sh

GIT_BRANCH_URL="https://$WERCKER_GIT_DOMAIN/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY"
GIT_COMMIT_URL="$GIT_BRANCH_URL/commits/$WERCKER_GIT_COMMIT"

WERCKER_STEP_TEMP="/tmp/$WERCKER_STEP_ID"
mkdir -p $WERCKER_STEP_TEMP

if [ -n "$WERCKER_SLACK_NOTIFY_BRANCH" ]; then
    if [ "$WERCKER_SLACK_NOTIFY_BRANCH" != "$WERCKER_GIT_BRANCH" ]; then
        return 0
    fi
fi

if [ -z "$WERCKER_SLACK_NOTIFY_URL" ]; then
  fail "URL is Required Property"
fi

if [ -n "$DEPLOY" ]; then
  ACTION="deploy ($WERCKER_DEPLOYTARGET_NAME)"
  ACTION_URL=$WERCKER_DEPLOY_URL
else
  ACTION="build"
  ACTION_URL=$WERCKER_BUILD_URL
fi

USER="\n user: $WERCKER_STARTED_BY \n"
if [ -z "$WERCKER_STARTED_BY" ]; then
  USER=""
fi

ACTION_LINK="<$ACTION_URL|$ACTION>"
APPLICATION_LINK="<$WERCKER_RUN_URL|$WERCKER_APPLICATION_NAME>"
GIT_BRANCH_LINK="<$GIT_BRANCH_URL|$WERCKER_GIT_BRANCH>"
GIT_COMMIT_LINK="<$GIT_COMMIT_URL|$WERCKER_GIT_COMMIT>"

MESSAGE="
$ACTION_LINK for $APPLICATION_LINK $USER
result: $WERCKER_RESULT
branch: $GIT_BRANCH_LINK
commit: $GIT_COMMIT_LINK
"

FALLBACK="
$ACTION for $WERCKER_APPLICATION_NAME　$USER
result: $WERCKER_RESULT
branch: $WERCKER_GIT_BRANCH
commit: $WERCKER_GIT_COMMIT
"

COLOR="good"

if [ "$WERCKER_RESULT" = "failed" ]; then
  MESSAGE="$MESSAGE \n step: $WERCKER_FAILED_STEP_DISPLAY_NAME"
  FALLBACK="$FALLBACK \n step: $WERCKER_FAILED_STEP_DISPLAY_NAME"
  COLOR="danger"
fi

json="{
    \"attachments\":[
      {
        \"fallback\": \"$FALLBACK\",
        \"text\": \"$MESSAGE\",
        \"color\": \"$COLOR\"
      }
    ]
}"

RESULT=$(curl -d "payload=$json" -s "$WERCKER_SLACK_NOTIFY_URL" --output "$WERCKER_STEP_TEMP"/result.txt -w "%{http_code}")
cat "$WERCKER_STEP_TEMP/result.txt"

if [ "$RESULT" = "500" ] || [ "$RESULT" = "404" ] ; then
  fail "No token is specified."
fi