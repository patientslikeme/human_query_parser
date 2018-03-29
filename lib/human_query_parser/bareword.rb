module HumanQueryParser
  class Bareword
    attr_reader :content

    def initialize(content)
      @content = content.to_s
    end

    def query_fragments(search_fields, fuzzy)
      if fuzzy
        [
          {
            multi_match: {
              fields: search_fields,
              query: content,
              max_expansions: 50,
              fuzziness: "AUTO",
              prefix_length: 1,
            },
          },
          {
            multi_match: {
              fields: search_fields,
              query: content,
              max_expansions: 50,
              fuzziness: "AUTO",
              operator: 'and',
              boost: 6.0,
              prefix_length: 1,
            },
          },
          {
            multi_match: {
              fields: search_fields,
              query: content,
              max_expansions: 50,
              type: "phrase",
              boost: 8.0,
            },
          },
          {
            multi_match: {
              fields: search_fields,
              query: content,
              max_expansions: 50,
              fuzziness: "AUTO",
              prefix_length: 3,
            },
          },
        ]
      else
        [
          {
            multi_match: {
              fields: search_fields,
              query: content,
            },
          },
        ]
      end
    end
  end
end
