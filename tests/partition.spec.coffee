_ = require('lodash')
chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))
errors = require('resin-errors')
partition = require('../lib/partition')
bootRecord = require('../lib/boot-record')

describe 'Partition:', ->

	describe '.parse()', ->

		it 'should throw an error if no input', ->
			expect ->
				partition.parse(null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw an error if input it not a string nor a number', ->
			expect ->
				partition.parse([ '123' ])
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a single primary partition', ->

			describe 'given is described as a number', ->

				beforeEach ->
					@partition = 4

				it 'should return the correct representation', ->
					expect(partition.parse(@partition)).to.deep.equal
						primary: 4

			describe 'given is described as a string', ->

				beforeEach ->
					@partition = '4'

				it 'should return the correct representation', ->
					expect(partition.parse(@partition)).to.deep.equal
						primary: 4

		describe 'given a primary and logical partition', ->

			beforeEach ->
				@partition = '3:1'

			it 'should return the correct representation', ->
				expect(partition.parse(@partition)).to.deep.equal
					primary: 3
					logical: 1

		describe 'given non parseable primary number', ->

			beforeEach ->
				@partition = 'hello'

			it 'should throw an error', ->
				expect =>
					partition.parse(@partition)
				.to.throw('Invalid primary partition: hello.')

		describe 'given non parseable logical number', ->

			beforeEach ->
				@partition = '1:hello'

			it 'should throw an error', ->
				expect =>
					partition.parse(@partition)
				.to.throw('Invalid logical partition: hello.')

		describe 'given an empty string', ->

			beforeEach ->
				@partition = ''

			it 'should throw an error', ->
				expect =>
					partition.parse(@partition)
				.to.throw(errors.ResinInvalidParameter)

		describe 'given multiple separators', ->

			beforeEach ->
				@partition = '3::1'

			it 'should throw an error', ->
				expect =>
					partition.parse(@partition)
				.to.throw(errors.ResinInvalidParameter)

	describe '.getPartition()', ->

		it 'should throw if no record', ->
			expect ->
				partition.getPartition(null, 1)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if record.partitions is missing', ->
			expect ->
				partition.getPartition({}, 1)
			.to.throw(errors.ResinMissingOption)

		it 'should throw if record.partitions is not an array', ->
			expect ->
				partition.getPartition({ partitions: 123 }, 1)
			.to.throw(errors.ResinInvalidOption)

		it 'should throw if no number', ->
			expect ->
				partition.getPartition({ partitions: [] }, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if number is not a number', ->
			expect ->
				partition.getPartition({ partitions: [] }, 'hello')
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if number is not > 0', ->
			expect ->
				partition.getPartition({ partitions: [] }, 0)
			.to.throw(errors.ResinInvalidParameter)

			expect ->
				partition.getPartition({ partitions: [] }, -5)
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a record with partitions', ->

			beforeEach ->
				@record =
					partitions: [
						{ info: 'first' }
						{ info: 'second' }
					]

			it 'should retrieve an existing partition', ->
				result = partition.getPartition(@record, 1)
				expect(result.info).to.equal('first')

			it 'should throw if partition does not exist', ->
				expect =>
					partition.getPartition(@record, 5)
				.to.throw('Partition not found: 5.')

	describe '.getPartitionOffset()', ->

		it 'should throw if no partition', ->
			expect ->
				partition.getPartitionOffset(null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if partition.firstLBA is missing', ->
			expect ->
				partition.getPartitionOffset({})
			.to.throw(errors.ResinMissingOption)

		it 'should throw if partition.firstLBA is not a number', ->
			expect ->
				partition.getPartitionOffset({ firstLBA: 'hello' })
			.to.throw(errors.ResinInvalidOption)

		it 'should multiply firstLBA with 512', ->
			result = partition.getPartitionOffset(firstLBA: 512)
			expect(result).to.equal(262144)

	describe '.getPartitionSize()', ->

		it 'should throw if no partition', ->
			expect ->
				partition.getPartitionSize(null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if no partition.sectors', ->
			expect ->
				partition.getPartitionSize({})
			.to.throw(errors.ResinMissingOption)

		it 'should throw if partition.sectors is not a number', ->
			expect ->
				partition.getPartitionSize({ sectors: '123' })
			.to.throw(errors.ResinInvalidOption)

		describe 'given a raspberry pi 1 config partition', ->

			beforeEach ->
				@partition =
					sectors: 8192

			it 'should return the correct byte size', ->
				expect(partition.getPartitionSize(@partition)).to.equal(4194304)

	describe '.getPartitionFromDefinition()', ->

		it 'should throw if no image', ->
			expect ->
				partition.getPartitionFromDefinition(null, { primary: 3, logical: 1 }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				partition.getPartitionFromDefinition(123, { primary: 3, logical: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition', ->
			expect ->
				partition.getPartitionFromDefinition('image', null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if definition is not an object', ->
			expect ->
				partition.getPartitionFromDefinition('image', [ 'hello' ], _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition.primary', ->
			expect ->
				partition.getPartitionFromDefinition('image', { logical: 1 }, _.noop)
			.to.throw(errors.ResinMissingOption)

		it 'should throw if no callback', ->
			expect ->
				partition.getPartitionFromDefinition('image', { primary: 3, logical: 1 }, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				partition.getPartitionFromDefinition('image', { primary: 3, logical: 1 }, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		describe 'given an invalid primary partition', ->

			beforeEach ->
				@bootRecordGetMasterStub = sinon.stub(bootRecord, 'getMaster')
				@bootRecordGetMasterStub.yields null,
					partitions: [
						{ firstLBA: 256, info: 'first' }
						{ firstLBA: 512, info: 'second' }
					]

			afterEach ->
				@bootRecordGetMasterStub.restore()

			it 'should return an error', (done) ->
				partition.getPartitionFromDefinition 'image', { primary: 5 }, (error, position) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('Partition not found: 5.')
					expect(position).to.not.exist
					done()

		describe 'given a valid primary partition', ->

			beforeEach ->
				@bootRecordGetMasterStub = sinon.stub(bootRecord, 'getMaster')
				@bootRecordGetMasterStub.yields null,
					partitions: [
						{ firstLBA: 256, info: 'first' }
						{ firstLBA: 512, info: 'second' }
					]

			afterEach ->
				@bootRecordGetMasterStub.restore()

			it 'should return the primary partition if no logical partition', (done) ->
				partition.getPartitionFromDefinition 'image', { primary: 1 }, (error, definition) ->
					expect(error).to.not.exist
					expect(definition).to.deep.equal
						firstLBA: 256
						info: 'first'
					done()

			it 'should return the primary partition if logical partition is zero', (done) ->
				partition.getPartitionFromDefinition 'image', { primary: 1, logical: 0 }, (error, definition) ->
					expect(error).to.not.exist
					expect(definition).to.deep.equal
						firstLBA: 256
						info: 'first'
					done()

			describe 'given partition is not extended', ->

				beforeEach ->
					@bootRecordGetExtendedStub = sinon.stub(bootRecord, 'getExtended')
					@bootRecordGetExtendedStub.yields(null, undefined)

				afterEach ->
					@bootRecordGetExtendedStub.restore()

				it 'should return an error', (done) ->
					partition.getPartitionFromDefinition 'image', { primary: 1, logical: 2 }, (error, definition) ->
						expect(error).to.be.an.instanceof(Error)
						expect(error.message).to.equal('Not an extended partition: 1.')
						expect(definition).to.not.exist
						done()

			describe 'given partition is extended', ->

				beforeEach ->
					@bootRecordGetExtendedStub = sinon.stub(bootRecord, 'getExtended')
					@bootRecordGetExtendedStub.yields null,
						partitions: [
							{ firstLBA: 1024, info: 'third' }
							{ firstLBA: 2048, info: 'fourth' }
						]

				afterEach ->
					@bootRecordGetExtendedStub.restore()

				it 'should return an error if partition was not found', (done) ->
					partition.getPartitionFromDefinition 'image', { primary: 1, logical: 3 }, (error, definition) ->
						expect(error).to.be.an.instanceof(Error)
						expect(error.message).to.equal('Partition not found: 3.')
						expect(definition).to.not.exist
						done()

				it 'should return the logical partition', (done) ->
					partition.getPartitionFromDefinition 'image', { primary: 1, logical: 2 }, (error, definition) ->
						expect(error).to.not.exist
						expect(definition).to.deep.equal
							firstLBA: 2304
							info: 'fourth'
						done()

	describe '.getPosition()', ->

		it 'should throw if no image', ->
			expect ->
				partition.getPosition(null, { primary: 3, logical: 1 }, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				partition.getPosition(123, { primary: 3, logical: 1 }, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition', ->
			expect ->
				partition.getPosition('image', null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if definition is not an object', ->
			expect ->
				partition.getPosition('image', [ 'hello' ], _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition.primary', ->
			expect ->
				partition.getPosition('image', { logical: 1 }, _.noop)
			.to.throw(errors.ResinMissingOption)

		it 'should throw if no callback', ->
			expect ->
				partition.getPosition('image', { primary: 3, logical: 1 }, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				partition.getPosition('image', { primary: 3, logical: 1 }, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a partition was found', ->

			beforeEach ->
				@partitionGetPartitionFromDefinitionStub = sinon.stub(partition, 'getPartitionFromDefinition')
				@partitionGetPartitionFromDefinitionStub.yields(null, firstLBA: 512)

			afterEach ->
				@partitionGetPartitionFromDefinitionStub.restore()

			it 'should return the correct position', (done) ->
				partition.getPosition 'image.img', { primary: 3, logical: 1 }, (error, position) ->
					expect(error).to.not.exist
					expect(position).to.equal(512 * 512)
					done()

		describe 'given a partition was not found', ->

			beforeEach ->
				@partitionGetPartitionFromDefinitionStub = sinon.stub(partition, 'getPartitionFromDefinition')
				@partitionGetPartitionFromDefinitionStub.yields(new Error('Partition not found: 3.'))

			afterEach ->
				@partitionGetPartitionFromDefinitionStub.restore()

			it 'should return an error', (done) ->
				partition.getPosition 'image.img', { primary: 3, logical: 1 }, (error, position) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('Partition not found: 3.')
					expect(position).to.not.exist
					done()

	describe '.copyPartition()', ->

		it 'should throw if no image', ->
			expect ->
				partition.copyPartition(null, { primary: 3, logical: 1 }, 'output', _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if image is not a string', ->
			expect ->
				partition.copyPartition(123, { primary: 3, logical: 1 }, 'output', _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition', ->
			expect ->
				partition.copyPartition('image', null, 'output', _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if definition is not an object', ->
			expect ->
				partition.copyPartition('image', [ 'hello' ], 'output', _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no definition.primary', ->
			expect ->
				partition.copyPartition('image', { logical: 1 }, 'output', _.noop)
			.to.throw(errors.ResinMissingOption)

		it 'should throw if no output', ->
			expect ->
				partition.copyPartition('image', { primary: 3, logical: 1 }, null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if output is not a string', ->
			expect ->
				partition.copyPartition('image', { primary: 3, logical: 1 }, 123, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				partition.copyPartition('image', { primary: 3, logical: 1 }, 'output', null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				partition.copyPartition('image', { primary: 3, logical: 1 }, 'output', [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		describe 'given a partition not was found', ->

			beforeEach ->
				@partitionGetPartitionFromDefinitionStub = sinon.stub(partition, 'getPartitionFromDefinition')
				@partitionGetPartitionFromDefinitionStub.yields(new Error('Partition not found: 3.'))

			afterEach ->
				@partitionGetPartitionFromDefinitionStub.restore()

			it 'should return an error', (done) ->
				partition.copyPartition 'image', { primary: 3, logical: 1 }, 'output', (error) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('Partition not found: 3.')
					done()

		describe 'given a partition without sectors', ->

			beforeEach ->
				@partitionGetPartitionFromDefinitionStub = sinon.stub(partition, 'getPartitionFromDefinition')
				@partitionGetPartitionFromDefinitionStub.yields null,
					firstLBA: 512

			afterEach ->
				@partitionGetPartitionFromDefinitionStub.restore()

			it 'should return an error', (done) ->
				partition.copyPartition 'image', { primary: 3, logical: 1 }, 'output', (error) ->
					expect(error).to.be.an.instanceof(errors.ResinMissingOption)
					done()

		describe 'given a partition without firstLBA', ->

			beforeEach ->
				@partitionGetPartitionFromDefinitionStub = sinon.stub(partition, 'getPartitionFromDefinition')
				@partitionGetPartitionFromDefinitionStub.yields null,
					sectors: 2048

			afterEach ->
				@partitionGetPartitionFromDefinitionStub.restore()

			it 'should return an error', (done) ->
				partition.copyPartition 'image', { primary: 3, logical: 1 }, 'output', (error) ->
					expect(error).to.be.an.instanceof(errors.ResinMissingOption)
					done()
