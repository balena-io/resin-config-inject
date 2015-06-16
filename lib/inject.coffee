imageConfig = require('resin-image-config')

###*
# @summary Write a config object to an image
# @public
# @function
#
# @param {String} image - image path
# @param {Object} config - config object
# @param {String|Number} definition - partition definition
# @param {Function} callback - callback (error)
#
# @example
#	inject.write 'path/to/rpi.img', hello: 'world', '4:1', (error) ->
#		throw error if error?
###
exports.write = (imagePath, config, definition, callback) ->
	writeFiles = {}
	writeFiles[definition] =
		'config.json': JSON.stringify(config)

	imageConfig.write(imagePath, writeFiles).nodeify(callback)

###*
# @summary Read a config object from an image
# @public
# @function
#
# @param {String} image - image path
# @param {String|Number} definition - partition definition
# @param {Function} callback - callback (error, config)
#
# @example
#	inject.read 'path/to/rpi.img', 128, (error, config) ->
#		throw error if error?
#		console.log(config)
###
exports.read = (imagePath, definition, callback) ->
	readFiles = {}
	readFiles[definition] = [ 'config.json' ]

	imageConfig.read(imagePath, readFiles).then (results) ->
		return JSON.parse(results[definition]['config.json'])
	.nodeify(callback)
