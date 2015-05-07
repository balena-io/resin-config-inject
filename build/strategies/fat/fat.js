var errors, fs, settings, _;

_ = require('lodash');

fs = require('fs');

errors = require('resin-errors');

settings = require('./settings');


/**
 * @summary Write an config object to a FAT partition
 * @protected
 * @function
 *
 * @param {Object} driver - fatfs driver
 * @param {Object} config - config object
 * @param {Function} callback - callback (error)
 *
 * @example
 * fat.writeConfig driver, { hello: 'world' }, (error) ->
 *		throw error if error?
 */

exports.writeConfig = function(driver, config, callback) {
  var stringifiedConfig;
  if (driver == null) {
    throw new errors.ResinMissingParameter('driver');
  }
  if (config == null) {
    throw new errors.ResinMissingParameter('config');
  }
  if (!_.isPlainObject(config)) {
    throw new errors.ResinInvalidParameter('config', config, 'not an object');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  stringifiedConfig = JSON.stringify(config);
  if (!_.isEmpty(config) && stringifiedConfig === '{}') {
    return callback(new errors.ResinInvalidParameter('config', config, 'not json'));
  }
  return driver.writeFile(settings.configFile, stringifiedConfig, callback);
};


/**
 * @summary List files in a FAT drive
 * @protected
 * @function
 *
 * @param {Object} driver - fatfs driver
 * @param {Function} callback - callback (error, files)
 *
 * @example
 * fat.listFiles driver, (error, files) ->
 *		throw error if error?
 *
 *		for file in files
 *			console.log(fle)
 */

exports.listFiles = function(driver, callback) {
  if (driver == null) {
    throw new errors.ResinMissingParameter('driver');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return driver.readdir('.', callback);
};


/**
 * @summary Check if FAT disk has a config.json file
 * @protected
 * @function
 *
 * @param {Object} driver - fatfs driver
 * @param {Function} callback - callback (error, hasConfig)
 *
 * @example
 * fat.hasConfig driver, (error, hasConfig) ->
 *		throw error if error?
 *		console.log(hasConfig)
 */

exports.hasConfig = function(driver, callback) {
  if (driver == null) {
    throw new errors.ResinMissingParameter('driver');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return exports.listFiles(driver, function(error, files) {
    if (error != null) {
      return callback(error);
    }
    return callback(null, _.includes(files, settings.configFile));
  });
};


/**
 * @summary Read a config file from a FAT disk
 * @protected
 * @function
 *
 * @param {Object} driver - fatfs driver
 * @param {Function} callback - callback (error, config)
 *
 * @example
 * fat.readConfig driver, (error, config) ->
 *		throw error if error?
 *		console.log(config)
 */

exports.readConfig = function(driver, callback) {
  if (driver == null) {
    throw new errors.ResinMissingParameter('driver');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return exports.hasConfig(driver, function(error, hasConfig) {
    if (error != null) {
      return callback(error);
    }
    if (!hasConfig) {
      return callback(new Error('No config.json'));
    }
    return driver.readFile(settings.configFile, {
      encoding: 'utf8'
    }, function(error, config) {
      if (error != null) {
        return callback(error);
      }
      try {
        return callback(null, JSON.parse(config));
      } catch (_error) {
        return callback(new Error('Invalid config.json'));
      }
    });
  });
};
