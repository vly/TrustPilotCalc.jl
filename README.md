# TrustPilotCalc.jl

A package to calculate TrustPilot scores from user reviews.
Did my best to follow the official description of calculations employed by TrustPilot themselves.

### Setup

- Download or scrape TrustPilot reviews for a given company/product.
I used the following schema `review_author_id, review_created_at_utc, review_star`.
- `using TrustPilotCalc` you can run through the entire dataset using `playBack(filename)` function
- if you are wanting to parse your own dataset e.g. from a db, use `getTrustScore(reviews)` function and pass in an array of `TPReview` objects.

### References
- High level overview of TP's approach to calculating scores: https://support.trustpilot.com/hc/en-us/articles/201748946
- http://www.ebc.cat/2015/01/05/how-to-rank-restaurants/
- https://www.evanmiller.org/bayesian-average-ratings.html
- https://medium.com/district-data-labs/computing-a-bayesian-estimate-of-star-rating-means-651496a890ab
