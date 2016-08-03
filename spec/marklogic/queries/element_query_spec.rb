require 'spec_helper'

describe MarkLogic::Queries::ElementQuery do

  describe '#to_s' do
    it 'should create xquery correctly when given a term' do
      q = MarkLogic::Queries::ElementQuery.new('my_element', 'my_term')
      expect(q.to_s).to eq (%{cts:element-query(xs:QName("my_element"), "my_term")})
    end

    it 'should create xquery correctly when not given a term' do
      q = MarkLogic::Queries::ElementQuery.new('my_element')
      expect(q.to_s).to eq (%{cts:element-query(xs:QName("my_element"), cts:and-query( () ))})
    end
  end
end
