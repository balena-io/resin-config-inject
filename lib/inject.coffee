_ = require('lodash')
errors = require('resin-errors')
image = require('./image')
utils = require('./utils')
settings = require('./settings')

###*
# @summary Write a config buffer to an image
# @public
# @function
#
# @param {String} image - image path
# @param {Object} config - config object
# @param {Number} position - position
# @param {Function} callback - callback (error)
#
# @example
#	inject.write 'path/to/rpi.img', hello: 'world', 128, (error) ->
#		throw error if error?
###
exports.write = (imagePath, config, position, callback) ->

	if not config?
		throw new errors.ResinMissingParameter('config')

	if not _.isObject(config) or _.isArray(config)
		throw new errors.ResinInvalidParameter('config', config, 'not an object')

	data = utils.configToBuffer(config, settings.configSize)
	image.writeBufferToPosition(imagePath, data, position, callback)

###*
# @summary Read a config buffer from an image
# @public
# @function
#
# @param {String} image - image path
# @param {Number} position - position
# @param {Function} callback - callback (error, config)
#
# @example
#	inject.read 'path/to/rpi.img', 128, (error, config) ->
#		throw error if error?
#		console.log(config)
###
exports.read = (imagePath, position, callback) ->

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	image.readBufferFromPosition imagePath, position, (error, data) ->
		return callback(error) if error?

		try
			config = utils.bufferToConfig(data)
		catch error
			return callback(error)

		return callback(null, config)
