require 'spec_helper'

describe MarkLogic::Queries::OrQuery do
  describe 'to_s' do
    it 'should create json correctly' do
      q = MarkLogic::Queries::OrQuery.new
      expect(q.to_s).to eq(%{cts:or-query(())})
    end

    it 'should create json correctly' do
      q = MarkLogic::Queries::OrQuery.new([])
      expect(q.to_s).to eq(%{cts:or-query(())})
    end

    it 'should create json correctly' do
      q = MarkLogic::Queries::OrQuery.new([
                                            MarkLogic::Queries::DirectoryQuery.new('/foo/')
                                          ])
      expect(q.to_s).to eq(%{cts:or-query((cts:directory-query(("/foo/"))))})
    end

    it 'should create json correctly' do
      q = MarkLogic::Queries::OrQuery.new([
                                            MarkLogic::Queries::DirectoryQuery.new('/foo/'),
                                            MarkLogic::Queries::DirectoryQuery.new('/bar/')
                                          ])
      expect(q.to_s).to eq(%{cts:or-query((cts:directory-query(("/foo/")), cts:directory-query(("/bar/"))))})
    end
  end
end
