= Company Name Matcher

The purpose of this library is to compare company names with a confidence score on how well they match.

The algorithm works as follows:

* start at 100% confidence
* names are compared in lowercase since case differences are very common
* deduct 3%  for locales differences (accents such as é)
* deduct 5%  for mismatching abbreviations (e.g. "Baker & Son" vs "Baker and Son" or "Bakers Ltd" vs "Bakers Limited")
* deduct 10% for a mismatch in common words (e.g. "John Doe Company" vs "The John Doe Company")
* deduct 20% for missing words (e.g. "John Doe" vs "John Doe Company")
* deduct 30% for incorrect word order (e.g. "The Joe Bloggs Company" vs "The Company of Joe Bloggs")

== Example

```
match = CompanyNameMatcher::Match.new('Jolly Green Giant Corp', 'The Jolly Green Giant Corporation')

puts match.score # 85 - as in an 85% confidence that this is the same Company
```

== Known Issues

There's a problem with the word order score, however it always returns a very low score for words in the wrong order which will probably suffice for most cases.
