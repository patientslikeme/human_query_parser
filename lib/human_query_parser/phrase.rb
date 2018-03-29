module HumanQueryParser
  class Phrase
    attr_reader :content

    def initialize(content)
      @content = content.to_s
    end

    def query_fragments(search_fields, fuzzy)
      multi_match = {
        fields: search_fields,
        query: content,
        type: "phrase",
      }

      if fuzzy
        [
          {
            function_score: {
              query: {
                multi_match: multi_match.merge(max_expansions: 50),
              },
              boost: 8.0,
            },
          },
        ]
      else
        [
          {
            multi_match: multi_match,
          },
        ]
      end
    end
  end
end
