require 'test_helper'

class HumanQueryParser::ParserTest < Minitest::Spec
  subject { HumanQueryParser::Parser.new }

  it 'parses a single term correctly' do
    subject.parse('word').must_equal({
      query: [
        {
          operator: nil,
          term: {
            bareword: 'word',
          },
        },
      ],
    },)
  end

  it 'parses two terms correctly' do
    subject.parse('word up').must_equal({
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
  end

  it 'ignores extra spacing' do
    subject.parse('       word   up  ').must_equal({
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
  end

  it 'parses terms with operators correctly' do
    subject.parse('+word').must_equal({
      query: [
        {
          operator: '+',
          term: {
            bareword: 'word',
          },
        },
      ],
    },)

    subject.parse('-word').must_equal({
      query: [
        {
          operator: '-',
          term: {
            bareword: 'word',
          },
        },
      ],
    },)
  end

  it 'parses quoted phrases correctly' do
    subject.parse('word "a phrase"').must_equal({
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
  end

  it 'passes through extra spacing in phrases' do
    subject.parse('"a    phrase"').must_equal({
      query: [
        {
          operator: nil,
          term: {
            phrase: 'a    phrase',
          },
        },
      ],
    },)
  end

  it 'parses phrases with operators correctly' do
    subject.parse('+"a    phrase"').must_equal({
      query: [
        {
          operator: '+',
          term: {
            phrase: 'a    phrase',
          },
        },
      ],
    },)

    subject.parse('-"a    phrase"').must_equal({
      query: [
        {
          operator: '-',
          term: {
            phrase: 'a    phrase',
          },
        },
      ],
    },)
  end
end
