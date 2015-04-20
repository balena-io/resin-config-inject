_ = require('lodash')
async = require('async')
tmp = require('tmp')
errors = require('resin-errors')
fatDriver = require('./driver')
fat = require('./fat')
utils = require('./utils')
partition = require('../../partition')

tmp.setGracefulCleanup()

performOnFATPartition = (imagePath, definition, action, callback) ->
	tmp.file
		prefix: 'resin-'
	, (error, path, fd, cleanupCallback) ->

		async.waterfall([

			(callback) ->
				partition.copyPartition(imagePath, definition, path, callback)

			(callback) ->
				fatDriver.createDriverFromFile(path, callback)

			(driver, callback)  ->
				action(driver, path, cleanupCallback, callback)

		], callback)

###*
# @summary Read a config object from an image
# @protected
# @function
#
# @param {String} imagePath - image path
# @param {Number} position - config partition position
# @param {Object} definition - partition definition
# @param {Function} callback - callback (error, config)
#
# @todo Test this function
#
# @example
# strategy.read 'my/image.img', 2048,
#		primary: 4
#		logical: 1
#	, (error, config) ->
#		throw error if error?
#		console.log(config)
###
exports.read = (imagePath, position, definition, callback) ->

	if not imagePath?
		throw new errors.ResinMissingParameter('image')

	if not _.isString(imagePath)
		throw new errors.ResinInvalidParameter('image', imagePath, 'not a string')

	if not position?
		throw new errors.ResinMissingParameter('position')

	if not _.isNumber(position)
		throw new errors.ResinInvalidParameter('position', position, 'not a number')

	if not definition?
		throw new errors.ResinMissingParameter('definition')

	if not _.isPlainObject(definition)
		throw new errors.ResinInvalidParameter('definition', definition, 'not an object')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	performOnFATPartition imagePath, definition, (driver, fatPartition, cleanupCallback, callback) ->
		fat.readConfig driver, (error, config) ->
			return callback(error) if error?
			cleanupCallback()
			return callback(null, config)
	, callback

###*
# @summary Write a config object to an image
# @protected
# @function
#
# @param {String} imagePath - image path
# @param {Object} config - config object
# @param {Number} position - config partition position
# @param {Object} definition - partition definition
# @param {Function} callback - callback (error, config)
#
# @todo Test this function
#
# @example
# strategy.write 'my/image.img',
#		hello: 'world'
# , 2048,
#		primary: 4
#		logical: 1
#	, (error) ->
#		throw error if error?
###
exports.write = (imagePath, config, position, definition, callback) ->

	if not imagePath?
		throw new errors.ResinMissingParameter('image')

	if not _.isString(imagePath)
		throw new errors.ResinInvalidParameter('image', imagePath, 'not a string')

	if not config?
		throw new errors.ResinMissingParameter('config')

	if not _.isPlainObject(config)
		throw new errors.ResinInvalidParameter('config', config, 'not an object')

	if not position?
		throw new errors.ResinMissingParameter('position')

	if not _.isNumber(position)
		throw new errors.ResinInvalidParameter('position', position, 'not a number')

	if not definition?
		throw new errors.ResinMissingParameter('definition')

	if not _.isPlainObject(definition)
		throw new errors.ResinInvalidParameter('definition', definition, 'not an object')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	performOnFATPartition imagePath, definition, (driver, fatPartition, cleanupCallback, callback) ->
		fat.writeConfig driver, config, (error) ->
			return callback(error) if error?

			utils.streamFileToPosition fatPartition, imagePath, position, (error) ->
				return callback(error) if error?
				cleanupCallback()
				return callback()
	, callback

###*
# @summary Write config object to a partition and return a stream
# @protected
# @function
#
# @description The stream corresponds to the written partition.
#
# @param {String} image - image path
# @param {Object} config - config object
# @param {String|Number} definition - partition definition
# @param {Function} callback - callback (error, stream)
#
# @example
#	strategy.writePartition 'path/to/rpi.img', { hello: 'world' }, '4:1', (error, stream) ->
#		throw error if error?
###
exports.writePartition = (imagePath, config, definition, callback) ->

	if not imagePath?
		throw new errors.ResinMissingParameter('image')

	if not _.isString(imagePath)
		throw new errors.ResinInvalidParameter('image', imagePath, 'not a string')

	if not config?
		throw new errors.ResinMissingParameter('config')

	if not _.isPlainObject(config)
		throw new errors.ResinInvalidParameter('config', config, 'not an object')

	if not definition?
		throw new errors.ResinMissingParameter('definition')

	if not _.isPlainObject(definition)
		throw new errors.ResinInvalidParameter('definition', definition, 'not an object')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	performOnFATPartition imagePath, definition, (driver, fatPartition, cleanupCallback, callback) ->
		fat.writeConfig driver, config, (error) ->
			return callback(error) if error?

			partitionStream = fs.createReadStream(fatPartition)
			partitionStream.on 'close', ->
				cleanupCallback()

			return callback(null, partitionStream)
	, callback
