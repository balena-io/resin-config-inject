_ = require('lodash')
chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))
errors = require('resin-errors')
fat = require('../../../lib/strategies/fat/fat')
settings = require('../../../lib/strategies/fat/settings')

describe 'FAT:', ->

	describe '.writeConfig()', ->

		it 'should throw if no driver', ->
			expect ->
				fat.writeConfig(null, { foo: 'bar' }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if no config', ->
			expect ->
				fat.writeConfig({}, null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if config is not an object', ->
			expect ->
				fat.writeConfig({}, 123, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				fat.writeConfig({}, { foo: 'bar' }, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				fat.writeConfig({}, { foo: 'bar' }, 123)
			.to.throw(errors.ResinInvalidParameter)

		it 'should write the config file', ->
			driver =
				writeFile: sinon.spy()

			fat.writeConfig(driver, { hello: 'world' }, _.noop)
			expect(driver.writeFile).to.have.been.calledOnce
			expect(driver.writeFile).to.have.been.calledWith(settings.configFile, '{"hello":"world"}', _.noop)

		describe 'given a non json config', ->

			beforeEach ->
				@config = { hello: _.noop }

			it 'should return an error', (done) ->
				fat.writeConfig {}, @config, (error) ->
					expect(error).to.be.an.instanceof(errors.ResinInvalidParameter)
					done()

	describe '.listFiles()', ->

		it 'should throw if no driver', ->
			expect ->
				fat.listFiles(null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if no callback', ->
			expect ->
				fat.listFiles({}, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				fat.listFiles({}, 123)
			.to.throw(errors.ResinInvalidParameter)

		it 'should list the current directory', ->
			driver =
				readdir: sinon.spy()

			fat.listFiles(driver, _.noop)
			expect(driver.readdir).to.have.been.calledOnce
			expect(driver.readdir).to.have.been.calledWith('.', _.noop)

	describe '.hasConfig()', ->

		it 'should throw if no driver', ->
			expect ->
				fat.hasConfig(null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if no callback', ->
			expect ->
				fat.hasConfig({}, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				fat.hasConfig({}, 123)
			.to.throw(errors.ResinInvalidParameter)

		describe 'given it has a config.json file', ->

			beforeEach ->
				@fatListFilesStub = sinon.stub(fat, 'listFiles')
				@fatListFilesStub.yields(null, [ 'hello.txt', 'config.json' ])

			afterEach ->
				@fatListFilesStub.restore()

			it 'should return true', (done) ->
				fat.hasConfig {}, (error, hasConfig) ->
					expect(error).to.not.exist
					expect(hasConfig).to.be.true
					done()

		describe 'given it does not have a config.json file', ->

			beforeEach ->
				@fatListFilesStub = sinon.stub(fat, 'listFiles')
				@fatListFilesStub.yields(null, [ 'hello.txt', 'foo.bar' ])

			afterEach ->
				@fatListFilesStub.restore()

			it 'should return false', (done) ->
				fat.hasConfig {}, (error, hasConfig) ->
					expect(error).to.not.exist
					expect(hasConfig).to.be.false
					done()

		describe 'given there was an error listing the files', ->

			beforeEach ->
				@fatListFilesStub = sinon.stub(fat, 'listFiles')
				@fatListFilesStub.yields(new Error('list error'))

			afterEach ->
				@fatListFilesStub.restore()

			it 'should return an error', (done) ->
				fat.hasConfig {}, (error, hasConfig) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('list error')
					expect(hasConfig).to.not.exist
					done()

	describe '.readConfig()', ->

		it 'should throw if no driver', ->
			expect ->
				fat.readConfig(null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if no callback', ->
			expect ->
				fat.readConfig({}, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				fat.readConfig({}, 123)
			.to.throw(errors.ResinInvalidParameter)

		describe 'given it does not have a config.json', ->

			beforeEach ->
				@fatHasConfigStub = sinon.stub(fat, 'hasConfig')
				@fatHasConfigStub.yields(null, false)

			afterEach ->
				@fatHasConfigStub.restore()

			it 'should return an error', (done) ->
				fat.readConfig {}, (error, config) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('No config.json')
					expect(config).to.not.exist
					done()

		describe 'given there was an error checking the config.json', ->

			beforeEach ->
				@fatHasConfigStub = sinon.stub(fat, 'hasConfig')
				@fatHasConfigStub.yields(new Error('list error'))

			afterEach ->
				@fatHasConfigStub.restore()

			it 'should return an error', (done) ->
				fat.readConfig {}, (error, config) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('list error')
					expect(config).to.not.exist
					done()

		describe 'given it does have a config.json', ->

			beforeEach ->
				@fatHasConfigStub = sinon.stub(fat, 'hasConfig')
				@fatHasConfigStub.yields(null, true)

			afterEach ->
				@fatHasConfigStub.restore()

			describe 'given the read file is valid', ->

				beforeEach ->
					@driver = {}
					@driver.readFile = (file, options, callback) ->
						return callback(null, '{"hello":"world"}')

				it 'should return the parsed config.json', (done) ->
					fat.readConfig @driver, (error, config) ->
						expect(error).to.not.exist
						expect(config).to.deep.equal(hello: 'world')
						done()

			describe 'given the read file is not valid', ->

				beforeEach ->
					@driver = {}
					@driver.readFile = (file, options, callback) ->
						return callback(null, '1234asdf')

				it 'should return an error', (done) ->
					fat.readConfig @driver, (error, config) ->
						expect(error).to.be.an.instanceof(Error)
						expect(error.message).to.equal('Invalid config.json')
						expect(config).to.not.exist
						done()

			describe 'given there was an error reading the config file', ->

				beforeEach ->
					@driver = {}
					@driver.readFile = (file, options, callback) ->
						return callback(new Error('read error'))

				it 'should return the error', (done) ->
					fat.readConfig @driver, (error, config) ->
						expect(error).to.be.an.instanceof(Error)
						expect(error.message).to.equal('read error')
						expect(config).to.not.exist
						done()
