require 'pry'
require 'spec_helper'
require './lib/checkout'
require './lib/product'
require './lib/promotion_rule'

describe "Checkout System: register new item and checkout with applied rules" do
  let(:product_1) {Product.find_by_code "001"}
  let(:product_2) {Product.find_by_code "002"}
  let(:product_3) {Product.find_by_code "003"}

  # This is just an example of products, your system should be ready to accept any kind of product.
  it "It should allow to register new product" do
    Product.register("004", "Logivan X", 9.99)
    Product.register("005", "Logivan Y", 19.99)
    Product.register("006", "Logivan Z", "invalid price")

    expect(Product.include_item?("004")).to eq(true)
    expect(Product.include_item?("005")).to eq(true)
    expect(Product.include_item?("006")).to eq(false)
    expect(Product.products.size).to eq(5)
  end

  it "It should Don't register new product with if it duplicate item code" do
    Product.register("004", "Logivan X", 9.99)
    Product.register("004", "Logivan X", 19.99)
    Product.register("004", "Logivan X", 119.99)

    expect(Product.include_item?("004")).to eq(true)
    expect(Product.find_by_code("004")).not_to eq(nil)
    expect(Product.find_by_code("004").price).to eq(9.99)
  end

  it "It should delete product" do
    Product.delete("004")
    Product.delete("005")
    Product.delete("006")
    Product.delete("007")

    expect(Product.include_item?("004")).to eq(false)
    expect(Product.include_item?("005")).to eq(false)
    expect(Product.include_item?("006")).to eq(false)
    expect(Product.include_item?("007")).to eq(false)
    expect(Product.products.size).to eq(3)
  end

  it "The system should be ready to accept any kind of product" do
    Product.register("004", "Logivan X", 9.99)
    product_4 = Product.find_by_code("004")

    checkout = Checkout.new
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("003")
    checkout.scan("004")

    expected_total = product_1.price + product_2.price + product_3.price + product_4.price
    expect(checkout.items.map {|item| item.item_code}).to eq(["001", "002", "003", "004"])
    expect(checkout.total).to eq(expected_total.round(2))
  end

  it "Test data 3 with register new prouct: If you spend over '£60', then get '10%' off of your purchase
          AND If you buy 2 or Logivan Y (005) then the price drops to £15.00" do

    Product.register("004", "Logivan X", 9.99)
    Product.register("005", "Logivan Y", 19.99)
    Product.register("006", "Logivan Z", 119.99)

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
      apply_condition_value: "005",
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

    expected = (product_1.price + product_2.price + product_1.price + product_3.price) * 90 / 100
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 3 with register new prouct: If you spend over '£60', then get '10%' off of your purchase
          AND If you buy 2 or Logivan Y (005) then the price drops to £15.00" do

    Product.register("004", "Logivan X", 9.99)
    Product.register("005", "Logivan Y", 19.99)
    Product.register("006", "Logivan Z", 119.99)

    promotion_rule_1 = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 10.00,
      apply_condition_type: :total_purchase,
      apply_condition_value: 60.00,
      applied_for: :purchase
    )
    promotion_rule_2 = PromotionRule.new(
      discount_type: :discount_by_price,
      discount_value: 15.00,
      apply_condition_type: :items_count,
      apply_condition_value: "005",
      applied_for: :item
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule_1)
    promotion_rules.push(promotion_rule_2)

    product_5 = Product.find_by_code("005")

    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("001")
    checkout.scan("003")
    checkout.scan("005")

    expected = (product_1.price + product_2.price + product_1.price + product_3.price + product_5.price) * 90 / 100
    expect(checkout.total).to eq(expected.round(2))
  end

  it "Test data 3 with register new prouct: If you spend over '£60', then get '10%' off of your purchase
          AND If you buy 2 or Logivan Y (005) then the price drops to £15.00" do

    Product.register("004", "Logivan X", 9.99)
    Product.register("005", "Logivan Y", 19.99)
    Product.register("006", "Logivan Z", 119.99)

    promotion_rule_1 = PromotionRule.new(
      discount_type: :discount_by_percent,
      discount_value: 10.00,
      apply_condition_type: :total_purchase,
      apply_condition_value: 60.00,
      applied_for: :purchase
    )
    promotion_rule_2 = PromotionRule.new(
      discount_type: :discount_by_price,
      discount_value: 15.00,
      apply_condition_type: :items_count,
      apply_condition_value: "005",
      applied_for: :item
    )
    promotion_rules = []
    promotion_rules.push(promotion_rule_1)
    promotion_rules.push(promotion_rule_2)

    product_5 = Product.find_by_code("005")

    checkout = Checkout.new(promotion_rules)
    checkout.scan("001")
    checkout.scan("002")
    checkout.scan("001")
    checkout.scan("003")
    checkout.scan("005")
    checkout.scan("005")

    expected = (product_1.price + product_2.price + product_1.price + product_3.price + 15.00 * 2) * 90 / 100
    expect(checkout.total).to eq(expected.round(2))
  end
end