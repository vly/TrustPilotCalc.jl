# TrustPilotCalc

A package to calculate TrustPilot scores from user reviews.
Did my best to follow the official description of calculations employed by TrustPilot themselves.

## Example

* Download or scrape TrustPilot reviews for a given company/product.
  I used the following schema
  ```review_author_id, review_created_at_utc, review_star```
* `using TrustPilotCalc` you can run through the entire dataset using `playBack(filename)` function
  ```julia
  julia> Pkg.add("TrustPilotCalc")
  ```
* if you are wanting to parse your own dataset e.g. from a db, use `getTrustScore(reviews)` function and pass in an array of `TPReview` objects.

```julia
using TrustPilotCalc
using Dates, JuliaDB, Lazy

# Import sample TrustPilot data
example_data = loadtable("examples/trustpilot_sample_data.csv"; type_detect_rows = 500)

# Example of a time-series of monthly TrustPilot scores
@as data example_data begin
  unique(map(x-> round(x.review_created_at_utc, Dates.Month), data))
  sort!(data; rev = true)
  pop!(data)
  [print(playBack(example_data; max_yearmon = x).score, " | ", x, "\n") for x in data]
end
```

## References

* [High level overview of TP's approach to calculating scores:](https://support.trustpilot.com/hc/en-us/articles/201748946)
  description of TrustPilot's scoring algorithm
* [Evan's blog post on bayesian averages:](https://www.evanmiller.org/bayesian-average-ratings.html)
* [Bayesian average scoring blog post](http://www.ebc.cat/2015/01/05/how-to-rank-restaurants/)
* [Another blog post on rating analysis](https://medium.com/district-data-labs/computing-a-bayesian-estimate-of-star-rating-means-651496a890ab)
