require 'spec_helper'

describe MarkLogic::Queries::NotQuery do
  describe '#to_s' do
    it 'should create xquery correctly' do
      q = MarkLogic::Queries::NotQuery.new(MarkLogic::Queries::DirectoryQuery.new('/foo/'))
      expect(q.to_s).to eq(%{cts:not-query(cts:directory-query(("/foo/")))})
    end
  end
end
