_ = require('lodash')
chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))
errors = require('resin-errors')
inject = require('../lib/inject')
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

	describe '.writePartition()', ->

		it 'should throw if no image', ->
			expect ->
				inject.writePartition(null, hello: 'world', 1, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				inject.writePartition([ 'hello' ], hello: 'world', 1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no config', ->
			expect ->
				inject.writePartition('rpi.img', null, 1, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if config is an array', ->
			expect ->
				inject.writePartition('rpi.img', [ hello: 'world' ], 1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if config is a number', ->
			expect ->
				inject.writePartition('rpi.img', 1234, 1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if config is a string', ->
			expect ->
				inject.writePartition('rpi.img', 'hello world', 1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition', ->
			expect ->
				inject.writePartition('rpi.img', hello: 'world', null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if definition is not a number or string', ->
			expect ->
				inject.writePartition('rpi.img', hello: 'world', [ 1234 ], _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				inject.writePartition('rpi.img', hello: 'world', 1, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				inject.writePartition('rpi.img', hello: 'world', 1, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)
