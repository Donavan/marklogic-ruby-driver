require 'spec_helper'

describe MarkLogic::Queries::SearchQuery do

  describe '#to_s' do
    it 'should create xquery correctly when given a source to search' do
      q = MarkLogic::Queries::SearchQuery.new('sub_query', 'foo')
      expect(q.to_s).to eq (%{cts:search(foo, sub_query)})
    end

    it 'should create xquery correctly when not given a source to search' do
      q = MarkLogic::Queries::SearchQuery.new('sub_query', )
      expect(q.to_s).to eq (%{cts:search(fn:doc(), sub_query)})
    end
  end
end
