# wercker-step-slack

## Options

- `url` The 'Slack Incoming Webhook' url
- `channel` (optional) If set, it will sent to target channel
- `icon_url` (optional) default is what you set in slack 'Slack Incoming Webhook' 'Customize Icon'
- `branch` (optional) If set, it will only notify on the given branch
- `head_fields` (optional) If set, add attachment field
- `tail_fields` (optional) If set, add attachment field

## Example

```yaml

HEAD_FIELDS="
{
  \"title\": \"Title 1\",
  \"value\": \"Value 1\"
},
{
  \"title\": \"Title 2\",
  \"value\": \"Value 2\"
}
"

```

```yaml
build:
    after-steps:
        - cilly/slack-notify:
            url: $SLACK_WEBHOOK_URL
            channel: "#hoge"
            branch: master
            head_fields: $HEAD_FIELDS
```

## License

The MIT License (MIT)