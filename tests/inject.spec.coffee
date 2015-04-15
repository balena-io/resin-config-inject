_ = require('lodash')
chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))
errors = require('resin-errors')
inject = require('../lib/inject')
image = require('../lib/image')
utils = require('../lib/utils')
settings = require('../lib/settings')
partition = require('../lib/partition')

describe 'Inject:', ->

	describe '.write()', ->

		it 'should throw if no image', ->
			expect ->
				inject.write(null, hello: 'world', 1, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				inject.write([ 'hello' ], hello: 'world', 1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no config', ->
			expect ->
				inject.write('rpi.img', null, 1, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if config is an array', ->
			expect ->
				inject.write('rpi.img', [ hello: 'world' ], 1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if config is a number', ->
			expect ->
				inject.write('rpi.img', 1234, 1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if config is a string', ->
			expect ->
				inject.write('rpi.img', 'hello world', 1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition', ->
			expect ->
				inject.write('rpi.img', hello: 'world', null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if definition is not a number or string', ->
			expect ->
				inject.write('rpi.img', hello: 'world', [ 1234 ], _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				inject.write('rpi.img', hello: 'world', 1, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				inject.write('rpi.img', hello: 'world', 1, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a non JSON object', ->

			beforeEach ->
				@object = hello: _.noop

			it 'should throw an error', ->
				expect =>
					inject.write('rpi.img', @object, '4:1', _.noop)
				.to.throw(errors.ResinInvalidParameter)

	describe '.read()', ->

		beforeEach ->
			@partitionGetPositionStub = sinon.stub(partition, 'getPosition')
			@partitionGetPositionStub.yields(null, 512)

		afterEach ->
			@partitionGetPositionStub.restore()

		it 'should throw if no image', ->
			expect ->
				inject.read(null, 1, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				inject.read([ 'hello' ], 1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition', ->
			expect ->
				inject.read('rpi.img', null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if definition is not a number', ->
			expect ->
				inject.read('rpi.img', [ '1234' ], _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				inject.read('rpi.img', 1, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				inject.read('rpi.img', 1, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a correct config buffer is returned', ->

			beforeEach ->
				@imageReadBufferFromPositionStub = sinon.stub(image, 'readBufferFromPosition')
				@imageReadBufferFromPositionStub.yields(null, utils.configToBuffer(hello: 'world', 64))

			afterEach ->
				@imageReadBufferFromPositionStub.restore()

			it 'should return the parsed object', (done) ->
				inject.read 'rpi.img', '4:1', (error, config) ->
					expect(error).to.not.exist
					expect(config).to.deep.equal(hello: 'world')
					done()

		describe 'given an error when reading the image', ->

			beforeEach ->
				@imageReadBufferFromPositionStub = sinon.stub(image, 'readBufferFromPosition')
				@imageReadBufferFromPositionStub.yields(new Error('read error'))

			afterEach ->
				@imageReadBufferFromPositionStub.restore()

			it 'should return the error', (done) ->
				inject.read 'rpi.img', '4:1', (error, config) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('read error')
					expect(config).to.not.exist
					done()

		describe 'given a non json config buffer is returned', ->

			beforeEach ->
				@imageReadBufferFromPositionStub = sinon.stub(image, 'readBufferFromPosition')
				@imageReadBufferFromPositionStub.yields(null, new Buffer(1234))

			afterEach ->
				@imageReadBufferFromPositionStub.restore()

			it 'should return an error', (done) ->
				inject.read 'rpi.img', '4:1', (error, config) ->
					expect(error).to.be.an.instanceof(errors.ResinInvalidParameter)
					expect(config).to.not.exist
					done()
