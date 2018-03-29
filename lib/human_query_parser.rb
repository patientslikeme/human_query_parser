require 'human_query_parser/parser'
require 'human_query_parser/bareword'
require 'human_query_parser/phrase'
require 'human_query_parser/query'
require 'human_query_parser/term'
require 'human_query_parser/transform'

module HumanQueryParser
  def self.compile(query_text, search_fields)
    parse_result = HumanQueryParser::Parser.new.parse(query_text)
    query = HumanQueryParser::Transform.new.apply(parse_result)
    query.es_query(search_fields)
  end
end