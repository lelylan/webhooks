# Webhooks

Realtime HTTP notification from Lelylan to third party apps

## Requirements

Webhooks is tested against Node 0.10.36.

## Configuration: [Documentation](doc/README.md)

## Installation

```bash
$ git clone git@github.com:lelylan/webhooks.git && cd webhooks
$ npm install && npm install -g foreman
$ nf start
```

## Install with docker

#### Badges
Docker image: [lelylanlab/webhooks](https://hub.docker.com/r/lelylanlab/webhooks/)

[![](https://images.microbadger.com/badges/version/lelylanlab/webhooks:latest.svg)](http://microbadger.com/images/lelylanlab/webhooks:latest "Get your own version badge on microbadger.com")  [![](https://images.microbadger.com/badges/image/lelylanlab/webhooks:latest.svg)](http://microbadger.com/images/lelylanlab/webhooks:latest "Get your own image badge on microbadger.com")

### Use docker hub image
```bash
$ docker run -d -it --name webhooks lelylanlab/webhooks
```

### Generate local image
```bash
$ docker build --tag=webhooks .
$ docker run -d -it --name webhooks webhooks
```

When installing the service in production set [lelylan environment variables](https://github.com/lelylan/lelylan/blob/master/README.md#production).


## Resources

* [Lelylan Realtime API](http://dev.lelylan.com/api#api-realtime)


## Contributing

Fork the repo on github and send a pull requests with topic branches.
Do not forget to provide specs to your contribution.


### Running specs

```bash
$ npm install
$ npm test
```

## Coding guidelines

Follow [Felix](http://nodeguide.com/style.html) guidelines.


## Feedback

Use the [issue tracker](http://github.com/lelylan/webhooks/issues) for bugs or [stack  overflow](http://stackoverflow.com/questions/tagged/lelylan) for questions.
[Mail](mailto:dev@lelylan.com) or [Tweet](http://twitter.com/lelylan) us for any idea that can improve the project.


## Links

* [GIT Repository](http://github.com/lelylan/webhooks)
* [Lelylan Dev Center](http://dev.lelylan.com)
* [Lelylan Site](http://lelylan.com)


## Authors

[Andrea Reginato](https://www.linkedin.com/in/andreareginato)


## Contributors

Special thanks to all [contributors](https://github.com/lelylan/webhooks/contributors)
for submitting patches.


## Changelog

See [CHANGELOG](https://github.com/lelylan/webhooks/blob/master/CHANGELOG.md)


## License

Lelylan is licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
