require 'test_helper'
require 'json'

class HumanQueryParser::BarewordTest < Minitest::Spec
  it 'generates a non-fuzzy query fragment correctly' do
    HumanQueryParser::Bareword.new('blue').query_fragments(['field1', 'field2'], false).must_equal([
      {
        multi_match: {
          fields: ['field1', 'field2'],
          query: 'blue',
        },
      },
    ],)
  end

  it 'generates a fuzzy query fragment correctly' do
    actual_fragments = HumanQueryParser::Bareword.new('blue').query_fragments(['field1', 'field2'], true)

    basic_multi_match = {
      fields: ['field1', 'field2'],
      query: 'blue',
      max_expansions: 50,
    }

    expected_fragments = [
      { multi_match: basic_multi_match.merge(fuzziness: "AUTO", prefix_length: 1) },
      {
        multi_match: basic_multi_match.merge({
          operator: "and",
          fuzziness: "AUTO",
          prefix_length: 1,
          boost: 6.0,
        },),
      },
      {
        multi_match: basic_multi_match.merge(type: 'phrase', boost: 8.0),
      },
      { multi_match: basic_multi_match.merge(fuzziness: "AUTO", prefix_length: 1) },
    ]

    actual_fragments.size.must_equal expected_fragments.size
    expected_fragments.each do |fragment|
      assert actual_fragments.include?(fragment), <<-MESSAGE
Generated query fragments:
#{JSON.pretty_generate(actual_fragments)}

Were expected to contain the following fragment, but didn't:
#{JSON.pretty_generate(fragment)}
      MESSAGE
    end
  end
end
