require 'human_query_parser/bareword'
require 'human_query_parser/term'

module HumanQueryParser
  class Query
    attr_reader :terms_by_operator

    def initialize(terms)
      @terms_by_operator = terms.group_by(&:operator).inject({}) do |hash, (operator, term_group)|
        hash[operator] = combine_barewords(term_group, operator)
        hash
      end
    end

    def combine_barewords(terms, operator)
      bareword_terms, others = terms.partition(&:bareword?)

      if bareword_terms.any?
        strings = bareword_terms.map { |term| term.content.content }
        new_bareword = Bareword.new(strings.join(" "))
        [Term.new(operator, new_bareword)] + others
      else
        others
      end
    end

    def terms_for_operator(operator)
      terms_by_operator[operator] || []
    end

    def es_query(search_fields)
      bool_clauses = terms_by_operator.inject({}) do |hash, (operator, terms)|
        es_operator = case operator
        when nil then :should
        when '+' then :must
        when '-' then :must_not
        end

        hash[es_operator] = terms.flat_map { |term| term.query_fragments(search_fields) }
        hash
      end

      { bool: bool_clauses }
    end
  end
end