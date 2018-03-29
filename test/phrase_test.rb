require 'test_helper'

class HumanQueryParser::PhraseTest < Minitest::Spec
  it 'generates a non-fuzzy query fragment correctly' do
    HumanQueryParser::Phrase.new('bloo blah').query_fragments(['field1', 'field2'], false).must_equal([
      {
        multi_match: {
          fields: ['field1', 'field2'],
          query: 'bloo blah',
          type: 'phrase',
        },
      },
    ],)
  end

  it 'generates a fuzzy query fragment correctly' do
    HumanQueryParser::Phrase.new('bloo blah').query_fragments(['field1', 'field2'], true).must_equal([
      {
        function_score: {
          query: {
            multi_match: {
              fields: ['field1', 'field2'],
              query: 'bloo blah',
              type: 'phrase',
              max_expansions: 50,
            },
          },
          boost: 8.0,
        },
      },
    ],)
  end
end
