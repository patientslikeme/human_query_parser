require_relative 'test_helper'

class HumanQueryParserTest < Minitest::Spec
  it 'compiles things, basically' do
    HumanQueryParser.compile('+test', ['field1', 'field2']).must_equal({
      bool: {
        must: [
          {
            multi_match: {
              fields: ['field1', 'field2'],
              query: 'test',
            },
          },
        ],
      },
    },)
  end
end
