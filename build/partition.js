var SEPARATOR, bootRecord, errors, _;

_ = require('lodash');

_.str = require('underscore.string');

errors = require('resin-errors');

bootRecord = require('./boot-record');

SEPARATOR = ':';


/**
 * @summary Parse a partition definition
 * @protected
 * @function
 *
 * @param {String} input - input definition
 * @returns {Object} parsed definition
 *
 * @example
 * result = partition.parse('4:1')
 * console.log(result)
 * > { primary: 4, logical: 1 }
 */

exports.parse = function(input) {
  var logical, parsedLogical, parsedPrimary, primary, result, _ref;
  if (input == null) {
    throw new errors.ResinMissingParameter('input');
  }
  if (!_.isString(input) && !_.isNumber(input)) {
    throw new errors.ResinInvalidParameter('input', input, 'not a string nor a number');
  }
  if (_.isString(input) && _.isEmpty(input)) {
    throw new errors.ResinInvalidParameter('input', input, 'empty string');
  }
  if (_.str.count(input, SEPARATOR) > 1) {
    throw new errors.ResinInvalidParameter('input', input, 'multiple separators');
  }
  _ref = String(input).split(SEPARATOR), primary = _ref[0], logical = _ref[1];
  result = {};
  parsedPrimary = _.parseInt(primary);
  if (_.isNaN(parsedPrimary)) {
    throw new Error("Invalid primary partition: " + primary + ".");
  }
  if (parsedPrimary != null) {
    result.primary = parsedPrimary;
  }
  if (logical != null) {
    parsedLogical = _.parseInt(logical);
    if (_.isNaN(parsedLogical)) {
      throw new Error("Invalid logical partition: " + logical + ".");
    }
    if (parsedLogical != null) {
      result.logical = parsedLogical;
    }
  }
  return result;
};


/**
 * @summary Get a partition from a boot record
 * @protected
 * @function
 *
 * @param {Object} record - boot record
 * @param {Number} number - partition number
 * @returns {Object} partition
 *
 * @example
 * result = partition.getPartition(mbr, 1)
 */

exports.getPartition = function(record, number) {
  var result;
  if (record == null) {
    throw new errors.ResinMissingParameter('record');
  }
  if (record.partitions == null) {
    throw new errors.ResinMissingOption('partitions');
  }
  if (!_.isArray(record.partitions)) {
    throw new errors.ResinInvalidOption('partitions', record.partitions, 'not an array');
  }
  if (number == null) {
    throw new errors.ResinMissingParameter('number');
  }
  if (!_.isNumber(number)) {
    throw new errors.ResinInvalidParameter('number', number, 'not a number');
  }
  if (number <= 0) {
    throw new errors.ResinInvalidParameter('number', number, 'not higher than zero');
  }
  result = record.partitions[number - 1];
  if (result == null) {
    throw new Error("Partition not found: " + number + ".");
  }
  return result;
};


/**
 * @summary Get a partition offset
 * @protected
 * @function
 *
 * @param {Object} partition - partition
 * @returns {Number} partition offset
 *
 * @example
 * offset = partition.getPartitionOffset(myPartition)
 */

exports.getPartitionOffset = function(partition) {
  if (partition == null) {
    throw new errors.ResinMissingParameter('partition');
  }
  if (partition.firstLBA == null) {
    throw new errors.ResinMissingOption('firstLBA');
  }
  if (!_.isNumber(partition.firstLBA)) {
    throw new errors.ResinInvalidOption('firstLBA', partition.firstLBA, 'not a number');
  }
  return partition.firstLBA * 512;
};


/**
 * @summary Get a partition position
 * @protected
 * @function
 *
 * @param {String} image - image path
 * @param {Object} definition - parition definition
 * @param {Function} callback - callback
 *
 * @example
 * partition.getPosition 'image.img', partition.parse('4:1'), (error, position) ->
 *		throw error if error?
 *		console.log(position)
 */

exports.getPosition = function(image, definition, callback) {
  if (image == null) {
    throw new errors.ResinMissingParameter('image');
  }
  if (!_.isString(image)) {
    throw new errors.ResinInvalidParameter('image', image, 'not a string');
  }
  if (definition == null) {
    throw new errors.ResinMissingParameter('definition');
  }
  if (!_.isPlainObject(definition)) {
    throw new errors.ResinInvalidParameter('definition', definition, 'not an object');
  }
  if (definition.primary == null) {
    throw new errors.ResinMissingOption('primary');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return bootRecord.getMaster(image, function(error, mbr) {
    var primaryPartition, primaryPartitionOffset;
    if (error != null) {
      return callback(error);
    }
    try {
      primaryPartition = exports.getPartition(mbr, definition.primary);
    } catch (_error) {
      error = _error;
      return callback(error);
    }
    primaryPartitionOffset = exports.getPartitionOffset(primaryPartition);
    if ((definition.logical == null) || definition.logical === 0) {
      return callback(null, primaryPartitionOffset);
    }
    return bootRecord.getExtended(image, primaryPartitionOffset, function(error, ebr) {
      var logicalPartition, logicalPartitionOffset;
      if (error != null) {
        return callback(error);
      }
      if (ebr == null) {
        return callback(new Error("Not an extended partition: " + definition.primary + "."));
      }
      try {
        logicalPartition = exports.getPartition(ebr, definition.logical);
      } catch (_error) {
        error = _error;
        return callback(error);
      }
      logicalPartition.firstLBA += primaryPartition.firstLBA;
      logicalPartitionOffset = exports.getPartitionOffset(logicalPartition);
      return callback(null, logicalPartitionOffset);
    });
  });
};
