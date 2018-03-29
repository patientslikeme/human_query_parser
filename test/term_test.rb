require 'test_helper'

class HumanQueryParser::TermTest < Minitest::Spec
  it 'correctly identifies fuzzy vs non-fuzzy terms' do
    content = HumanQueryParser::Bareword.new('word')

    HumanQueryParser::Term.new(nil, content).must_be :fuzzy?
    HumanQueryParser::Term.new('+', content).wont_be :fuzzy?
    HumanQueryParser::Term.new('-', content).wont_be :fuzzy?
  end

  it 'correctly identifies barewords vs non-barewords' do
    HumanQueryParser::Term.new(nil, HumanQueryParser::Bareword.new('word')).must_be :bareword?
    HumanQueryParser::Term.new(nil, HumanQueryParser::Phrase.new('word')).wont_be :bareword?
  end
end
