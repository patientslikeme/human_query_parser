module HumanQueryParser
  class Term
    attr_reader :operator, :content

    def initialize(operator, content)
      @operator = operator
      @content = content
    end

    def bareword?
      content.is_a?(Bareword)
    end

    def fuzzy?
      operator.nil?
    end

    def query_fragments(search_fields)
      content.query_fragments(search_fields, fuzzy?)
    end
  end
end