_ = require('lodash')
async = require('async')
fs = require('fs')
MasterBootRecord = require('mbr')
errors = require('resin-errors')

BOOT_RECORD_SIZE = 512

###*
# @summary Read the boot record of an image file
# @protected
# @function
#
# @description It returns a 512 bytes buffer.
#
# @param {String} image - image path
# @param {Number=0} position - byte position
# @param {Function} callback - callback (error, buffer)
#
# @example
#	bootRecord.read 'path/to/rpi.img', 0, (error, buffer) ->
#		throw error if error?
#		console.log(buffer)
###
exports.read = (image, position = 0, callback) ->

	if not image?
		throw new errors.ResinMissingParameter('image')

	if not _.isString(image)
		throw new errors.ResinInvalidParameter('image', image, 'not a string')

	if position?

		if not _.isNumber(position)
			throw new errors.ResinInvalidParameter('position', position, 'not a number')

		if position < 0
			throw new errors.ResinInvalidParameter('position', position, 'not a positive number')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	result = new Buffer(BOOT_RECORD_SIZE)

	async.waterfall([

		(callback) ->
			fs.open(image, 'r+', callback)

		(fd, callback) ->
			fs.read fd, result, 0, BOOT_RECORD_SIZE, position, (error) ->
				return callback(error) if error?
				return callback(null, fd)

		(fd, callback) ->
			fs.close(fd, callback)

		(callback) ->
			return callback(null, result)

	], callback)

###*
# @summary Parse a boot record buffer
# @protected
# @function
#
# @param {Buffer} buffer - mbr buffer
# @returns {Object} the parsed mbr
#
# @example
#	bootRecord.read 'path/to/rpi.img', 0, (error, buffer) ->
#		throw error if error?
#		parsedBootRecord = bootRecord.parse(buffer)
#		console.log(parsedBootRecord)
###
exports.parse = (mbrBuffer) ->

	if not mbrBuffer?
		throw new errors.ResinMissingParameter('mbrBuffer')

	if not Buffer.isBuffer(mbrBuffer)
		throw new errors.ResinInvalidParameter('mbrBuffer', mbrBuffer, 'not a buffer')

	return new MasterBootRecord(mbrBuffer)

###*
# @summary Get an Extended Boot Record from an offset
# @protected
# @function
#
# @description Attempts to parse the EBR as well.
#
# @param {String} image - image path
# @param {Number} position - byte position
# @param {Function} callback - callback (error, ebr)
#
# @example
#	bootRecord.getExtended 'path/to/rpi.img', 2048, (error, ebr) ->
#		throw error if error?
#		console.log(ebr)
###
exports.getExtended = (image, position, callback) ->

	if not image?
		throw new errors.ResinMissingParameter('image')

	if not _.isString(image)
		throw new errors.ResinInvalidParameter('image', image, 'not a string')

	if not position?
		throw new errors.ResinMissingParameter('position')

	if not _.isNumber(position)
		throw new errors.ResinInvalidParameter('position', position, 'not a number')

	if position < 0
		throw new errors.ResinInvalidParameter('position', position, 'not a positive number')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	exports.read image, position, (error, buffer) ->
		return callback(error) if error?

		try
			result = exports.parse(buffer)
		catch
			return callback(null, undefined)

		return callback(null, result)

###*
# @summary Get the Master Boot Record from an image
# @protected
# @function
#
# @param {String} image - image path
# @param {Function} callback - callback (error, mbr)
#
# @example
#	bootRecord.getMaster 'path/to/rpi.img', (error, mbr) ->
#		throw error if error?
#		console.log(mbr)
###
exports.getMaster = (image, callback) ->

	if not image?
		throw new errors.ResinMissingParameter('image')

	if not _.isString(image)
		throw new errors.ResinInvalidParameter('image', image, 'not a string')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	exports.read image, 0, (error, buffer) ->
		return callback(error) if error?

		try
			mbr = exports.parse(buffer)
		catch error
			return callback(error)

		return callback(null, mbr)
