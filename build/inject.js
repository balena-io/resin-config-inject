var errors, partition, strategy, _;

_ = require('lodash');

errors = require('resin-errors');

partition = require('./partition');

strategy = require('./strategies/fat');


/**
 * @summary Write a config object to an image
 * @public
 * @function
 *
 * @param {String} image - image path
 * @param {Object} config - config object
 * @param {String|Number} definition - partition definition
 * @param {Function} callback - callback (error)
 *
 * @example
 *	inject.write 'path/to/rpi.img', hello: 'world', '4:1', (error) ->
 *		throw error if error?
 */

exports.write = function(imagePath, config, definition, callback) {
  if (config == null) {
    throw new errors.ResinMissingParameter('config');
  }
  if (!_.isObject(config) || _.isArray(config)) {
    throw new errors.ResinInvalidParameter('config', config, 'not an object');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  definition = partition.parse(definition);
  return partition.getPosition(imagePath, definition, function(error, position) {
    if (error != null) {
      return callback(error);
    }
    return strategy.write(imagePath, config, position, definition, callback);
  });
};


/**
 * @summary Read a config object from an image
 * @public
 * @function
 *
 * @param {String} image - image path
 * @param {String|Number} definition - partition definition
 * @param {Function} callback - callback (error, config)
 *
 * @example
 *	inject.read 'path/to/rpi.img', 128, (error, config) ->
 *		throw error if error?
 *		console.log(config)
 */

exports.read = function(imagePath, definition, callback) {
  if (imagePath == null) {
    throw new errors.ResinMissingParameter('image');
  }
  if (!_.isString(imagePath)) {
    throw new errors.ResinInvalidParameter('image', imagePath, 'not a string');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  definition = partition.parse(definition);
  return partition.getPosition(imagePath, definition, function(error, position) {
    if (error != null) {
      return callback(error);
    }
    return strategy.read(imagePath, position, definition, callback);
  });
};


/**
 * @summary Write config object to a partition and return a stream
 * @public
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
 *	inject.writePartition 'path/to/rpi.img', { hello: 'world' }, '4:1', (error, stream) ->
 *		throw error if error?
 */

exports.writePartition = function(imagePath, config, definition, callback) {
  return strategy.writePartition(imagePath, config, partition.parse(definition), callback);
};
