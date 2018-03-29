# HumanQueryParser

A tool for taking search queries of the form most users will expect, and producing ElasticSearch queries that do what
most users would expect.

For example:

```
some terms to search for
```

will produce a query that returns results that match as many as possible of "some", "terms", "to", "search", and "for",
preferably in that order, allowing some level of misspelling (but penalizing results for it).

```
"a phrase" term
```

will produce a query that returns results that match the entirety of "a phrase", or the word "term", or preferably
both, allowing some level of misspelling (but penalizing results for it).

```
+required optional
```

will produce a query that returns results that include exactly the word "required", ranking results that also contain
"optional" higher, and allowing misspellings of "optional" but not of "required".

```
+"required phrase" optional
```

will produce a query that returns results that include exactly the phrase "required phrase", ranking results that also
contain "optional" higher, and allowing misspellings of "optional" but not of "required phrase".

```
-negatory +affirmative
```

will produce a query that returns results that include exactly the word "affirmative", but not the word "negatory".
Misspellings of either are not counted.

```
-none -of -these -words
```

will produce a query that returns results that don't include any of the words "none", "of", "these", or "words".

## Installation

Add this to your Gemfile:

```ruby
gem 'human_query_parser'
```

Then run:

```bash
bundle install
```

## Usage

To compile a query, use the `HumanQueryParser.compile` method.  This method takes two parameters:

1. The text of the search query
2. An array of field names to search against

The content of the field names is entirely up to you and the design of your ElasticSearch index, but typically
will be names of one or more text fields in an ElasticSearch document.

For example:

```ruby
es_query = HumanQueryParser.compile("search query goes here", ['field1', 'field2'])
```

You could then use this to query ElasticSearch in a variety of ways.  For example, if you're using the official
[elasticsearch-model](https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-model) gem, you could
do:

```ruby
results = MyModel.search(query: es_query)
```

Easy peasy!

## Under the Hood

The above example returns the following ElasticSearch query:

```json
{
  "bool": {
    "should": [
      {
        "multi_match": {
          "fields": [
            "field1",
            "field2"
          ],
          "query": "search query goes here",
          "max_expansions": 50,
          "fuzziness": "AUTO"
        }
      },
      {
        "function_score": {
          "query": {
            "multi_match": {
              "fields": [
                "field1",
                "field2"
              ],
              "query": "search query goes here",
              "max_expansions": 50,
              "fuzziness": "AUTO",
              "operator": "and"
            }
          },
          "boost": 6.0
        }
      },
      {
        "function_score": {
          "query": {
            "multi_match": {
              "fields": [
                "field1",
                "field2"
              ],
              "query": "search query goes here",
              "max_expansions": 50,
              "fuzziness": "AUTO",
              "type": "phrase"
            }
          },
          "boost": 8.0
        }
      },
      {
        "multi_match": {
          "fields": [
            "field1",
            "field2"
          ],
          "query": "search query goes here",
          "max_expansions": 50,
          "fuzziness": "AUTO",
          "prefix_length": 3
        }
      }
    ]
  }
}
```

It's a little complicated, yeah!  Let's break this down piece by piece.

```json
{
  "multi_match": {
    "fields": [
      "field1",
      "field2"
    ],
    "query": "search query goes here",
    "max_expansions": 50,
    "fuzziness": "AUTO"
  }
}
```

This is our basic, misspelling-allowed version of the query against all the fields we specified.  We've found 80%
fuzziness and 50 expansions to produce good results and have hardcoded them in for now, but this may well become
configurable in future versions of HumanQueryParser.

```json
{
  "function_score": {
    "query": {
      "multi_match": {
        "fields": [
          "field1",
          "field2"
        ],
        "query": "search query goes here",
        "max_expansions": 50,
        "fuzziness": "AUTO",
        "operator": "and"
      }
    },
    "boost": 6.0
  }
}
```

This is the same query with misspellings allowed, but all terms (or misspelled versions thereof) must be present in
order to match.  If they all are, we boost the result score 6x.

```json
{
  "function_score": {
    "query": {
      "multi_match": {
        "fields": [
          "field1",
          "field2"
        ],
        "query": "search query goes here",
        "max_expansions": 50,
        "fuzziness": "AUTO",
        "type": "phrase"
      }
    },
    "boost": 8.0
  }
}
```

This is a fundamentally different type of query, because it treats the entire search term set as a phrase.
Misspellings are still allowed, but all terms (or misspelled versions thereof) must be present,
*in the same order as in the query*.  If they are, we boost the result score 8x.

```json
{
  "multi_match": {
    "fields": [
      "field1",
      "field2"
    ],
    "query": "search query goes here",
    "max_expansions": 50,
    "fuzziness": "AUTO",
    "prefix_length": 3
  }
}
```

This last fragment is yet again another type of query.  This allows a greater degree of misspelling (50% fuzziness)
as long as the first 3 characters are an exact match.  This makes it easier to do typeahead search, by not requiring
the user to have to know the entire spelling of the term (but guiding them by showing results as they go).

This is the basic pattern for generated queries.  For terms with + and - operators, misspelling isn't allowed, and
as a result we can use a single `multi_match` query rather than these four.  Terms with + and - will use `must` and
`must_not` sections of the `bool` query respectively.

## Running Tests

1. Change to the gem's directory
2. Run `bundle`
3. Run `rake`


## Release Process
Once pull request is merged to master, on latest master:
1. Update CHANGELOG.md. Version: [ major (breaking change: non-backwards
   compatible release) | minor (new features) | patch (bugfixes) ]
2. Update version in lib/global_enforcer/version.rb
3. Release by running `bundle exec rake release`
