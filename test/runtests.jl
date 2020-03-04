using Dates, Test
using TrustPilotCalc
using TrustPilotCalc: TPReview, TPScore

printstyled("Running tests:\n", color=:blue)
@testset "Testing base use cases" begin
let
    five_star_review = TPReview("seed", 5.0, Dates.now() - Dates.Year(2))
    one_star_review = TPReview("seed", 1.0, Dates.now())

    # 20x 5star reviews two years ago = trustscore 4.5.
    @test getTrustScore(fill(five_star_review, 20)) == TPScore(4.6, 4.5, five_star_review.created_at)
    # as above + 1-star review today
    @test getTrustScore([fill(five_star_review, 20); one_star_review]) == TPScore(3.3, 3.5, one_star_review.created_at)
    # single 1-star review today
    @test getTrustScore([one_star_review]) == TPScore(3.2, 3.0, one_star_review.created_at)
    # single 5-star review today
    @test getTrustScore([five_star_review]) == TPScore(3.7, 3.5, five_star_review.created_at)

end
end
