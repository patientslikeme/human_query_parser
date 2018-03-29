require 'test_helper'

class HumanQueryParser::QueryTest < Minitest::Spec
  describe '#combine_barewords' do
    it 'combines two bareword terms' do
      query = HumanQueryParser::Query.new([
        HumanQueryParser::Term.new(
          nil,
          HumanQueryParser::Bareword.new('word'),
        ),
        HumanQueryParser::Term.new(
          nil,
          HumanQueryParser::Bareword.new('up'),
        ),
      ],)

      query.terms_by_operator.size.must_equal 1
      query.terms_for_operator(nil).size.must_equal 1

      combined_term = query.terms_for_operator(nil).first
      combined_term.must_be :bareword?
      combined_term.content.content.must_equal 'word up'
    end

    it 'does not combine phrases' do
      query = HumanQueryParser::Query.new([
        HumanQueryParser::Term.new(
          nil,
          HumanQueryParser::Bareword.new('word'),
        ),
        HumanQueryParser::Term.new(
          nil,
          HumanQueryParser::Bareword.new('up'),
        ),
        HumanQueryParser::Term.new(
          nil,
          HumanQueryParser::Phrase.new('a phrase'),
        ),
        HumanQueryParser::Term.new(
          nil,
          HumanQueryParser::Phrase.new('another phrase'),
        ),
      ],)

      query.terms_by_operator.size.must_equal 1
      query.terms_for_operator(nil).size.must_equal 3

      bareword_term = query.terms_for_operator(nil).first
      bareword_term.must_be :bareword?
      bareword_term.content.content.must_equal 'word up'

      phrase_term_1 = query.terms_for_operator(nil)[1]
      phrase_term_1.wont_be :bareword?
      phrase_term_1.content.content.must_equal 'a phrase'

      phrase_term_1 = query.terms_for_operator(nil)[2]
      phrase_term_1.wont_be :bareword?
      phrase_term_1.content.content.must_equal 'another phrase'
    end

    it 'does not combine barewords with different operators' do
      query = HumanQueryParser::Query.new([
        HumanQueryParser::Term.new(
          nil,
          HumanQueryParser::Bareword.new('word'),
        ),
        HumanQueryParser::Term.new(
          '+',
          HumanQueryParser::Bareword.new('up'),
        ),
      ],)

      query.terms_by_operator.size.must_equal 2
      query.terms_for_operator(nil).size.must_equal 1
      query.terms_for_operator('+').size.must_equal 1

      word_term = query.terms_for_operator(nil).first
      word_term.must_be :bareword?
      word_term.content.content.must_equal 'word'

      word_term = query.terms_for_operator('+').first
      word_term.must_be :bareword?
      word_term.content.content.must_equal 'up'
    end
  end

  describe '#es_query' do
    it 'generates a basic query' do
      bareword = HumanQueryParser::Bareword.new('word')

      query = HumanQueryParser::Query.new([
        HumanQueryParser::Term.new(
          '+',
          bareword,
        ),
      ],)

      query.es_query(['body', 'tags']).must_equal({
        bool: {
          must: bareword.query_fragments(['body', 'tags'], false),
        },
      },)
    end

    it 'combines terms of the same operator' do
      bareword = HumanQueryParser::Bareword.new('word')
      phrase = HumanQueryParser::Phrase.new('phrase-ology')

      query = HumanQueryParser::Query.new([
        HumanQueryParser::Term.new(
          '+',
          bareword,
        ),
        HumanQueryParser::Term.new(
          '+',
          phrase,
        ),
      ],)

      query.es_query(['body', 'tags']).must_equal({
        bool: {
          must: (
            bareword.query_fragments(['body', 'tags'], false) +
            phrase.query_fragments(['body', 'tags'], false)
          ),
        },
      },)
    end

    it 'generates separate sections for different operators' do
      must_word = HumanQueryParser::Bareword.new('word1')
      should_word = HumanQueryParser::Bareword.new('word2')
      must_not_word = HumanQueryParser::Bareword.new('word3')

      query = HumanQueryParser::Query.new([
        HumanQueryParser::Term.new(
          '+',
          must_word,
        ),
        HumanQueryParser::Term.new(
          nil,
          should_word,
        ),
        HumanQueryParser::Term.new(
          '-',
          must_not_word,
        ),
      ],)

      query.es_query(['body', 'tags']).must_equal({
        bool: {
          must: must_word.query_fragments(['body', 'tags'], false),
          should: should_word.query_fragments(['body', 'tags'], true),
          must_not: must_not_word.query_fragments(['body', 'tags'], false),
        },
      },)
    end
  end
end
