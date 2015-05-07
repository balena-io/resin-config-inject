_ = require('lodash')
chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))
errors = require('resin-errors')
strategy = require('../../../lib/strategies/fat')

describe 'FAT strategy:', ->

	describe '.read()', ->

		it 'should throw if no image', ->
			expect ->
				strategy.read(null, 512, { primary: 1 }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				strategy.read([ 'hello' ], 512, { primary: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no position', ->
			expect ->
				strategy.read('rpi.img', null, { primary: 1 }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if position is not a number', ->
			expect ->
				strategy.read('rpi.img', '512', { primary: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition', ->
			expect ->
				strategy.read('rpi.img', 512, null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if definition is not an object', ->
			expect ->
				strategy.read('rpi.img', 512, 123, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				strategy.read('rpi.img', 512, { primary: 1 }, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				strategy.read('rpi.img', 512, { primary: 1 }, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

	describe '.write()', ->

		it 'should throw if no image', ->
			expect ->
				strategy.write(null, hello: 'world', 512, { primary: 1 }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				strategy.write([ 'hello' ], hello: 'world', 512, { primary: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no config', ->
			expect ->
				strategy.write('rpi.img', null, 512, { primary: 1 }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if config is not an object', ->
			expect ->
				strategy.write('rpi.img', 123, 512, { primary: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no position', ->
			expect ->
				strategy.write('rpi.img', foo: 'bar', null, { primary: 1 }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if position is not a number', ->
			expect ->
				strategy.write('rpi.img', foo: 'bar', '512', { primary: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition', ->
			expect ->
				strategy.write('rpi.img', { foo: 'bar' }, 512, null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if definition is not an object', ->
			expect ->
				strategy.write('rpi.img', { foo: 'bar' }, 512, 123, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				strategy.write('rpi.img', hello: 'world', 512, { primary: 1 }, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				strategy.write('rpi.img', hello: 'world', 512, { primary: 1 }, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

	describe '.writePartition()', ->

		it 'should throw if no image', ->
			expect ->
				strategy.writePartition(null, hello: 'world', { primary: 1 }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				strategy.writePartition([ 'hello' ], hello: 'world', { primary: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no config', ->
			expect ->
				strategy.writePartition('rpi.img', null, { primary: 1 }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if config is an array', ->
			expect ->
				strategy.writePartition('rpi.img', [ hello: 'world' ], { primary: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if config is a number', ->
			expect ->
				strategy.writePartition('rpi.img', 1234, { primary: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if config is a string', ->
			expect ->
				strategy.writePartition('rpi.img', 'hello world', { primary: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition', ->
			expect ->
				strategy.writePartition('rpi.img', { foo: 'bar' }, null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if definition is not an object', ->
			expect ->
				strategy.writePartition('rpi.img', { foo: 'bar' }, 123, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				strategy.writePartition('rpi.img', hello: 'world', { primary: 1 }, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				strategy.writePartition('rpi.img', hello: 'world', { primary: 1 }, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)
