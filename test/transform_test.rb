require 'test_helper'

class HumanQueryParser::TransformTest < Minitest::Spec
  subject { HumanQueryParser::Transform.new }

  it 'transforms a single term correctly' do
    query = subject.apply({
      query: [
        {
          operator: nil,
          term: {
            bareword: 'word',
          },
        },
      ],
    },)

    word_term = query.terms_for_operator(nil).first
    word_term.must_be :bareword?
    word_term.content.content.must_equal 'word'
  end

  it 'combines two bareword terms' do
    query = subject.apply({
      query: [
        {
          operator: nil,
          term: {
            bareword: 'word',
          },
        },
        {
          operator: nil,
          term: {
            bareword: 'up',
          },
        },
      ],
    },)

    query.terms_by_operator.size.must_equal 1
    query.terms_for_operator(nil).size.must_equal 1

    combined_term = query.terms_for_operator(nil).first
    combined_term.must_be :bareword?
    combined_term.content.content.must_equal 'word up'
  end

  it 'handles operators correctly' do
    plus_query = subject.apply({
      query: [
        {
          operator: '+',
          term: {
            bareword: 'word',
          },
        },
      ],
    },)

    plus_query.terms_by_operator.size.must_equal 1
    plus_query.terms_for_operator('+').size.must_equal 1

    minus_query = subject.apply({
      query: [
        {
          operator: '-',
          term: {
            bareword: 'word',
          },
        },
      ],
    },)

    minus_query.terms_by_operator.size.must_equal 1
    minus_query.terms_for_operator('-').size.must_equal 1
  end

  it 'transforms phrases correctly' do
    query = subject.apply({
      query: [
        {
          operator: nil,
          term: {
            bareword: 'word',
          },
        },
        {
          operator: nil,
          term: {
            phrase: 'a phrase',
          },
        },
      ],
    },)

    query.terms_by_operator.size.must_equal 1
    query.terms_for_operator(nil).size.must_equal 2

    bareword_term = query.terms_for_operator(nil).first
    bareword_term.must_be :bareword?
    bareword_term.content.content.must_equal 'word'

    phrase_term = query.terms_for_operator(nil)[1]
    phrase_term.wont_be :bareword?
    phrase_term.content.content.must_equal 'a phrase'
  end

  it 'does not combine phrases' do
    query = subject.apply({
      query: [
        {
          operator: nil,
          term: {
            bareword: 'word',
          },
        },
        {
          operator: nil,
          term: {
            bareword: 'up',
          },
        },
        {
          operator: nil,
          term: {
            phrase: 'a phrase',
          },
        },
        {
          operator: nil,
          term: {
            phrase: 'another phrase',
          },
        },
      ],
    },)

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
    query = subject.apply({
      query: [
        {
          operator: nil,
          term: {
            bareword: 'word',
          },
        },
        {
          operator: '+',
          term: {
            bareword: 'up',
          },
        },
      ],
    },)

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
