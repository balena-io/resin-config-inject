chai = require('chai')
expect = chai.expect
settings = require('../../../lib/strategies/fat/settings')

describe 'Settings:', ->

	describe '.sectorSize', ->

		it 'should exist', ->
			expect(settings.sectorSize).to.exist

		it 'should be a number', ->
			expect(settings.sectorSize).to.be.a('number')

		it 'should be higher than 0', ->
			expect(settings.sectorSize).to.be.above(0)

		# http://www.exploringbinary.com/ten-ways-to-check-if-an-integer-is-a-power-of-two-in-c/
		isPowerOf2 = (number) ->
			return not (number & (number - 1))

		it 'should be a power of 2', ->
			expect(isPowerOf2(settings.sectorSize)).to.be.true

	describe '.configFile', ->

		it 'should exist', ->
			expect(settings.configFile).to.exist

		it 'should be a string', ->
			expect(settings.configFile).to.be.a('string')

		it 'should not be empty', ->
			expect(settings.configFile).to.have.length.above(0)
