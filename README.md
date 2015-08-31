resin-config-inject
-------------------

[![npm version](https://badge.fury.io/js/resin-config-inject.svg)](http://badge.fury.io/js/resin-config-inject)
[![dependencies](https://david-dm.org/resin-io/resin-config-inject.png)](https://david-dm.org/resin-io/resin-config-inject.png)
[![Build Status](https://travis-ci.org/resin-io/resin-config-inject.svg?branch=master)](https://travis-ci.org/resin-io/resin-config-inject)
[![Build status](https://ci.appveyor.com/api/projects/status/x9b8mvs318nm6b1i?svg=true)](https://ci.appveyor.com/project/jviotti/resin-config-inject)

**DEPRECATED in favor of https://github.com/resin-io/resin-image-fs**

Resin.io config.json injection.

Installation
------------

Install `resin-config-inject` by running:

```sh
$ npm install --save resin-config-inject
```

Documentation
-------------

### inject.write(String image, Object config, Partition partition, Function callback)

Write a config object to an image.

See the [Partition Definition section](https://github.com/resin-io/resin-config-inject#partition-definition) for more information about the partition parameter.

The callback gets passed one argument: `(error)`.

Example:

```coffee
inject.write 'path/to/rpi.img', hello: 'world', 3, (error) ->
	throw error if error?
```

### inject.read(String image, Partition partition, Function callback)

Read a config object from an image.

See the [Partition Definition section](https://github.com/resin-io/resin-config-inject#partition-definition) for more information about the partition parameter.

The callback gets passed two arguments: `(error, config)`.

Example:

```coffee
inject.read 'path/to/rpi.img', '4:1', (error, config) ->
	throw error if error?
	console.log(config)
```

### inject.writePartition(String image, Object config, Partition partition, Function callback)

Write a config object to a partition, and return a `ReadableStream` of the partition.

The callback gets passed two arguments: `(error, stream)`.

The partition is extracted into a temporary file. Once the returned stream emits
the `close` event, the temporary file is removed.

Example:

```coffee
inject.writePartition 'path/to/rpi.img', hello: 'world', '4:1', (error, stream) ->
	throw error if error?
	stream.pipe(anotherStream)
```

Partition Definition
--------------------

A partition definition is a number or string representing the primary partition number, or an extended partition number along with a logical partition number.

Notice that this definition is device dependent. Refer to specific device bundles for this information.

Examples:

- `4` is the primary partition number four.
- `3:1` is the first logical partition of the third primary extended partition.

CLI
---

Resin Config Inject exposes a simple CLI tool to interact with the image configuration, mainly for debugging purposes.

Install `resin-config-inject` globally to access it:

```sh
$ npm install -g resin-config-inject
```

That will add an `inject` script in your path.

### read <image> <partition>

Read and parse the configuration from an image.

Example:

```sh
$ inject read path/to/image.img "4:1"
```

### write <image> <partition> <|config>

Example:

```sh
$ cat config.json | inject write path/to/image.img "4:1"
```

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/resin-io/resin-config-inject/issues](https://github.com/resin-io/resin-config-inject/issues)
- Source Code: [github.com/resin-io/resin-config-inject](https://github.com/resin-io/resin-config-inject)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

Support
-------

If you're having any problem, please [raise an issue](https://github.com/resin-io/resin-config-inject/issues/new) on GitHub.

ChangeLog
---------

### v3.0.0

- Perform injection in a FAT partition instead of serialising the JSON directly.

### v2.0.0

- Handle partition definition instead of byte offsets in the public interface.

### v1.0.1

- Fix incompatibility issues with Node v0.11.

License
-------

The project is licensed under the MIT license.
