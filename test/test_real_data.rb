# frozen_string_literal: true

require "test_helper"
require "json"

class TestDecombobulate < Minitest::Test
  def test_can_generate_csv
    object = [{
      "id": "7ca6f341-88b8-49ff-a0a0-ee7ef8ea1d20",
      "@context": "https://schema.org",
      "@type": "ClaimReview",
      "author": {
        "@type": "Organization",
        "name": "realfact",
        "url": "https://www.realfact.com/",
        "image": nil,
        "sameAs": nil
      },
      "claimReviewed": "The approach will not be easy. You are required to maneuver straight down this trench and skim the surface to this point. The target area is only two meters wide.",
      "datePublished": "2021-02-01",
      "itemReviewed": {
        "@type": "Claim",
        "datePublished": "2021-01-30",
        "name": "Star Wars claim",
        "appearance": [{
          "url": "https://foobar.com/13531",
          "@type": "CreativeWork"
        }],
        "firstAppearance": {
          "url": "https://foobar.com/13531",
          "@type": "CreativeWork"
        },
        "author": {
          "@type": "Person",
          "name": "Viral image",
          "jobTitle": "On the internet",
          "image": nil,
          "sameAs": nil
        }
      },
      "reviewRating": {
        "@type": "Rating",
        "ratingValue": "4",
        "bestRating": "5",
        "worstRating": "0",
        "ratingExplanation": "Don't worry about it",
        "image": "https://static.politifact.com/politifact/rulings/meter-false.jpg",
        "alternateName": "False"
      },
      "url": "https://www.realfact.com/factchecks/2021/feb/03/starwars"
    }]

    assert_equal Decombobulate.new(object).headers.to_set, [
      "id",
      "@context",
      "@type",
      "author.@type",
      "author.name",
      "author.url",
      "author.image",
      "author.sameAs",
      "claimReviewed",
      "datePublished",
      "itemReviewed.@type",
      "itemReviewed.datePublished",
      "itemReviewed.name",
      "itemReviewed.appearance.1.url",
      "itemReviewed.appearance.1.@type",
      "itemReviewed.firstAppearance.url",
      "itemReviewed.firstAppearance.@type",
      "itemReviewed.author.@type",
      "itemReviewed.author.name",
      "itemReviewed.author.jobTitle",
      "itemReviewed.author.image",
      "itemReviewed.author.sameAs",
      "reviewRating.@type",
      "reviewRating.ratingValue",
      "reviewRating.bestRating",
      "reviewRating.worstRating",
      "reviewRating.ratingExplanation",
      "reviewRating.image",
      "reviewRating.alternateName",
      "url"
    ].to_set

    assert_equal Decombobulate.new(object).to_csv, "id,@context,@type,claimReviewed,datePublished,url,author.@type,author.name,author.url,author.image,author.sameAs,itemReviewed.@type,itemReviewed.datePublished,itemReviewed.name,itemReviewed.appearance.1.url,itemReviewed.appearance.1.@type,itemReviewed.firstAppearance.url,itemReviewed.firstAppearance.@type,itemReviewed.author.@type,itemReviewed.author.name,itemReviewed.author.jobTitle,itemReviewed.author.image,itemReviewed.author.sameAs,reviewRating.@type,reviewRating.ratingValue,reviewRating.bestRating,reviewRating.worstRating,reviewRating.ratingExplanation,reviewRating.image,reviewRating.alternateName\n7ca6f341-88b8-49ff-a0a0-ee7ef8ea1d20,https://schema.org,ClaimReview,The approach will not be easy. You are required to maneuver straight down this trench and skim the surface to this point. The target area is only two meters wide.,2021-02-01,https://www.realfact.com/factchecks/2021/feb/03/starwars,Organization,realfact,https://www.realfact.com/,,,Claim,2021-01-30,Star Wars claim,https://foobar.com/13531,CreativeWork,https://foobar.com/13531,CreativeWork,Person,Viral image,On the internet,,,Rating,4,5,0,Don't worry about it,https://static.politifact.com/politifact/rulings/meter-false.jpg,False\n"
  end
end
