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
