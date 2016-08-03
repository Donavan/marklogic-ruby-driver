require 'spec_helper'

describe MarkLogic::Queries::NotInQuery do

  describe "#to_s" do
    it "should create xquery correctly" do
      q = MarkLogic::Queries::NotInQuery.new(
        MarkLogic::Queries::DirectoryQuery.new("/foo/"),
        MarkLogic::Queries::CollectionQuery.new("bar"))
      expect(q.to_s).to eq(%Q{cts:not-in-query(cts:directory-query(("/foo/")),cts:collection-query(("bar")))})
    end
  end
end
