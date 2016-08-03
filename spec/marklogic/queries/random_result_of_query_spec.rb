require 'spec_helper'

describe MarkLogic::Queries::RandomResultOfQuery do

  describe '#to_s' do
    it 'should create xquery correctly when given a sub query' do
      q = MarkLogic::Queries::RandomResultOfQuery.new('sub_query')
      expect(q.to_s).to eq (%{declare variable $idx := xdmp:random(xdmp:estimate(sub_query)); sub_query[$idx]})
    end
  end
end