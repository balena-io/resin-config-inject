var errors, image, settings, utils, _;

_ = require('lodash');

errors = require('resin-errors');

image = require('./image');

utils = require('./utils');

settings = require('./settings');


/**
 * @summary Write a config buffer to an image
 * @public
 * @function
 *
 * @param {String} image - image path
 * @param {Object} config - config object
 * @param {Number} position - position
 * @param {Function} callback - callback (error)
 *
 * @example
 *	inject.write 'path/to/rpi.img', hello: 'world', 128, (error) ->
 *		throw error if error?
 */

exports.write = function(imagePath, config, position, callback) {
  var data;
  if (config == null) {
    throw new errors.ResinMissingParameter('config');
  }
  if (!_.isObject(config) || _.isArray(config)) {
    throw new errors.ResinInvalidParameter('config', config, 'not an object');
  }
  data = utils.configToBuffer(config, settings.configSize);
  return image.writeBufferToPosition(imagePath, data, position, callback);
};


/**
 * @summary Read a config buffer from an image
 * @public
 * @function
 *
 * @param {String} image - image path
 * @param {Number} position - position
 * @param {Function} callback - callback (error, config)
 *
 * @example
 *	inject.read 'path/to/rpi.img', 128, (error, config) ->
 *		throw error if error?
 *		console.log(config)
 */

exports.read = function(imagePath, position, callback) {
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return image.readBufferFromPosition(imagePath, position, function(error, data) {
    var config;
    if (error != null) {
      return callback(error);
    }
    try {
      config = utils.bufferToConfig(data);
    } catch (_error) {
      error = _error;
      return callback(error);
    }
    return callback(null, config);
  });
};
