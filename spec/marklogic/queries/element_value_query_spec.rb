require 'spec_helper'

describe MarkLogic::Queries::ElementValueQuery do
  describe '#to_s' do
    it 'should create xquery correctly when given a term' do
      q = MarkLogic::Queries::ElementValueQuery.new('my_element', 'my_term')
      expect(q.to_s).to eq %{cts:element-value-query(xs:QName("my_element"), "my_term", (), 1.0}
    end

    it 'should create xquery correctly when not given a term' do
      q = MarkLogic::Queries::ElementValueQuery.new('my_element')
      expect(q.to_s).to eq %{cts:element-value-query(xs:QName("my_element"), "*", ("wildcarded"), 1.0}
    end

    it 'should create xquery correctly when given options' do
      q = MarkLogic::Queries::ElementValueQuery.new('my_element', 'foo', [:opt1, 'opt2'])
      expect(q.to_s).to eq %{cts:element-value-query(xs:QName("my_element"), "foo", ("opt1", "opt2"), 1.0}
    end

    it 'should create xquery correctly when given a weight' do
      q = MarkLogic::Queries::ElementValueQuery.new('my_element', 'foo', [:opt1, 'opt2'], 2.0)
      expect(q.to_s).to eq %{cts:element-value-query(xs:QName("my_element"), "foo", ("opt1", "opt2"), 2.0}
    end
  end
end
