_ = require('lodash')
chai = require('chai')
expect = chai.expect
errors = require('resin-errors')
image = require('../lib/image')

describe 'Image:', ->

	describe '.writeBufferToPosition()', ->

		it 'should throw if no image', ->
			expect ->
				image.writeBufferToPosition(null, new Buffer('1234'), 0, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				image.writeBufferToPosition([ 'hello' ], new Buffer('1234'), 0, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no data', ->
			expect ->
				image.writeBufferToPosition('rpi.img', null, 0, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if data is not a buffer', ->
			expect ->
				image.writeBufferToPosition('rpi.img', '1234', 0, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no position', ->
			expect ->
				image.writeBufferToPosition('rpi.img', new Buffer('1234'), null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if position is not a number', ->
			expect ->
				image.writeBufferToPosition('rpi.img', new Buffer('1234'), '1234', _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if position is a negative number', ->
			expect ->
				image.writeBufferToPosition('rpi.img', new Buffer('1234'), -1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				image.writeBufferToPosition('rpi.img', new Buffer('1234'), 0, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				image.writeBufferToPosition('rpi.img', new Buffer('1234'), 0, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

	describe '.readBufferFromPosition()', ->

		it 'should throw if no image', ->
			expect ->
				image.readBufferFromPosition(null, 0, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				image.readBufferFromPosition([ 'hello' ], 0, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no position', ->
			expect ->
				image.readBufferFromPosition('rpi.img', null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if position is not a number', ->
			expect ->
				image.readBufferFromPosition('rpi.img', '1234', _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if position is a negative number', ->
			expect ->
				image.readBufferFromPosition('rpi.img', -1, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				image.readBufferFromPosition('rpi.img', 0, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				image.readBufferFromPosition('rpi.img', 0, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)
