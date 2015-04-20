assert = require('assert')
inject = require('../../lib/inject')

image = process.argv[2]
partition = process.argv[3]

if not image? or not partition?
	console.error('Usage: coffee inject.coffee <image> <partition>')
	process.exit(1)

console.log("IMAGE: #{image}")
console.log("PARTITION: #{partition}")

require('async').waterfall [

	(callback) ->
		inject.read(image, partition, callback)

	(config, callback) ->
		console.info(config)
		assert(not config.foo?, 'foo does not exist')
		config.foo = 'bar'
		inject.write(image, config, partition, callback)

	(callback) ->
		inject.read(image, partition, callback)

	(config, callback) ->
		console.info(config)
		assert.equal(config.foo, 'bar', 'foo is equal to "bar"')
		delete config.foo
		inject.write(image, config, partition, callback)

	(callback) ->
		inject.read(image, partition, callback)

	(config, callback) ->
		console.info(config)
		assert(not config.foo?, 'foo does not exist')
		return callback()

], (error) ->
	if error?
		console.error("ERROR: #{error.message}")
		process.exit(1)

	console.log('SUCCESS')
	process.exit(0)
