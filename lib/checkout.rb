require './lib/product'
require './lib/promotion_rule'

class Checkout

  attr_accessor :items, :promotion_rules

  ROUND_FLOAT_CONST = 2

  def initialize(promotion_rules = nil)
    @items           = []
    @promotion_rules = promotion_rules
  end

  def scan(item_code)
    product = Product.find_by_code(item_code).clone
    @items.push(product) if product
  end

  def count(item_code)
    @items.count {|item| item.item_code == item_code }
  end

  def total
    return total_net if promotion_rules.nil?
    total_promotion_applied.round(ROUND_FLOAT_CONST)
  end

  def total_net
    @items.map { |item| item.price }.sum
  end

  def is_more_items?(promotion_rule)
    return if promotion_rule.apply_condition_value.nil?
    self.count(promotion_rule.apply_condition_value) >= PromotionRule::MORE_ITEMS_COUNT_CONST
  end

  def promotion_rules_applied_for_item
    @promotion_rules.map { |rule| rule if rule.is_applied_on_each_item? }.compact
  end

  def promotion_rules_applied_for_purchase
    @promotion_rules.map { |rule| rule if rule.is_applied_on_purchase? }.compact
  end

  def assign_promotion_rules_for_each_item
    self.promotion_rules_applied_for_item.each do |rule|
      item_code = rule.apply_condition_value
      next if Product.find_by_code(item_code).nil?
      if is_more_items?(rule)
        if rule.is_discount_by_percent?
          @items.map {|item| item.price = rule.apply_promotion(item.price_base) if item.item_code == item_code}
        elsif rule.is_discount_by_price?
          @items.map {|item| item.price = rule.discount_value if item.item_code == item_code}
        end
      end
    end
  end

  def total_promotion_applied
    assign_promotion_rules_for_each_item if self.promotion_rules_applied_for_item
    current_total_net = self.total_net
    self.promotion_rules_applied_for_purchase.each do |rule|
      if (rule.is_total_purchase_condition? && current_total_net > rule.apply_condition_value) ||
        (rule.is_items_count_condition? && is_more_items?(rule))
        current_total_net = rule.apply_promotion(current_total_net)
      end
    end
    current_total_net
  end
end