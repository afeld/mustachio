To run tests:

```bash
bundle
bundle exec rake
```

To run app, you'll need credentials by signing up for an account from http://rekognition.com/.  Then run:

```bash
bundle
MUSTACHIO_REKOGNITION_KEY=... MUSTACHIO_REKOGNITION_SECRET=... bundle exec rackup
```
