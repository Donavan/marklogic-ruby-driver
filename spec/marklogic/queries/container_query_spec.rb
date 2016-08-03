require 'spec_helper'

describe MarkLogic::Queries::ContainerQuery do
  describe '#to_s' do
    it 'should create xquery correctly' do
      q = MarkLogic::Queries::ContainerQuery.new('foo', MarkLogic::Queries::ValueQuery.new('bar', 'baz'))
      expect(q.to_s).to eq(%{cts:json-property-scope-query("foo",cts:json-property-value-query("bar",("baz"),("exact"),1.0))})
    end
  end
end
