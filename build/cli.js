var capitano, inject;

capitano = require('capitano');

inject = require('./inject');

capitano.command({
  signature: '*',
  action: function(params, options, done) {
    console.log('Usage: inject <COMMAND> <OPTIONS>\n\n    read <image> <partition>             read configuration from an image\n    write <image> <partition> <|config>  write configuration to an image\n\nExamples:\n\n    $ inject read ../rpi.img \'4:1\'\n    $ cat config.json | inject write ../rpi.img \'4:1\'\n    $ inject write ../rpi.img \'4:1\' \'{"hello":"world"}\'');
    return done();
  }
});

capitano.command({
  signature: 'read <image> <partition>',
  action: function(params, options, done) {
    return inject.read(params.image, params.partition, function(error, config) {
      if (error != null) {
        return done(error);
      }
      console.log(config);
      return done();
    });
  }
});

capitano.command({
  signature: 'write <image> <partition> <|config>',
  action: function(params, options, done) {
    var error;
    try {
      params.config = JSON.parse(params.config);
    } catch (_error) {
      error = _error;
      return done(new Error("Invalid config: " + params.config));
    }
    return inject.write(params.image, params.config, params.partition, done);
  }
});

capitano.run(process.argv, function(error) {
  if (error != null) {
    console.error(error.message);
    return process.exit(1);
  }
});
