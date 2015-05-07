_ = require('lodash')
async = require('async')
fs = require('fs')
fatfs = require('fatfs')
errors = require('resin-errors')
settings = require('./settings')
utils = require('./utils')

###*
# @summary Get a fatfs driver given a file descriptor
# @protected
# @function
#
# @param {Object} fd - file descriptor
# @param {Number} size - size of the image
# @param {Number} sectorSize - sector size
# @returns {Object} the fatfs driver
#
# @example
# fatDriver = driver.getDriver(fd, 2048, 512)
###
exports.getDriver = (fd, size, sectorSize) ->

	if not fd?
		throw new errors.ResinMissingParameter('fd')

	if not size?
		throw new errors.ResinMissingParameter('size')

	if not _.isNumber(size)
		throw new errors.ResinInvalidParameter('size', size, 'not a number')

	if not sectorSize?
		throw new errors.ResinMissingParameter('sectorSize')

	if not _.isNumber(sectorSize)
		throw new errors.ResinInvalidParameter('sectorSize', sectorSize, 'not a number')

	return {
		sectorSize: sectorSize
		numSectors: size / sectorSize
		readSectors: (sector, dest, callback) ->
			destLength = dest.length

			if not utils.isDivisibleBy(destLength, sectorSize)
				throw Error('Unexpected buffer length!')

			fs.read fd, dest, 0, destLength, sector * sectorSize, (error, bytesRead, buffer) ->
				return callback(error, buffer)

		writeSectors: (sector, data, callback) ->
			dataLength = data.length

			if not utils.isDivisibleBy(dataLength, sectorSize)
				throw Error('Unexpected buffer length!')

			fs.write(fd, data, 0, dataLength, sector * sectorSize, callback)
	}

###*
# @summary Get a fatfs driver from a file
# @protected
# @function
#
# @param {String} file - file path
# @param {Function} callback - callback (error, driver)
#
# @example
# driver.createDriverFromFile 'my/file', (error, driver) ->
#		throw error if error?
#		console.log(driver)
###
exports.createDriverFromFile = (file, callback) ->

	if not file?
		throw new errors.ResinMissingParameter('file')

	if not _.isString(file)
		throw new errors.ResinInvalidParameter('file', file, 'not a string')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	async.waterfall([

		(callback) ->
			fs.open(file, 'r+', callback)

		(fd, callback) ->
			fs.fstat fd, (error, stats) ->
				return callback(error) if error?
				return callback(null, fd, stats)

		(fd, stats, callback) ->
			driver = exports.getDriver(fd, stats.size, settings.sectorSize)
			return callback(null, driver)

		(driver, callback) ->
			return callback(null, fatfs.createFileSystem(driver))

	], callback)
