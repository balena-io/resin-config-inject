var async, errors, fatfs, fs, settings, utils, _;

_ = require('lodash');

async = require('async');

fs = require('fs');

fatfs = require('fatfs');

errors = require('resin-errors');

settings = require('./settings');

utils = require('./utils');


/**
 * @summary Get a fatfs driver given a file descriptor
 * @protected
 * @function
 *
 * @param {Object} fd - file descriptor
 * @param {Number} size - size of the image
 * @param {Number} sectorSize - sector size
 * @returns {Object} the fatfs driver
 *
 * @example
 * fatDriver = driver.getDriver(fd, 2048, 512)
 */

exports.getDriver = function(fd, size, sectorSize) {
  if (fd == null) {
    throw new errors.ResinMissingParameter('fd');
  }
  if (size == null) {
    throw new errors.ResinMissingParameter('size');
  }
  if (!_.isNumber(size)) {
    throw new errors.ResinInvalidParameter('size', size, 'not a number');
  }
  if (sectorSize == null) {
    throw new errors.ResinMissingParameter('sectorSize');
  }
  if (!_.isNumber(sectorSize)) {
    throw new errors.ResinInvalidParameter('sectorSize', sectorSize, 'not a number');
  }
  return {
    sectorSize: sectorSize,
    numSectors: size / sectorSize,
    readSectors: function(sector, dest, callback) {
      var destLength;
      destLength = dest.length;
      if (!utils.isDivisibleBy(destLength, sectorSize)) {
        throw Error('Unexpected buffer length!');
      }
      return fs.read(fd, dest, 0, destLength, sector * sectorSize, function(error, bytesRead, buffer) {
        return callback(error, buffer);
      });
    },
    writeSectors: function(sector, data, callback) {
      var dataLength;
      dataLength = data.length;
      if (!utils.isDivisibleBy(dataLength, sectorSize)) {
        throw Error('Unexpected buffer length!');
      }
      return fs.write(fd, data, 0, dataLength, sector * sectorSize, callback);
    }
  };
};


/**
 * @summary Get a fatfs driver from a file
 * @protected
 * @function
 *
 * @param {String} file - file path
 * @param {Function} callback - callback (error, driver)
 *
 * @example
 * driver.createDriverFromFile 'my/file', (error, driver) ->
 *		throw error if error?
 *		console.log(driver)
 */

exports.createDriverFromFile = function(file, callback) {
  if (file == null) {
    throw new errors.ResinMissingParameter('file');
  }
  if (!_.isString(file)) {
    throw new errors.ResinInvalidParameter('file', file, 'not a string');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return async.waterfall([
    function(callback) {
      return fs.open(file, 'r+', callback);
    }, function(fd, callback) {
      return fs.fstat(fd, function(error, stats) {
        if (error != null) {
          return callback(error);
        }
        return callback(null, fd, stats);
      });
    }, function(fd, stats, callback) {
      var driver;
      driver = exports.getDriver(fd, stats.size, settings.sectorSize);
      return callback(null, driver);
    }, function(driver, callback) {
      return callback(null, fatfs.createFileSystem(driver));
    }
  ], callback);
};
