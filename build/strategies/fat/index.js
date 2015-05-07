var async, errors, fat, fatDriver, partition, performOnFATPartition, tmp, utils, _;

_ = require('lodash');

async = require('async');

tmp = require('tmp');

errors = require('resin-errors');

fatDriver = require('./driver');

fat = require('./fat');

utils = require('./utils');

partition = require('../../partition');

tmp.setGracefulCleanup();

performOnFATPartition = function(imagePath, definition, action, callback) {
  return tmp.file({
    prefix: 'resin-'
  }, function(error, path, fd, cleanupCallback) {
    return async.waterfall([
      function(callback) {
        return partition.copyPartition(imagePath, definition, path, callback);
      }, function(callback) {
        return fatDriver.createDriverFromFile(path, callback);
      }, function(driver, callback) {
        return action(driver, path, cleanupCallback, callback);
      }
    ], callback);
  });
};


/**
 * @summary Read a config object from an image
 * @protected
 * @function
 *
 * @param {String} imagePath - image path
 * @param {Number} position - config partition position
 * @param {Object} definition - partition definition
 * @param {Function} callback - callback (error, config)
 *
 * @todo Test this function
 *
 * @example
 * strategy.read 'my/image.img', 2048,
 *		primary: 4
 *		logical: 1
 *	, (error, config) ->
 *		throw error if error?
 *		console.log(config)
 */

exports.read = function(imagePath, position, definition, callback) {
  if (imagePath == null) {
    throw new errors.ResinMissingParameter('image');
  }
  if (!_.isString(imagePath)) {
    throw new errors.ResinInvalidParameter('image', imagePath, 'not a string');
  }
  if (position == null) {
    throw new errors.ResinMissingParameter('position');
  }
  if (!_.isNumber(position)) {
    throw new errors.ResinInvalidParameter('position', position, 'not a number');
  }
  if (definition == null) {
    throw new errors.ResinMissingParameter('definition');
  }
  if (!_.isPlainObject(definition)) {
    throw new errors.ResinInvalidParameter('definition', definition, 'not an object');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return performOnFATPartition(imagePath, definition, function(driver, fatPartition, cleanupCallback, callback) {
    return fat.readConfig(driver, function(error, config) {
      if (error != null) {
        return callback(error);
      }
      cleanupCallback();
      return callback(null, config);
    });
  }, callback);
};


/**
 * @summary Write a config object to an image
 * @protected
 * @function
 *
 * @param {String} imagePath - image path
 * @param {Object} config - config object
 * @param {Number} position - config partition position
 * @param {Object} definition - partition definition
 * @param {Function} callback - callback (error, config)
 *
 * @todo Test this function
 *
 * @example
 * strategy.write 'my/image.img',
 *		hello: 'world'
 * , 2048,
 *		primary: 4
 *		logical: 1
 *	, (error) ->
 *		throw error if error?
 */

exports.write = function(imagePath, config, position, definition, callback) {
  if (imagePath == null) {
    throw new errors.ResinMissingParameter('image');
  }
  if (!_.isString(imagePath)) {
    throw new errors.ResinInvalidParameter('image', imagePath, 'not a string');
  }
  if (config == null) {
    throw new errors.ResinMissingParameter('config');
  }
  if (!_.isPlainObject(config)) {
    throw new errors.ResinInvalidParameter('config', config, 'not an object');
  }
  if (position == null) {
    throw new errors.ResinMissingParameter('position');
  }
  if (!_.isNumber(position)) {
    throw new errors.ResinInvalidParameter('position', position, 'not a number');
  }
  if (definition == null) {
    throw new errors.ResinMissingParameter('definition');
  }
  if (!_.isPlainObject(definition)) {
    throw new errors.ResinInvalidParameter('definition', definition, 'not an object');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return performOnFATPartition(imagePath, definition, function(driver, fatPartition, cleanupCallback, callback) {
    return fat.writeConfig(driver, config, function(error) {
      if (error != null) {
        return callback(error);
      }
      return utils.streamFileToPosition(fatPartition, imagePath, position, function(error) {
        if (error != null) {
          return callback(error);
        }
        cleanupCallback();
        return callback();
      });
    });
  }, callback);
};


/**
 * @summary Write config object to a partition and return a stream
 * @protected
 * @function
 *
 * @description The stream corresponds to the written partition.
 *
 * @param {String} image - image path
 * @param {Object} config - config object
 * @param {String|Number} definition - partition definition
 * @param {Function} callback - callback (error, stream)
 *
 * @example
 *	strategy.writePartition 'path/to/rpi.img', { hello: 'world' }, '4:1', (error, stream) ->
 *		throw error if error?
 */

exports.writePartition = function(imagePath, config, definition, callback) {
  if (imagePath == null) {
    throw new errors.ResinMissingParameter('image');
  }
  if (!_.isString(imagePath)) {
    throw new errors.ResinInvalidParameter('image', imagePath, 'not a string');
  }
  if (config == null) {
    throw new errors.ResinMissingParameter('config');
  }
  if (!_.isPlainObject(config)) {
    throw new errors.ResinInvalidParameter('config', config, 'not an object');
  }
  if (definition == null) {
    throw new errors.ResinMissingParameter('definition');
  }
  if (!_.isPlainObject(definition)) {
    throw new errors.ResinInvalidParameter('definition', definition, 'not an object');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return performOnFATPartition(imagePath, definition, function(driver, fatPartition, cleanupCallback, callback) {
    return fat.writeConfig(driver, config, function(error) {
      var partitionStream;
      if (error != null) {
        return callback(error);
      }
      partitionStream = fs.createReadStream(fatPartition);
      partitionStream.on('close', function() {
        return cleanupCallback();
      });
      return callback(null, partitionStream);
    });
  }, callback);
};
