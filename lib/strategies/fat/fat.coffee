_ = require('lodash')
fs = require('fs')
errors = require('resin-errors')
settings = require('./settings')

###*
# @summary Write an config object to a FAT partition
# @protected
# @function
#
# @param {Object} driver - fatfs driver
# @param {Object} config - config object
# @param {Function} callback - callback (error)
#
# @example
# fat.writeConfig driver, { hello: 'world' }, (error) ->
#		throw error if error?
###
exports.writeConfig = (driver, config, callback) ->

	if not driver?
		throw new errors.ResinMissingParameter('driver')

	if not config?
		throw new errors.ResinMissingParameter('config')

	if not _.isPlainObject(config)
		throw new errors.ResinInvalidParameter('config', config, 'not an object')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	stringifiedConfig = JSON.stringify(config)

	if not _.isEmpty(config) and stringifiedConfig is '{}'
		return callback(new errors.ResinInvalidParameter('config', config, 'not json'))

	driver.writeFile(settings.configFile, stringifiedConfig, callback)

###*
# @summary List files in a FAT drive
# @protected
# @function
#
# @param {Object} driver - fatfs driver
# @param {Function} callback - callback (error, files)
#
# @example
# fat.listFiles driver, (error, files) ->
#		throw error if error?
#
#		for file in files
#			console.log(fle)
###
exports.listFiles = (driver, callback) ->

	if not driver?
		throw new errors.ResinMissingParameter('driver')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	driver.readdir('.', callback)

###*
# @summary Check if FAT disk has a config.json file
# @protected
# @function
#
# @param {Object} driver - fatfs driver
# @param {Function} callback - callback (error, hasConfig)
#
# @example
# fat.hasConfig driver, (error, hasConfig) ->
#		throw error if error?
#		console.log(hasConfig)
###
exports.hasConfig = (driver, callback) ->

	if not driver?
		throw new errors.ResinMissingParameter('driver')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	exports.listFiles driver, (error, files) ->
		return callback(error) if error?
		return callback(null, _.includes(files, settings.configFile))

###*
# @summary Read a config file from a FAT disk
# @protected
# @function
#
# @param {Object} driver - fatfs driver
# @param {Function} callback - callback (error, config)
#
# @example
# fat.readConfig driver, (error, config) ->
#		throw error if error?
#		console.log(config)
###
exports.readConfig = (driver, callback) ->

	if not driver?
		throw new errors.ResinMissingParameter('driver')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	exports.hasConfig driver, (error, hasConfig) ->
		return callback(error) if error?

		if not hasConfig
			return callback(new Error('No config.json'))

		driver.readFile settings.configFile, encoding: 'utf8', (error, config) ->
			return callback(error) if error?

			try
				return callback(null, JSON.parse(config))
			catch
				return callback(new Error('Invalid config.json'))
