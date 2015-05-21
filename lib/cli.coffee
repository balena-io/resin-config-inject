capitano = require('capitano')
inject = require('./inject')

capitano.command
	signature: '*'
	action: (params, options, done) ->
		console.log '''
			Usage: inject <COMMAND> <OPTIONS>

			    read <image> <partition>             read configuration from an image
			    write <image> <partition> <|config>  write configuration to an image

			Examples:

			    $ inject read ../rpi.img '4:1'
			    $ cat config.json | inject write ../rpi.img '4:1'
			    $ inject write ../rpi.img '4:1' '{"hello":"world"}'
		'''
		return done()

capitano.command
	signature: 'read <image> <partition>'
	action: (params, options, done) ->
		inject.read params.image, params.partition, (error, config) ->
			return done(error) if error?
			console.log(config)
			return done()

capitano.command
	signature: 'write <image> <partition> <|config>'
	action: (params, options, done) ->
		try
			params.config = JSON.parse(params.config)
		catch error
			return done(new Error("Invalid config: #{params.config}"))

		inject.write(params.image, params.config, params.partition, done)

capitano.run process.argv, (error) ->
	if error?
		console.error(error.message)
		process.exit(1)
