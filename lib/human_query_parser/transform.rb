require 'parslet'
require 'human_query_parser/bareword'
require 'human_query_parser/phrase'
require 'human_query_parser/query'
require 'human_query_parser/term'

module HumanQueryParser
  class Transform < Parslet::Transform
    rule(:phrase => simple(:phrase)) { Phrase.new(phrase) }
    rule(:bareword => simple(:bareword)) { Bareword.new(bareword) }
    rule(:term => simple(:term), :operator => simple(:operator)) { Term.new(operator, term) }
    rule(:query => sequence(:terms)) { Query.new(terms) }
  end
end