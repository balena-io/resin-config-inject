var NULL_CHARACTER, errors, _;

_ = require('lodash');

errors = require('resin-errors');


/**
 * @summary Get the byte length of a string.
 * @private
 * @function
 *
 * @param {String} string - string
 * @returns {Number} the string byte length.
 *
 * @throws Will throw if input is not a string.
 *
 * @example
 * utils.getStringByteLength('hello') is 5
 * True
 */

exports.getStringByteLength = function(string) {
  if (string == null) {
    throw new errors.ResinMissingParameter('string');
  }
  if (!_.isString(string)) {
    throw new errors.ResinInvalidParameter('string', string, 'not a string');
  }
  return Buffer.byteLength(string, 'utf8');
};


/**
 * @summary Get a buffer filled with null bytes
 * @private
 * @function
 *
 * @param {Number} size - size
 * @returns {Buffer} the buffer with null bytes
 *
 * @throws Will throw if size is a negative number.
 *
 * @example
 * nullBuffer = utils.getEmptyBuffer(128)
 */

exports.getEmptyBuffer = function(size) {
  var result;
  if (size == null) {
    throw new errors.ResinMissingParameter('size');
  }
  if (!_.isNumber(size)) {
    throw new errors.ResinInvalidParameter('size', size, 'not a number');
  }
  if (size < 0) {
    throw new errors.ResinInvalidParameter('size', size, 'negative number');
  }
  result = new Buffer(size);
  result.fill(0);
  return result;
};


/**
 * @summary Say whether a buffer only contains null bytes
 * @protected
 * @function
 *
 * @param {Buffer} buffer - buffer
 * @returns {Boolean} whether the buffer contains only null bytes
 *
 * @example
 * utils.isNullBuffer(new Buffer('1234')) is False
 */

exports.isNullBuffer = function(buffer) {
  if (buffer == null) {
    throw new errors.ResinMissingParameter('buffer');
  }
  if (!Buffer.isBuffer(buffer)) {
    throw new errors.ResinInvalidParameter('buffer', buffer, 'not a buffer');
  }
  return _.all(buffer.toJSON(), function(byte) {
    return byte === 0;
  });
};


/**
 * @summary Convert an Object into a buffer.
 * @protected
 * @function
 *
 * @description It fills the remaining space with null bytes.
 *
 * @param {Object} config - config object
 * @param {Number} size - buffer size
 * @returns {Buffer} the converted buffer
 *
 * @throws Will throw if size is a negative number.
 * @throws Will throw if the config bytes length is greater than the size.
 * @throws Will throw if config cannot be stringified.
 *
 * @example
 *	data = utils.configToBuffer({ hello: 'world' }, 128)
 */

exports.configToBuffer = function(config, size) {
  var configBytes, result, stringifiedConfig;
  if (config == null) {
    throw new errors.ResinMissingParameter('config');
  }
  if (size == null) {
    throw new errors.ResinMissingParameter('size');
  }
  if (!_.isNumber(size)) {
    throw new errors.ResinInvalidParameter('size', size, 'not a number');
  }
  if (size < 0) {
    throw new errors.ResinInvalidParameter('size', size, 'negative number');
  }
  stringifiedConfig = JSON.stringify(config);
  if (stringifiedConfig === '{}' && !_.isEmpty(config)) {
    throw new errors.ResinInvalidParameter('config', config, 'not json');
  }
  configBytes = exports.getStringByteLength(stringifiedConfig);
  if (configBytes > size) {
    throw new Error("Out of bounds. Config is " + configBytes + " bytes.");
  }
  result = exports.getEmptyBuffer(size);
  result.write(stringifiedConfig);
  return result;
};

NULL_CHARACTER = '\u0000';


/**
 * @summary Convert an buffer into a config object.
 * @protected
 * @function
 *
 * @param {Buffer} buffer - buffer
 * @returns {Object} the converted object
 *
 * @throws Will throw if buffer contains only null bytes.
 * @throws Will throw if buffer contents are not JSON parseable.
 *
 * @example
 *	config = utils.bufferToConfig(data)
 */

exports.bufferToConfig = function(buffer) {
  var endOfString, result;
  if (buffer == null) {
    throw new errors.ResinMissingParameter('buffer');
  }
  if (exports.isNullBuffer(buffer)) {
    throw new errors.ResinInvalidParameter('buffer', buffer, 'null buffer');
  }
  result = buffer.toString();
  endOfString = _.indexOf(result, NULL_CHARACTER);
  try {
    return JSON.parse(result.slice(0, endOfString));
  } catch (_error) {
    throw new errors.ResinInvalidParameter('buffer', buffer, 'invalid config');
  }
};
