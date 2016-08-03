require 'spec_helper'

describe MarkLogic::Queries::RecordCountQuery do
  describe '#to_s' do
    it 'should create xquery correctly' do
      q = MarkLogic::Queries::RecordCountQuery.new('sub_query')
      expect(q.to_s).to eq %{count(sub_query)}
    end

    it 'should create xquery for the db correctly when not given a sub query' do
      q = MarkLogic::Queries::RecordCountQuery.new
      expect(q.to_s).to eq %{count(fn:doc())}
    end
  end

  describe '#format_response' do
    it 'returns the result as an integer' do
      q = MarkLogic::Queries::RecordCountQuery.new('sub_query')
      expect(q.format_response('42')).to eq 42
    end
  end
end
