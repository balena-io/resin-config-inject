var errors, fs, _;

_ = require('lodash');

fs = require('fs');

errors = require('resin-errors');


/**
 * @summary Check if a number is divisible by another number
 * @protected
 * @function
 *
 * @param {Number} x - x
 * @param {Number} y - y
 *
 * @throws If either x or y are zero.
 *
 * @example
 * utils.isDivisibleBy(4, 2)
 */

exports.isDivisibleBy = function(x, y) {
  if (x === 0 || y === 0) {
    throw new Error('Numbers can\'t be zero');
  }
  return !(x % y);
};


/**
 * @summary Copy a file to specific start point of another file
 * @protected
 * @function
 *
 * @description It uses streams.
 *
 * @param {String} file - input file path
 * @param {String} output - output file path
 * @param {Number} start - byte start
 * @param {Function} callback - callback (error, output)
 *
 * @example
 * utils.streamFileToPosition 'input/file', 'output/file', 1024, (error) ->
 *		throw error if error?
 */

exports.streamFileToPosition = function(file, output, start, callback) {
  if (file == null) {
    throw new errors.ResinMissingParameter('file');
  }
  if (!_.isString(file)) {
    throw new errors.ResinInvalidParameter('file', file, 'not a string');
  }
  if (output == null) {
    throw new errors.ResinMissingParameter('output');
  }
  if (!_.isString(output)) {
    throw new errors.ResinInvalidParameter('output', output, 'not a string');
  }
  if (start == null) {
    throw new errors.ResinMissingParameter('start');
  }
  if (!_.isNumber(start)) {
    throw new errors.ResinInvalidParameter('start', start, 'not a number');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return fs.exists(file, function(exists) {
    var inputStream, outputStream;
    if (!exists) {
      return callback(new Error("File does not exist: " + file));
    }
    inputStream = fs.createReadStream(file);
    inputStream.on('error', callback);
    outputStream = fs.createWriteStream(output, {
      start: start,
      flags: 'r+'
    });
    outputStream.on('error', callback);
    outputStream.on('close', function() {
      return callback(null, output);
    });
    return inputStream.pipe(outputStream);
  });
};
