Requires Ruby 2.3+.

## Running tests

```bash
bundle
bundle exec rake
```

## Running the app

1. Follow the instructions about setting up your Google Cloud Vision API credentials [here](https://github.com/afeld/face_detect#installation).
1. Run:

    ```bash
    bundle
    bundle exec unicorn -c ./config/unicorn.rb -p 3000
    open http://localhost:3000
    ```

## Production

There is a `DISABLE_API` environment variable that can be used to take the API down.

### Analytics

This information will only be relevant if you have access to the various services.

* [CloudFlare](https://www.cloudflare.com/a/analytics/mustachify.me)
* [Google Cloud Vision API](https://console.cloud.google.com/apis/api/vision.googleapis.com/usage?project=mustachio-1298&duration=PT12H)
* [Heroku](https://dashboard-preview.heroku.com/apps/mustachio/metrics/web?starting=24-hours-ago)
* [New Relic](https://rpm.newrelic.com/accounts/42891/applications/4462437)
