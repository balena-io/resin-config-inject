var SECTOR_SIZE, SEPARATOR, bootRecord, errors, fileslice, _;

_ = require('lodash');

_.str = require('underscore.string');

errors = require('resin-errors');

fileslice = require('fileslice');

bootRecord = require('./boot-record');

SEPARATOR = ':';

SECTOR_SIZE = 512;


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
  return partition.firstLBA * SECTOR_SIZE;
};


/**
 * @summary Get the partition size in bytes
 * @protected
 * @function
 *
 * @param {Object} partition - partition
 * @returns {Number} partition size
 *
 * @example
 * size = partition.getPartitionSize(myPartition)
 */

exports.getPartitionSize = function(partition) {
  if (partition == null) {
    throw new errors.ResinMissingParameter('partition');
  }
  if (partition.sectors == null) {
    throw new errors.ResinMissingOption('sectors');
  }
  if (!_.isNumber(partition.sectors)) {
    throw new errors.ResinInvalidOption('sectors', partition.sectors, 'not a number');
  }
  return partition.sectors * SECTOR_SIZE;
};


/**
 * @summary Get a partition object from a definition
 * @protected
 * @function
 *
 * @param {String} image - image path
 * @param {Object} definition - parition definition
 * @param {Function} callback - callback
 *
 * @example
 * partition.getPartitionFromDefinition 'image.img', partition.parse('4:1'), (error, partition) ->
 *		throw error if error?
 *		console.log(partition)
 */

exports.getPartitionFromDefinition = function(image, definition, callback) {
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
    if ((definition.logical == null) || definition.logical === 0) {
      return callback(null, primaryPartition);
    }
    primaryPartitionOffset = exports.getPartitionOffset(primaryPartition);
    return bootRecord.getExtended(image, primaryPartitionOffset, function(error, ebr) {
      var logicalPartition;
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
      return callback(null, logicalPartition);
    });
  });
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
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return exports.getPartitionFromDefinition(image, definition, function(error, partition) {
    var partitionOffset;
    if (error != null) {
      return callback(error);
    }
    partitionOffset = exports.getPartitionOffset(partition);
    return callback(null, partitionOffset);
  });
};


/**
 * @summary Copy a partition to a separate file
 * @protected
 * @function
 *
 * @param {String} image - image path
 * @param {Object} definition - parition definition
 * @param {String} output - output path
 * @param {Function} callback - callback
 *
 * @example
 * partition.copyPartition 'image.img', partition.parse('4:1'), 'output', (error) ->
 *		throw error if error?
 */

exports.copyPartition = function(image, definition, output, callback) {
  if (output == null) {
    throw new errors.ResinMissingParameter('output');
  }
  if (!_.isString(output)) {
    throw new errors.ResinInvalidParameter('output', output, 'not a string');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return exports.getPartitionFromDefinition(image, definition, function(error, partition) {
    var end, start;
    if (error != null) {
      return callback(error);
    }
    try {
      start = exports.getPartitionOffset(partition);
      end = start + exports.getPartitionSize(partition);
    } catch (_error) {
      error = _error;
      return callback(error);
    }
    return fileslice.copy(image, output, {
      start: start,
      end: end
    }, callback);
  });
};
