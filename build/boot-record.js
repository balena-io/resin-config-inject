var BOOT_RECORD_SIZE, MasterBootRecord, async, errors, fs, _;

_ = require('lodash');

async = require('async');

fs = require('fs');

MasterBootRecord = require('mbr');

errors = require('resin-errors');

BOOT_RECORD_SIZE = 512;


/**
 * @summary Read the boot record of an image file
 * @protected
 * @function
 *
 * @description It returns a 512 bytes buffer.
 *
 * @param {String} image - image path
 * @param {Number=0} position - byte position
 * @param {Function} callback - callback (error, buffer)
 *
 * @example
 *	bootRecord.read 'path/to/rpi.img', 0, (error, buffer) ->
 *		throw error if error?
 *		console.log(buffer)
 */

exports.read = function(image, position, callback) {
  var result;
  if (position == null) {
    position = 0;
  }
  if (image == null) {
    throw new errors.ResinMissingParameter('image');
  }
  if (!_.isString(image)) {
    throw new errors.ResinInvalidParameter('image', image, 'not a string');
  }
  if (position != null) {
    if (!_.isNumber(position)) {
      throw new errors.ResinInvalidParameter('position', position, 'not a number');
    }
    if (position < 0) {
      throw new errors.ResinInvalidParameter('position', position, 'not a positive number');
    }
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  result = new Buffer(BOOT_RECORD_SIZE);
  return async.waterfall([
    function(callback) {
      return fs.open(image, 'r+', callback);
    }, function(fd, callback) {
      return fs.read(fd, result, 0, BOOT_RECORD_SIZE, position, function(error) {
        if (error != null) {
          return callback(error);
        }
        return callback(null, fd);
      });
    }, function(fd, callback) {
      return fs.close(fd, callback);
    }, function(callback) {
      return callback(null, result);
    }
  ], callback);
};


/**
 * @summary Parse a boot record buffer
 * @protected
 * @function
 *
 * @param {Buffer} buffer - mbr buffer
 * @returns {Object} the parsed mbr
 *
 * @example
 *	bootRecord.read 'path/to/rpi.img', 0, (error, buffer) ->
 *		throw error if error?
 *		parsedBootRecord = bootRecord.parse(buffer)
 *		console.log(parsedBootRecord)
 */

exports.parse = function(mbrBuffer) {
  if (mbrBuffer == null) {
    throw new errors.ResinMissingParameter('mbrBuffer');
  }
  if (!Buffer.isBuffer(mbrBuffer)) {
    throw new errors.ResinInvalidParameter('mbrBuffer', mbrBuffer, 'not a buffer');
  }
  return new MasterBootRecord(mbrBuffer);
};


/**
 * @summary Get an Extended Boot Record from an offset
 * @protected
 * @function
 *
 * @description Attempts to parse the EBR as well.
 *
 * @param {String} image - image path
 * @param {Number} position - byte position
 * @param {Function} callback - callback (error, ebr)
 *
 * @example
 *	bootRecord.getExtended 'path/to/rpi.img', 2048, (error, ebr) ->
 *		throw error if error?
 *		console.log(ebr)
 */

exports.getExtended = function(image, position, callback) {
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
    throw new errors.ResinInvalidParameter('position', position, 'not a positive number');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return exports.read(image, position, function(error, buffer) {
    var result;
    if (error != null) {
      return callback(error);
    }
    try {
      result = exports.parse(buffer);
    } catch (_error) {
      return callback(null, void 0);
    }
    return callback(null, result);
  });
};


/**
 * @summary Get the Master Boot Record from an image
 * @protected
 * @function
 *
 * @param {String} image - image path
 * @param {Function} callback - callback (error, mbr)
 *
 * @example
 *	bootRecord.getMaster 'path/to/rpi.img', (error, mbr) ->
 *		throw error if error?
 *		console.log(mbr)
 */

exports.getMaster = function(image, callback) {
  if (image == null) {
    throw new errors.ResinMissingParameter('image');
  }
  if (!_.isString(image)) {
    throw new errors.ResinInvalidParameter('image', image, 'not a string');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return exports.read(image, 0, function(error, buffer) {
    var mbr;
    if (error != null) {
      return callback(error);
    }
    try {
      mbr = exports.parse(buffer);
    } catch (_error) {
      error = _error;
      return callback(error);
    }
    return callback(null, mbr);
  });
};
