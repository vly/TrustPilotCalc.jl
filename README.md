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

## Data sourcing

With a TrustPilot business account you can export all your reviews as a flat csv file.

Alternatively, here is an example script to generate a quick dataset from a TrustPilot reviews page.

```javascript
(function(){
function parse_text(text) {
  let output = '';
  try {
    output = text.textContent.trim();
  } catch(e) { ''}
  return output;
};
function process_review(review) {
  data_review_info = JSON.parse(parse_text(review.querySelector('script[data-initial-state=review-info]')));
  data_review_dates = JSON.parse(parse_text(review.querySelector('script[data-initial-state=review-dates]')));

  review_blob = {
    review_id: data_review_info.reviewId,
    review_created_at_utc: data_review_dates.publishedDate,
    review_author_id: data_review_info.consumerId,
    review_username: data_review_info.consumerName,
    review_email: '',
    review_title: parse_text(review.querySelector('.review-content__title a')),
    review_content: parse_text(review.querySelector('.review-content__text')),
    review_star: data_review_info.stars,
    review_source: '',
    reference_id: '',
    company_response: parse_text(review.querySelector('.brand-company-reply__content')),
    review_language: '',
    domain_url: review.getAttribute('data-review-domain-name'),
    webshop_name: data_review_info.businessUnitDisplayName,
    business_unit_id: data_review_info.businessUnitId,
    tags: '',
    company_reply_at_utc: review.querySelector('.brand-company-reply__date time') ? review.querySelector('.brand-company-reply__date time').getAttribute('datetime') : '',
    location_name: parse_text(review.querySelector('.consumer-information__location span')),
    location_id: '',
    reviewer_review_count: Number(parse_text(review.querySelector('.consumer-information__review-count span')).replace(' reviews',''))
  };
  return review_blob;
};

function to_flatformat(review_objs) {
  keys = Object.keys(review_objs[0]);
  rows = Array.prototype.map.call(review_objs, function(obj){return Object.values(obj)});
  blob = Array.prototype.concat([header], rows);
  return Array.prototype.map.call(blob, function(line){return line.join("','");}).join("'\n'")
};

_reviews = document.querySelectorAll('.review');
_review_objs = Array.prototype.map.call(_reviews, function(review){return process_review(review)});
return to_flatformat(_review_objs);
})();

```

## References

* [High level overview of TP's approach to calculating scores:](https://support.trustpilot.com/hc/en-us/articles/201748946)
  description of TrustPilot's scoring algorithm
* [Evan's blog post on bayesian averages:](https://www.evanmiller.org/bayesian-average-ratings.html)
* [Bayesian average scoring blog post](http://www.ebc.cat/2015/01/05/how-to-rank-restaurants/)
* [Another blog post on rating analysis](https://medium.com/district-data-labs/computing-a-bayesian-estimate-of-star-rating-means-651496a890ab)
