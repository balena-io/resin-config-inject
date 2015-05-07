_ = require('lodash')
chai = require('chai')
expect = chai.expect
errors = require('resin-errors')
driver = require('../../../lib/strategies/fat/driver')

describe 'FAT Driver:', ->

	describe '.getDriver()', ->

		it 'should throw if no fd', ->
			expect ->
				driver.getDriver(null, 2048, 512)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if no size', ->
			expect ->
				driver.getDriver({}, null, 512)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if size is not a number', ->
			expect ->
				driver.getDriver({}, '2048', 512)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if sector size is not a number', ->
			expect ->
				driver.getDriver({}, 2048, '512')
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a valid driver', ->

			beforeEach ->
				@driver = driver.getDriver({}, 2048, 512)

			it 'should have .sectorSize', ->
				expect(@driver.sectorSize).to.equal(512)

			it 'should have .numSectors', ->
				expect(@driver.numSectors).to.equal(4)

	describe '.createDriverFromFile()', ->

		it 'should throw if no path', ->
			expect ->
				driver.createDriverFromFile(null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if path is not a string', ->
			expect ->
				driver.createDriverFromFile(123, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				driver.createDriverFromFile('input', null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				driver.createDriverFromFile('input', 123)
			.to.throw(errors.ResinInvalidParameter)
