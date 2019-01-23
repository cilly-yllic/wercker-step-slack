#!/bin/sh

FOOTER="<https://github.com/cilly-yllic/wercker-step-slack|cilly/slack-notify>"
DATE=$(date +%s)

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

FALLBACK="
$ACTION for $WERCKER_APPLICATION_NAME　$USER
result: $WERCKER_RESULT
branch: $WERCKER_GIT_BRANCH
commit: $WERCKER_GIT_COMMIT
"

COLOR="good"

RESULT=$WERCKER_RESULT
if [ "$WERCKER_RESULT" = "failed" ]; then
  RESULT="$RESULT \n step: $WERCKER_FAILED_STEP_DISPLAY_NAME"
  FALLBACK="$FALLBACK \n step: $WERCKER_FAILED_STEP_DISPLAY_NAME"
  COLOR="danger"
fi

json="{
    \"channel\": \"$WERCKER_SLACK_NOTIFY_CHANNEL\",
    \"attachments\":[
      {
        \"fallback\": \"$FALLBACK\",
        \"author_name\": \"$WERCKER_STARTED_BY\",
        \"fields\": [
          {
            \"title\": \"Type\",
            \"value\": \"$ACTION_LINK\",
          },
          {
            \"title\": \"Application\",
            \"value\": \"$APPLICATION_LINK\",
          },
          {
            \"title\": \"Result\",
            \"value\": \"$RESULT\",
          },
          {
            \"title\": \"Branch\",
            \"value\": \"$GIT_BRANCH_LINK\",
          },
          {
            \"title\": \"Commit\",
            \"value\": \"$GIT_COMMIT_LINK\",
          }
        ],
        \"color\": \"$COLOR\",
        \"footer\": \"$FOOTER\",
        \"ts\": \"$DATE\"
      }
    ]
}"

RESULT=$(curl -d "payload=$json" -s "$WERCKER_SLACK_NOTIFY_URL" --output "$WERCKER_STEP_TEMP"/result.txt -w "%{http_code}")
cat "$WERCKER_STEP_TEMP/result.txt"

if [ "$RESULT" = "500" ] || [ "$RESULT" = "404" ] ; then
  fail "No token is specified."
fi