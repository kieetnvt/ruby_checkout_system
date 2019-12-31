require 'pry'
require 'spec_helper'
require './lib/checkout'
require './lib/product'
require './lib/promotion_rule'

describe "Checkout System: basic test" do
  # new("001", "Lavender heart", 9.25),
  # new("002", "Personalised cufflinks", 45.00),
  # new("003", "Kids T-shirt", 19.95)
  let(:price_001) {9.25}
  let(:price_002) {45.00}
  let(:price_003) {19.95}

  it "It should have correct 3 items in basket equal with sample products" do
    checkout = Checkout.new
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("003")
    expect(checkout.items.map {|item| item.item_code}).to eq(["001", "002", "003"])
  end

  it "It should have correct number of items in basket after scan theses items" do
    checkout = Checkout.new()
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("003")
    expect(checkout.items.length).to eq(3)
  end

  it "Simple purchase of one item" do
    checkout = Checkout.new
    checkout.scan("001")
    expect(checkout.total).to eq(price_001)
  end

  it "Simple purchase all items" do
    checkout = Checkout.new
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("003")
    expect(checkout.total).to eq((price_001 + price_002 + price_003).round(2))
  end

  it "Simple purchase undefined item" do
    checkout = Checkout.new
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("003")
    checkout.scan("004")
    checkout.scan("005")
    checkout.scan("006")
    checkout.scan(nil)
    checkout.scan(001)
    expect(checkout.total).to eq((price_001 + price_002 + price_003).round(2))
  end

  it "Should count same items in basket" do
    checkout = Checkout.new
    checkout.scan("001")
    checkout.scan("003")
    checkout.scan("001")
    expect(checkout.count("001")).to eq(2)
  end

  it "Test data 1: If you spend over '£60', then you get '10%' off of your purchase" do
    promotion_rule = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 10.00,
      apply_condition_type: :total_purchase,
      apply_condition_value: 60.00,
      applied_for: :purchase
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("003")
    expected = (price_001 + price_002 + price_003) * 90 / 100
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 2: If you buy 2 or more lavender hearts then the price drops to £8.50" do
    promotion_rule = PromotionRule.new(
      discount_type: :discount_by_price,
      discount_value: 8.50,
      apply_condition_type: :items_count,
      apply_condition_value: "001",
      applied_for: :item
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("003")
    checkout.scan("001")
    expected = 8.5 + price_003 + 8.5
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 3: If you spend over '£60', then get '10%' off of your purchase
          AND If you buy 2 or more lavender hearts (001) then the price drops to £8.50" do
    promotion_rule_1 = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 10.00,
      apply_condition_type: :total_purchase,
      apply_condition_value: 60.00,
      applied_for: :purchase
    )
    promotion_rule_2 = PromotionRule.new(
      discount_type: :discount_by_price,
      discount_value: 8.50,
      apply_condition_type: :items_count,
      apply_condition_value: "001",
      applied_for: :item
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule_1)
    promotion_rules.push(promotion_rule_2)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("001")
    checkout.scan("003")
    expected = (8.5 + price_002 + 8.5 + price_003) * 90 / 100
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 4: If you buy 2 or more lavender hearts (001) then you will get discount '15%' on total purchase" do
    promotion_rule = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 15.00,
      apply_condition_type: :items_count,
      apply_condition_value: "001",
      applied_for: :purchase
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("001")
    checkout.scan("003")
    expected = (price_001 + price_002 + price_001 + price_003) * 85 / 100
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 5: If you spend over '£100.00', then you get '10%' off of your purchase" do
    promotion_rule = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 10.00,
      apply_condition_type: :total_purchase,
      apply_condition_value: 100.00,
      applied_for: :purchase
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("002")
    checkout.scan("002")
    checkout.scan("003")
    expected = (price_001 + price_002 + price_002 + price_002 + price_003) * 90 / 100
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 6: If you spend over '£100.00', then you get '-£50' off of your purchase" do
    promotion_rule = PromotionRule.new(
      discount_type: :discount_by_price,
      discount_value: 50.00,
      apply_condition_type: :total_purchase,
      apply_condition_value: 100.00,
      applied_for: :purchase
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("002")
    checkout.scan("002")
    checkout.scan("003")
    expected = (price_001 + price_002 + price_002 + price_002 + price_003) - 50.00
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 7: If you spend over '£100.00', then you get '-10%' off of your purchase
          AND If you buy mores 002 items, then you get '-5%' off of your purchase" do
    promotion_rule_1 = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 10.00,
      apply_condition_type: :total_purchase,
      apply_condition_value: 100.00,
      applied_for: :purchase
    )
    promotion_rule_2 = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 5.00,
      apply_condition_type: :items_count,
      apply_condition_value: "002",
      applied_for: :purchase
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule_1)
    promotion_rules.push(promotion_rule_2)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("002")
    checkout.scan("002")
    checkout.scan("003")
    expected = ((price_001 + price_002 + price_002 + price_002 + price_003) * 90 / 100) * 95 / 100
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 8: If you spend over '£60', then get '20%' off of your purchase
          AND If you buy 2 or more Kids T-shirt (003) then the price will sale '10%' on per items" do
    promotion_rule_1 = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 20.00,
      apply_condition_type: :total_purchase,
      apply_condition_value: 60.00,
      applied_for: :purchase
    )
    promotion_rule_2 = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 10.00,
      apply_condition_type: :items_count,
      apply_condition_value: "003",
      applied_for: :item
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule_1)
    promotion_rules.push(promotion_rule_2)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("002")
    checkout.scan("003")
    checkout.scan("003")
    expected = ( price_001 * 2 + price_002 * 2 + ( price_003 * 90 / 100 ) * 2 ) * 80 / 100
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 9: If you spend over '£60', then get '20%' off of your purchase
          AND If you buy 2 or more Kids T-shirt (003) then the price will sale '10%' on per items
          AND If you bye 2 or more Lavender heart (001) the the price of this item is '£8.50'" do
    promotion_rule_1 = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 20.00,
      apply_condition_type: :total_purchase,
      apply_condition_value: 60.00,
      applied_for: :purchase
    )
    promotion_rule_2 = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 10.00,
      apply_condition_type: :items_count,
      apply_condition_value: "003",
      applied_for: :item
    )
    promotion_rule_3 = PromotionRule.new(
      discount_type: :discount_by_price,
      discount_value: 8.50,
      apply_condition_type: :items_count,
      apply_condition_value: "001",
      applied_for: :item
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule_1)
    promotion_rules.push(promotion_rule_2)
    promotion_rules.push(promotion_rule_3)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("002")
    checkout.scan("003")
    checkout.scan("003")
    expected = ( 8.50 * 2 + price_002 * 2 + ( price_003 * 90 / 100 ) * 2 ) * 80 / 100
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 10: If you spend over '£60', then get '20%' off for Kids T-shirt (003)" do
    promotion_rule = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 20.00,
      apply_condition_type: :items_count,
      apply_condition_value: "003",
      applied_for: :purchase
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule)
    checkout = Checkout.new(promotion_rules)
    checkout.scan("002")
    checkout.scan("002")
    checkout.scan("003")
    checkout.scan("003")
    expected = ( price_002 * 2 + price_003 * 2 ) * 80 / 100
    expect(checkout.total).to eq(expected.round(2))
  end
end