_ = require('lodash')
fs = require('fs')
chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))
errors = require('resin-errors')
bootRecord = require('../lib/boot-record')

# Dumped MBR from real images downloaded from dashboard.resin.io
rpiMBR = fs.readFileSync('./tests/mbr/rpi.data')
rpi2MBR = fs.readFileSync('./tests/mbr/rpi2.data')
bbbMBR = fs.readFileSync('./tests/mbr/bbb.data')

describe 'Boot Record:', ->

	describe '.read()', ->

		it 'should throw if no image', ->
			expect ->
				bootRecord.read(null, 0, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				bootRecord.read(123, 0, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if position is not a number', ->
			expect ->
				bootRecord.read('image', '512', _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if position is not a positive number', ->
			expect ->
				bootRecord.read('image', -512, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should not throw if no position', ->
			expect ->
				bootRecord.read('image', null, _.noop)
			.to.not.throw()

		it 'should throw if no callback', ->
			expect ->
				bootRecord.read('image', 0, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				bootRecord.read('image', 0, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

	describe '.parse()', ->

		it 'should throw if no buffer', ->
			expect ->
				bootRecord.parse(null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if buffer is not a buffer', ->
			expect ->
				bootRecord.parse(123)
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a non valid MBR', ->

			beforeEach ->
				@mbr = new Buffer(512)
				@mbr.fill(0)

			it 'should throw an error', ->
				expect =>
					bootRecord.parse(@mbr)
				.to.throw(Error)

		describe 'given a rpi MBR', ->

			beforeEach ->
				@mbr = rpiMBR

			it 'should have a partitions array', ->
				result = bootRecord.parse(@mbr)
				expect(_.isArray(result.partitions)).to.be.true

		describe 'given a rpi2 MBR', ->

			beforeEach ->
				@mbr = rpi2MBR

			it 'should have a partitions array', ->
				result = bootRecord.parse(@mbr)
				expect(_.isArray(result.partitions)).to.be.true

		describe 'given a bbb MBR', ->

			beforeEach ->
				@mbr = bbbMBR

			it 'should have a partitions array', ->
				result = bootRecord.parse(@mbr)
				expect(_.isArray(result.partitions)).to.be.true

	describe '.getExtended()', ->

		it 'should throw if no image', ->
			expect ->
				bootRecord.getExtended(null, 0, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				bootRecord.getExtended(123, 0, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no position', ->
			expect ->
				bootRecord.getExtended('image', null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if position is not a number', ->
			expect ->
				bootRecord.getExtended('image', '512', _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if position is not a positive number', ->
			expect ->
				bootRecord.getExtended('image', -512, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				bootRecord.getExtended('image', 0, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				bootRecord.getExtended('image', 0, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a non ebr is read', ->

			beforeEach ->
				@bootRecordReadStub = sinon.stub(bootRecord, 'read')
				@bootRecordReadStub.yields(null, new Buffer(512))

			afterEach ->
				@bootRecordReadStub.restore()

			it 'should return undefined', (done) ->
				bootRecord.getExtended 'image', 512, (error, ebr) ->
					expect(error).to.not.exist
					expect(ebr).to.be.undefined
					done()

		describe 'given a valid ebr is read', ->

			beforeEach ->
				@bootRecordReadStub = sinon.stub(bootRecord, 'read')
				@bootRecordReadStub.yields(null, rpiMBR)

			afterEach ->
				@bootRecordReadStub.restore()

			it 'should return a parsed boot record', (done) ->
				bootRecord.getExtended 'image', 512, (error, ebr) ->
					expect(error).to.not.exist
					expect(ebr).to.exist
					expect(ebr.partitions).to.be.an.instanceof(Array)
					done()

		describe 'given there was an error reading the ebr', ->

			beforeEach ->
				@bootRecordReadStub = sinon.stub(bootRecord, 'read')
				@bootRecordReadStub.yields(new Error('read error'))

			afterEach ->
				@bootRecordReadStub.restore()

			it 'should return the error', (done) ->
				bootRecord.getExtended 'image', 512, (error, ebr) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('read error')
					expect(ebr).to.not.exist
					done()

	describe '.getMaster()', ->

		it 'should throw if no image', ->
			expect ->
				bootRecord.getMaster(null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				bootRecord.getMaster(123, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				bootRecord.getMaster('image', null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				bootRecord.getMaster('image', [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		describe 'given an invalid mbr is read', ->

			beforeEach ->
				@bootRecordReadStub = sinon.stub(bootRecord, 'read')
				@bootRecordReadStub.yields(null, new Buffer(512))

			afterEach ->
				@bootRecordReadStub.restore()

			it 'should return an error', (done) ->
				bootRecord.getMaster 'image', (error, mbr) ->
					expect(error).to.be.an.instanceof(Error)
					expect(mbr).to.not.exist
					done()

		describe 'given a valid mbr is read', ->

			beforeEach ->
				@bootRecordReadStub = sinon.stub(bootRecord, 'read')
				@bootRecordReadStub.yields(null, rpiMBR)

			afterEach ->
				@bootRecordReadStub.restore()

			it 'should return a parsed boot record', (done) ->
				bootRecord.getMaster 'image', (error, mbr) ->
					expect(error).to.not.exist
					expect(mbr).to.exist
					expect(mbr.partitions).to.be.an.instanceof(Array)
					done()

		describe 'given there was an error reading the ebr', ->

			beforeEach ->
				@bootRecordReadStub = sinon.stub(bootRecord, 'read')
				@bootRecordReadStub.yields(new Error('read error'))

			afterEach ->
				@bootRecordReadStub.restore()

			it 'should return the error', (done) ->
				bootRecord.getMaster 'image', (error, mbr) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('read error')
					expect(mbr).to.not.exist
					done()
