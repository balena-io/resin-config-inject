_ = require('lodash')
fs = require('fs')
async = require('async')
errors = require('resin-errors')
settings = require('./settings')

###*
# @summary Perform an action on a file
# @private
# @function
#
# @param {String} file - path to file
# @param {Function} action - action function (fd, callback)
# @param {Function} callback - callback (error)
###
performOnFile = (file, action, callback) ->
	async.waterfall([
		(callback)     -> fs.open(file, 'rs+', callback)
		(fd, callback) -> return action fd, (error) ->
			return callback(error) if error?
			return callback(null, fd)
		(fd, callback) -> fs.close(fd, callback)
	], callback)

###*
# @summary Write buffer to position
# @protected
# @function
#
# @param {String} image - path to image
# @param {Buffer} data - data
# @param {Number} position - position to read from
# @param {Function} callback - callback (error, data)
#
# @throws Will throw if position is not a positive number.
#
# @todo Test the body of the function. Currently only the contracts are being tested.
#
# @example
# image.writeBufferToPosition 'path/to/rpi.img', new Buffer('1234'), 128, (error) ->
#		throw error if error?
###
exports.writeBufferToPosition = (image, data, position, callback) ->

	if not image?
		throw new errors.ResinMissingParameter('image')

	if not _.isString(image)
		throw new errors.ResinInvalidParameter('image', image, 'not a string')

	if not data?
		throw new errors.ResinMissingParameter('data')

	if not Buffer.isBuffer(data)
		throw new errors.ResinInvalidParameter('data', data, 'not a buffer')

	if not position?
		throw new errors.ResinMissingParameter('position')

	if not _.isNumber(position)
		throw new errors.ResinInvalidParameter('position', position, 'not a number')

	if position < 0
		throw new errors.ResinInvalidParameter('position', position, 'negative number')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	performOnFile image, (fd, callback) ->
		fs.write(fd, data, 0, settings.configSize, position, callback)
	, callback

###*
# @summary Read buffer from position
# @protected
# @function
#
# @param {String} image - path to image
# @param {Number} position - position to read from
# @param {Function} callback - callback (error, data)
#
# @throws Will throw if position is not a positive number.
#
# @todo Test the body of the function. Currently only the contracts are being tested.
#
# @example
# image.readBufferFromPosition 'path/to/rpi.img', 128, (error, data) ->
#		throw error if error?
#		console.log(utils.bufferToConfig(data))
###
exports.readBufferFromPosition = (image, position, callback) ->

	if not image?
		throw new errors.ResinMissingParameter('image')

	if not _.isString(image)
		throw new errors.ResinInvalidParameter('image', image, 'not a string')

	if not position?
		throw new errors.ResinMissingParameter('position')

	if not _.isNumber(position)
		throw new errors.ResinInvalidParameter('position', position, 'not a number')

	if position < 0
		throw new errors.ResinInvalidParameter('position', position, 'negative number')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	result = new Buffer(settings.configSize)
	performOnFile image, (fd, callback) ->
		fs.read(fd, result, 0, settings.configSize, position, callback)
	, (error) ->
		return callback(error) if error?
		return callback(null, result)
