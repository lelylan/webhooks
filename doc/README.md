## Deploy

The deploy is quite the same, but be careful to check that the worker is up and running with the command `heroku ps` or by checking your dashboard.

```bash
$ git push heroku master
$ heroku ps:scale worker=1
```

## Organization

**lib/logic.coffee**: This is the file where all the logic is grouped (together with the models). In here we take off the subscriptions related to a resource and fire the callback events.

## Foreman

As we deploy on heroku start getting used on make the app running with Foreman

## Testing

Actually, for some unknown reasons (probably nock) the test suite raises an error if we try to run all specs together. For this reason we must run just one spec per time. At the moment this is acceptable as we have few tests, but when they grow we'll have to find a solution for this problem and also have a working continuous testing system.

```bash
$ gnode spec/app.spec.coffee
```

Which stays for
```bash
$ foreman run -e .test.env node node_modules/jasmine-node/lib/jasmine-node/cli.js --autotest --coffee spec/app.spec.coffee
```

If the first time it does not work, just try once more and it should work out.

## Debug

If you want to get some useful messages on production just set the Debug env variable
```bash
heroku config:set DEBUG=true
heroku config:remove DEBUG
```

## Live Testing

To live check if the webhook system works follow the following steps. In the future we'll define a playground section where you'll be able to do all of this in a fancy way, but until that moment just take 10 minutes and do this.

- Save your client uid and client secret
   - client uid: `145bbc32465049c756109d0a2a96550b718838aedef1315368866972cc75c771`
   - client secret: `014368b9b04229f889541a2eb60ddd0cd3e24c41938d213a29d6140e9b463034`

- Create a token (preferably not expirable): `07b6b89fe289c1150169eb044d4ff369a14a13da12f313e9b88968de00f40e6`

- Create a subscription setting a requestb.in URL as callback
```bash
curl -X POST http://localhost:3004/subscriptions \
     -u uid:secret \
     -H 'Content-Type: application/json' \
     -d '{
           "resource": "types",
           "event": "created",
           "callback_uri": "http://requestb.in/u641vfu6"
         }'
```

- Run the mongo console to check if the event has been created and be sure you are using a capped collection otherwise nothing will ever start to work.
```bash
$ mongo
$ > use jobs_development (or jobs db name)
$ > db.dropDatabase();
$ > use jobs_development (or jobs db name)
$ > db.createCollection("events", {capped: true, size: 10000000, max:1000});
$ > db.events.find().sort({natural:-1})
```

If events collection exists:
```bash
$ mongo
$ > use jobs_development (or jobs db name)
$ > db.runCommand({"convertToCapped": "events", size: 10000000, max:1000});
$ > db.events.find().sort({natural:-1})
```

- Run the webhook service and remember to restart it for any change `f -e .development.env`

- Create the firing resource (type is pretty easy to do)
```bash
curl -X POST http://localhost:3002/types \
     -H 'Authorization: Bearer 07b6b89fe289c1150169eb044d4ff369a14a13da12f313e9b88968de00f40e6f' \
     -H 'Content-Type: application/json' \
     -d '{ "name": "Dimmer" }'
```

- Inspect requestb.in for the sent data
```yml
POST: /u641vfu6
HTTP: 1.1
X-Hub-Signature: 0832ef3f5f5570e4da388909edcf63a8a27531d7
Host: requestb.in
Content-Type: application/json
Content-Length: 305
Connection: keep-alive
Accept: application/json
```

Response:
```json
{"id":"509e768ad033a94d38000010","resource":"types","event":"created","data":{"uri":"http://localhost:3002/types/509e768ad033a94d3800000f","id":"509e768ad033a94d3800000f","name":"Dimmer","created_at":"2012-11-10T15:45:14Z","updated_at":"2012-11-10T15:45:14Z","properties":[],"functions":[],"statuses":[]}}
```
