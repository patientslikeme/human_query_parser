require 'parslet'

module HumanQueryParser
  class Parser < Parslet::Parser
    # Single character rules
    rule(:plus)       { str('+') }
    rule(:minus)      { str('-') }
    rule(:quote)      { str('"') }

    rule(:space)      { match('\s').repeat(1) }
    rule(:space?)     { space.maybe }

    # Things
    rule(:operator)   { plus | minus }
    rule(:phrase) {
      quote >> (quote.absent? >> any).repeat.as(:phrase) >> quote
    }
    rule(:bareword_start) { quote.absent? >> any }
    rule(:bareword)   { (bareword_start >> (space.absent? >> any).repeat).as(:bareword) }
    rule(:term)       { space? >> operator.maybe.as(:operator) >> (phrase | bareword).as(:term) >> space? }

    # Put it all together
    rule(:query)      { term.repeat.as(:query) }
    root :query
  end
end