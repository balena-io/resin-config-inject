var async, errors, fs, performOnFile, settings, _;

_ = require('lodash');

fs = require('fs');

async = require('async');

errors = require('resin-errors');

settings = require('./settings');


/**
 * @summary Perform an action on a file
 * @private
 * @function
 *
 * @param {String} file - path to file
 * @param {Function} action - action function (fd, callback)
 * @param {Function} callback - callback (error)
 */

performOnFile = function(file, action, callback) {
  return async.waterfall([
    function(callback) {
      return fs.open(file, 'rs+', callback);
    }, function(fd, callback) {
      return action(fd, function(error) {
        if (error != null) {
          return callback(error);
        }
        return callback(null, fd);
      });
    }, function(fd, callback) {
      return fs.close(fd, callback);
    }
  ], callback);
};


/**
 * @summary Write buffer to position
 * @protected
 * @function
 *
 * @param {String} image - path to image
 * @param {Buffer} data - data
 * @param {Number} position - position to read from
 * @param {Function} callback - callback (error, data)
 *
 * @throws Will throw if position is not a positive number.
 *
 * @todo Test the body of the function. Currently only the contracts are being tested.
 *
 * @example
 * image.writeBufferToPosition 'path/to/rpi.img', new Buffer('1234'), 128, (error) ->
 *		throw error if error?
 */

exports.writeBufferToPosition = function(image, data, position, callback) {
  if (image == null) {
    throw new errors.ResinMissingParameter('image');
  }
  if (!_.isString(image)) {
    throw new errors.ResinInvalidParameter('image', image, 'not a string');
  }
  if (data == null) {
    throw new errors.ResinMissingParameter('data');
  }
  if (!Buffer.isBuffer(data)) {
    throw new errors.ResinInvalidParameter('data', data, 'not a buffer');
  }
  if (position == null) {
    throw new errors.ResinMissingParameter('position');
  }
  if (!_.isNumber(position)) {
    throw new errors.ResinInvalidParameter('position', position, 'not a number');
  }
  if (position < 0) {
    throw new errors.ResinInvalidParameter('position', position, 'negative number');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return performOnFile(image, function(fd, callback) {
    return fs.write(fd, data, 0, settings.configSize, position, callback);
  }, callback);
};


/**
 * @summary Read buffer from position
 * @protected
 * @function
 *
 * @param {String} image - path to image
 * @param {Number} position - position to read from
 * @param {Function} callback - callback (error, data)
 *
 * @throws Will throw if position is not a positive number.
 *
 * @todo Test the body of the function. Currently only the contracts are being tested.
 *
 * @example
 * image.readBufferFromPosition 'path/to/rpi.img', 128, (error, data) ->
 *		throw error if error?
 *		console.log(utils.bufferToConfig(data))
 */

exports.readBufferFromPosition = function(image, position, callback) {
  var result;
  if (image == null) {
    throw new errors.ResinMissingParameter('image');
  }
  if (!_.isString(image)) {
    throw new errors.ResinInvalidParameter('image', image, 'not a string');
  }
  if (position == null) {
    throw new errors.ResinMissingParameter('position');
  }
  if (!_.isNumber(position)) {
    throw new errors.ResinInvalidParameter('position', position, 'not a number');
  }
  if (position < 0) {
    throw new errors.ResinInvalidParameter('position', position, 'negative number');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  result = new Buffer(settings.configSize);
  return performOnFile(image, function(fd, callback) {
    return fs.read(fd, result, 0, settings.configSize, position, callback);
  }, function(error) {
    if (error != null) {
      return callback(error);
    }
    return callback(null, result);
  });
};
