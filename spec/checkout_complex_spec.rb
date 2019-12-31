require 'pry'
require 'spec_helper'
require './lib/checkout'
require './lib/product'
require './lib/promotion_rule'

describe "Checkout System: applied multiple rules" do
  # new("001", "Lavender heart", 9.25),
  # new("002", "Personalised cufflinks", 45.00),
  # new("003", "Kids T-shirt", 19.95)
  # Our check-out can scan items in any order, and because our promotions will change,
  # it needs to be flexible regarding our promotional rules.
  let(:price_001) {9.25}
  let(:price_002) {45.00}
  let(:price_003) {19.95}

  it "Complex 1: more rules" do
    # rule_1: If you spend over £60, then you get 10% off of your purchase.
    # rule_2: If you buy 2 or more Lavender hearts (001) then the price drops to £8.50.
    # rule_3: If you buy 2 or more Personalised cufflinks (002) then the price drops to £40.0.
    # rule_4: If you buy 2 or more Kids T-shirt (003) then the price drops get 10% off.
    rule_1 = PromotionRule.new(
      apply_condition_type: :total_purchase,
      apply_condition_value: 60.00,
      discount_type: :discount_by_percent,
      discount_value: 10.00,
      applied_for: :purchase
    )
    rule_2 = PromotionRule.new(
      apply_condition_type: :items_count,
      apply_condition_value: "001",
      discount_type: :discount_by_price,
      discount_value: 8.50,
      applied_for: :item
    )
    rule_3 = PromotionRule.new(
      apply_condition_type: :items_count,
      apply_condition_value: "002",
      discount_type: :discount_by_price,
      discount_value: 40.0,
      applied_for: :item
    )
    rule_4 = PromotionRule.new(
      apply_condition_type: :items_count,
      apply_condition_value: "003",
      discount_type: :discount_by_percent,
      discount_value: 10.0,
      applied_for: :item
    )
    co = Checkout.new([rule_1, rule_3, rule_4, rule_2])
    co.scan("003")
    co.scan("001")
    co.scan("003")
    co.scan("003")
    co.scan("001")
    co.scan("002")
    co.scan("002")
    co.scan("001")
    co.scan("002")
    co.scan("003")
    price_001_discounted = 8.5
    price_002_discounted = 40.0
    expected = ( (price_003 * 90 / 100) * 4 + price_001_discounted * 3 + price_002_discounted * 3 ) * 90 / 100
    expect(co.total).to eq(expected.round(2))
  end

  it "Complex 1: more rules with all percents" do
    # rule_1: If you spend over £150, then you get 30% off of your purchase.
    # rule_2: If you buy 2 or more Lavender hearts (001) then the price drops 20% off.
    # rule_3: If you buy 2 or more Personalised cufflinks (002) then the price drops get 15% off.
    # rule_4: If you buy 2 or more Kids T-shirt (003) then the price drops get 20% off.
    # rule_5: If you spend over £200, then you get 40% off of your purchase.
    rule_1 = PromotionRule.new(
      apply_condition_type: :total_purchase,
      apply_condition_value: 150.00,
      discount_type: :discount_by_percent,
      discount_value: 30.0,
      applied_for: :purchase
    )
    rule_2 = PromotionRule.new(
      apply_condition_type: :items_count,
      apply_condition_value: "001",
      discount_type: :discount_by_percent,
      discount_value: 20.0,
      applied_for: :item
    )
    rule_3 = PromotionRule.new(
      apply_condition_type: :items_count,
      apply_condition_value: "002",
      discount_type: :discount_by_percent,
      discount_value: 15.0,
      applied_for: :item
    )
    rule_4 = PromotionRule.new(
      apply_condition_type: :items_count,
      apply_condition_value: "003",
      discount_type: :discount_by_percent,
      discount_value: 20.0,
      applied_for: :item
    )
    rule_5 = PromotionRule.new(
      apply_condition_type: :total_purchase,
      apply_condition_value: 200.00,
      discount_type: :discount_by_percent,
      discount_value: 40.0,
      applied_for: :purchase
    )
    co = Checkout.new([rule_5, rule_1, rule_4, rule_2, rule_3])
    co.scan("003")
    co.scan("001")
    co.scan("003")
    co.scan("003")
    co.scan("001")
    co.scan("002")
    co.scan("002")
    co.scan("001")
    co.scan("002")
    co.scan("003")
    co.scan("003")
    co.scan("002")
    co.scan("001")
    co.scan("001")
    co.scan("001")
    co.scan("002")
    expected = ( ( (price_003 * 80 / 100) * 5 + (price_001 * 80 / 100) * 6 + (price_002 * 85 / 100) * 5 ) * 70 / 100 ) * 60 / 100
    expect(co.total).to eq(expected.round(2))
  end
end