fs = require('fs')
_ = require('lodash')
chai = require('chai')
expect = chai.expect
errors = require('resin-errors')
sinon = require('sinon')
chai.use(require('sinon-chai'))
utils = require('../../../lib/strategies/fat/utils')

describe 'Utils:', ->

	describe '.isDivisibleBy()', ->

		it 'should return true if the number is divisible', ->
			expect(utils.isDivisibleBy(4, 2)).to.be.true
			expect(utils.isDivisibleBy(6, 3)).to.be.true
			expect(utils.isDivisibleBy(1, 1)).to.be.true

		it 'should return false if the number is not divisible', ->
			expect(utils.isDivisibleBy(4, 3)).to.be.false
			expect(utils.isDivisibleBy(6, 4)).to.be.false
			expect(utils.isDivisibleBy(1, 5)).to.be.false

		it 'should throw if any number is zero', ->
			expect ->
				utils.isDivisibleBy(0, 2)
			.to.throw('Numbers can\'t be zero')

			expect ->
				utils.isDivisibleBy(2, 0)
			.to.throw('Numbers can\'t be zero')

	describe '.streamFileToPosition()', ->

		it 'should throw if no file', ->
			expect ->
				utils.streamFileToPosition(null, 'output', 512, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if file is not a string', ->
			expect ->
				utils.streamFileToPosition(123, 'output', 512, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no output', ->
			expect ->
				utils.streamFileToPosition('input', null, 512, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if output is not a string', ->
			expect ->
				utils.streamFileToPosition('start', 123, 512, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no start', ->
			expect ->
				utils.streamFileToPosition('input', 'output', null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if start is not a number', ->
			expect ->
				utils.streamFileToPosition('start', 'output', '512', _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				utils.streamFileToPosition('input', 'output', 512, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				utils.streamFileToPosition('start', 'output', 512, 123)
			.to.throw(errors.ResinInvalidParameter)

		describe 'given input does not exist', ->

			beforeEach ->
				@fsExistsStub = sinon.stub(fs, 'exists')
				@fsExistsStub.yields(false)

			afterEach ->
				@fsExistsStub.restore()

			it 'should return an error', (done) ->
				utils.streamFileToPosition 'hello', 'output', 512, (error) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('File does not exist: hello')
					done()
