module TrustPilotCalc

export getTrustScore, playBack

using Dates
using JuliaDB

# references
# https://support.trustpilot.com/hc/en-us/articles/201748946
# http://www.ebc.cat/2015/01/05/how-to-rank-restaurants/
# https://www.evanmiller.org/bayesian-average-ratings.html
# https://medium.com/district-data-labs/computing-a-bayesian-estimate-of-star-rating-means-651496a890ab

"""
TrustPilot review structure
"""
struct TPReview
    author_id::AbstractString
    stars::Float64
    created_at::DateTime
end

"""
TrustPilot score structure
"""
struct TPScore
    score::Float64
    stars::Float64
    date::DateTime
end

"""
  getReviewWeightStatic(review_date, last_review_date)

static variant of review weighting function assuming no decay.
"""
function getReviewWeightStatic(reviewed_at::DateTime, last_reviewed_at::DateTime)
    milli_month = 2592000000
    delta = round((last_reviewed_at - reviewed_at).value / milli_month)
    return if delta < 1 1
        elseif delta < 3 .8
        elseif delta < 6 .5
        elseif delta < 12 .3
        else .1
        end
end

"""
  getReviewWeightHL(review_date, last_review_date)

exponential decay (half-life) variant of the `getReviewWeight` function
"""
function getReviewWeightHL(reviewed_at::DateTime, last_reviewed_at::DateTime)
    milli_month = 2592000000 # a month in millis
    initial_weight = 1 # starting weight
    hl = 0.5 # half life
    hlt = 6 # half life t
    delta = round((last_reviewed_at - reviewed_at).value / milli_month)
    weight = initial_weight * exp((log(hl) / hlt) * delta)
    return weight >= 1 ? 1 : weight
end

"""
  getTrustScore(reviews_array)

calculates TrustPilot score given an array of reviews.

returns a `TPScore` object
"""
function getTrustScore(reviews::Array{TPReview})
    first_reviewed_at = mapreduce(x -> x.created_at, min, reviews)
    last_reviewed_at = mapreduce(x -> x.created_at, max, reviews)
    base_reviews = fill(TPReview("seed", 3.5, first_reviewed_at), 7) # avg seed
    all_reviews = [base_reviews; reviews]
    all_weights = mapreduce(x -> getReviewWeightHL(x.created_at, last_reviewed_at), +, all_reviews)
    R = mapreduce(x -> (x.stars * getReviewWeightHL(x.created_at, last_reviewed_at)), +, all_reviews) / all_weights # average user rating for this product
    C = 3.5 # average user rating for all products (seed) aka 3.5
    v = length(reviews)
    m = length(base_reviews)
    w = 1 #v/(v + m) # weight  for R... v/(v + m) v = n rating for this product, m = ... all products aka 7

    S = w * R + (1 - w) * C
    return TPScore(round(S, digits=1), scoreToStars(S), last_reviewed_at)
end

"""
  scoreToStars(trustPilot_score)

rounds TrustPilot score to its equivalent stars value.
"""
function scoreToStars(score::Float64)
    score = round(score, digits=1)
    rem = round(score % .5, digits = 1)
    stars = rem <= .2 ? score - rem : score + (.5 - rem)
    return stars < 1 ? 1 : stars
end

"""
  loadReviews(csv_file)

imports a TrustPilot reviews export.
"""
function loadReviews(filename)
    reviews = loadtable(filename; output = "data_swap", type_detect_rows = 500)
end

"""
  playBack(csv_file)

imports a TrustPilot reviews CSV export and calculates a TrustPilot score.
"""
function playBack(filename)
    raw_data = loadReviews(filename)
    working_data = select(working_data, (:review_author_id, :review_created_at_utc, :review_star))
    sort!(working_data, :review_created_at_utc)
    all_reviews = map(x -> TPReview(x.review_author_id, x.review_star, x.review_created_at_utc), working_data)
    results = getTrustScore(all_reviews)
    return results
end

end # module
