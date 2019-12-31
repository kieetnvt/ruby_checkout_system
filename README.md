### Checkout System with Ruby & Rspec

#### Promotion Rule Example

- If you spend over '£60', then you get '10%' off of your purchase

```

promotion_rule = PromotionRule.new(
  discount_type: :discount_by_percent,
  discount_value: 10.00,
  apply_condition_type: :total_purchase,
  apply_condition_value: 60.00,
  applied_for: :purchase
)

```

- If you buy 2 or more lavender hearts then the price drops to £8.50

```

promotion_rule = PromotionRule.new(
  discount_type: :discount_by_price,
  discount_value: 8.50,
  apply_condition_type: :items_count,
  apply_condition_value: "001",
  applied_for: :item
)

```

#### Checkout Example

```
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
```

#### Product Example

- Product.produc

```
@products = [
  self.new("001", "Lavender heart", 9.25),
  self.new("002", "Personalised cufflinks", 45.00),
  self.new("003", "Kids T-shirt", 19.95)
]
```