Requires Ruby 2.x. To run tests:

```bash
bundle
bundle exec rake
```

To run app, you'll need credentials by signing up for an account from http://rekognition.com/.  Then run:

```bash
bundle
MUSTACHIO_REKOGNITION_KEY=... MUSTACHIO_REKOGNITION_SECRET=... bundle exec unicorn -c ./config/unicorn.rb -p 3000
open http://localhost:3000
```
