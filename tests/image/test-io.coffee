async = require('async')
_ = require('lodash')
assert = require('assert')
fs = require('fs')
path = require('path')
inject = require('../../lib/inject')

IMAGE = path.join(__filename, '../random')
POSITION = 1024

async.waterfall [

	(callback) ->
		console.log('Writing initial config.')
		inject.write(IMAGE, { foo: 'bar' }, POSITION, callback)

	(callback) ->
		console.log("Reading #{IMAGE}.")
		inject.read(IMAGE, POSITION, callback)

	(config, callback) ->
		console.log(config)
		assert.deepEqual(config, { foo: 'bar' })

		config.foo = 'baz'

		console.log('Writing modified config.')
		inject.write(IMAGE, config, POSITION, callback)

	(callback) ->
		console.log('Reading modified config.')
		inject.read(IMAGE, POSITION, callback)

	(config, callback) ->
		console.log(config)
		assert.deepEqual(config, { foo: 'baz' })
		return callback()

], (error) ->
	if error?
		console.error(error.message)
		console.error('FAIL')
		process.exit(1)
	console.log('PASS')
