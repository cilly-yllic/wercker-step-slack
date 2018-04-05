# wercker-step-slack

## Options

- `url` The Slack webhook url
- `branch` (optional) If set, it will only notify on the given branch

## Example

```yaml
build:
    after-steps:
        - cilly/slack-notify:
            url: $SLACK_WEBHOOK_URL
            branch: master
```

## License

The MIT License (MIT)