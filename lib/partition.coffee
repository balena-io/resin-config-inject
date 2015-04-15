_ = require('lodash')
_.str = require('underscore.string')
errors = require('resin-errors')
bootRecord = require('./boot-record')

SEPARATOR = ':'

###*
# @summary Parse a partition definition
# @protected
# @function
#
# @param {String} input - input definition
# @returns {Object} parsed definition
#
# @example
# result = partition.parse('4:1')
# console.log(result)
# > { primary: 4, logical: 1 }
###
exports.parse = (input) ->

	if not input?
		throw new errors.ResinMissingParameter('input')

	if not _.isString(input) and not _.isNumber(input)
		throw new errors.ResinInvalidParameter('input', input, 'not a string nor a number')

	if _.isString(input) and _.isEmpty(input)
		throw new errors.ResinInvalidParameter('input', input, 'empty string')

	if _.str.count(input, SEPARATOR) > 1
		throw new errors.ResinInvalidParameter('input', input, 'multiple separators')

	[ primary, logical ] = String(input).split(SEPARATOR)

	result = {}

	parsedPrimary = _.parseInt(primary)

	if _.isNaN(parsedPrimary)
		throw new Error("Invalid primary partition: #{primary}.")

	result.primary = parsedPrimary if parsedPrimary?

	if logical?
		parsedLogical = _.parseInt(logical)

		if _.isNaN(parsedLogical)
			throw new Error("Invalid logical partition: #{logical}.")

		result.logical = parsedLogical if parsedLogical?

	return result

###*
# @summary Get a partition from a boot record
# @protected
# @function
#
# @param {Object} record - boot record
# @param {Number} number - partition number
# @returns {Object} partition
#
# @example
# result = partition.getPartition(mbr, 1)
###
exports.getPartition = (record, number) ->

	if not record?
		throw new errors.ResinMissingParameter('record')

	if not record.partitions?
		throw new errors.ResinMissingOption('partitions')

	if not _.isArray(record.partitions)
		throw new errors.ResinInvalidOption('partitions', record.partitions, 'not an array')

	if not number?
		throw new errors.ResinMissingParameter('number')

	if not _.isNumber(number)
		throw new errors.ResinInvalidParameter('number', number, 'not a number')

	if number <= 0
		throw new errors.ResinInvalidParameter('number', number, 'not higher than zero')

	result = record.partitions[number - 1]

	if not result?
		throw new Error("Partition not found: #{number}.")

	return result

###*
# @summary Get a partition offset
# @protected
# @function
#
# @param {Object} partition - partition
# @returns {Number} partition offset
#
# @example
# offset = partition.getPartitionOffset(myPartition)
###
exports.getPartitionOffset = (partition) ->

	if not partition?
		throw new errors.ResinMissingParameter('partition')

	if not partition.firstLBA?
		throw new errors.ResinMissingOption('firstLBA')

	if not _.isNumber(partition.firstLBA)
		throw new errors.ResinInvalidOption('firstLBA', partition.firstLBA, 'not a number')

	return partition.firstLBA * 512

###*
# @summary Get a partition position
# @protected
# @function
#
# @param {String} image - image path
# @param {Object} definition - parition definition
# @param {Function} callback - callback
#
# @example
# partition.getPosition 'image.img', partition.parse('4:1'), (error, position) ->
#		throw error if error?
#		console.log(position)
###
exports.getPosition = (image, definition, callback) ->

	if not image?
		throw new errors.ResinMissingParameter('image')

	if not _.isString(image)
		throw new errors.ResinInvalidParameter('image', image, 'not a string')

	if not definition?
		throw new errors.ResinMissingParameter('definition')

	if not _.isPlainObject(definition)
		throw new errors.ResinInvalidParameter('definition', definition, 'not an object')

	if not definition.primary?
		throw new errors.ResinMissingOption('primary')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	bootRecord.getMaster image, (error, mbr) ->
		return callback(error) if error?

		try
			primaryPartition = exports.getPartition(mbr, definition.primary)
		catch error
			return callback(error)

		primaryPartitionOffset = exports.getPartitionOffset(primaryPartition)

		if not definition.logical? or definition.logical is 0
			return callback(null, primaryPartitionOffset)

		bootRecord.getExtended image, primaryPartitionOffset, (error, ebr) ->
			return callback(error) if error?

			if not ebr?
				return callback(new Error("Not an extended partition: #{definition.primary}."))

			try
				logicalPartition = exports.getPartition(ebr, definition.logical)
			catch error
				return callback(error)

			logicalPartition.firstLBA += primaryPartition.firstLBA
			logicalPartitionOffset = exports.getPartitionOffset(logicalPartition)

			return callback(null, logicalPartitionOffset)
