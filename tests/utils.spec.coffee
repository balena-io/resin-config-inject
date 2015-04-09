_ = require('lodash')
chai = require('chai')
expect = chai.expect
errors = require('resin-errors')
utils = require('../lib/utils')

describe 'Utils:', ->

	describe '.getStringByteLength()', ->

		it 'should throw if string is missing', ->
			expect ->
				utils.getStringByteLength()
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if parameter is not a string', ->
			expect ->
				utils.getStringByteLength([ 1234 ])
			.to.throw(errors.ResinInvalidParameter)

		it 'should get the byte length of any string', ->
			expect(utils.getStringByteLength('hello')).to.equal(5)
			expect(utils.getStringByteLength('hey there')).to.equal(9)

		it 'should return 0 for an empty string', ->
			expect(utils.getStringByteLength('')).to.equal(0)

	describe '.getEmptyBuffer()', ->

		it 'should throw if size is missing', ->
			expect ->
				utils.getEmptyBuffer()
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if size is not a number', ->
			expect ->
				utils.getEmptyBuffer('17')
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if size is a negative number', ->
			expect ->
				utils.getEmptyBuffer(-128)
			.to.throw(errors.ResinInvalidParameter)

		it 'should create a buffer with null bytes', ->
			result = utils.getEmptyBuffer(64)
			expect(utils.isNullBuffer(result)).to.be.true

	describe '.isNullBuffer()', ->

		it 'should throw if buffer is missing', ->
			expect ->
				utils.isNullBuffer()
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if buffer is not a buffer', ->
			expect ->
				utils.isNullBuffer(1234)
			.to.throw(errors.ResinInvalidParameter)

		it 'should return true for an empty buffer', ->
			expect(utils.isNullBuffer(utils.getEmptyBuffer(128))).to.be.true

		it 'should return false for a non empty buffer', ->
			expect(utils.isNullBuffer(new Buffer('hello'))).to.be.false

	describe '.configToBuffer()', ->

		it 'should throw if no config', ->
			expect ->
				utils.configToBuffer(undefined, 128)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if size is missing', ->
			expect ->
				utils.configToBuffer(hello: 'world')
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if size is not a number', ->
			expect ->
				utils.configToBuffer(hello: 'world', '17')
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if size is a negative number', ->
			expect ->
				utils.configToBuffer(hello: 'world', -128)
			.to.throw(errors.ResinInvalidParameter)

		it 'should write a small object', ->
			buffer = utils.configToBuffer(hello: 'world', 20)
			expect(buffer.toString()).to.equal('{\"hello\":\"world\"}\u0000\u0000\u0000')

		it 'should throw an error if data exceeds size', ->
			expect ->
				utils.configToBuffer(hello: 'world', 16)
			.to.throw('Out of bounds. Config is 17 bytes')

		it 'should not throw if config fits exactly', ->
			expect ->
				result = utils.configToBuffer(hello: 'worl', 16)
				expect(result.toString()).to.equal('{\"hello\":\"worl\"}')
			.to.not.throw()

		it 'should throw if object cannot be converted to json', ->
			expect ->
				utils.configToBuffer(hello: _.noop, 16)
			.to.throw(errors.ResinInvalidParameter)

		it 'should not throw if object is empty', ->
			expect ->
				utils.configToBuffer({}, 16)
			.to.not.throw(errors.ResinInvalidParameter)

	describe '.bufferToConfig()', ->

		it 'should throw if no buffer', ->
			expect ->
				utils.bufferToConfig()
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if empty buffer', ->
			expect ->
				utils.bufferToConfig(utils.getEmptyBuffer(64))
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a small data buffer', ->

			beforeEach ->
				@buffer = utils.configToBuffer(hello: 'world', 20)

			it 'should read and parse the JSON contents', ->
				expect(utils.bufferToConfig(@buffer)).to.deep.equal
					hello: 'world'

		describe 'given an out of bounds buffer', ->

			beforeEach ->
				@buffer = new Buffer('{\"hello\":\"worl}')

			it 'should throw an error', ->
				expect =>
					utils.bufferToConfig(@buffer)
				.to.throw(errors.ResinInvalidParameter)
