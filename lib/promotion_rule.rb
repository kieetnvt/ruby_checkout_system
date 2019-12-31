class PromotionRule

  MORE_ITEMS_COUNT_CONST = 2

  attr_accessor :discount_type, :discount_value, :apply_condition_type, :apply_condition_value, :applied_for

  def initialize(discount_type:, discount_value:, apply_condition_type:, apply_condition_value:, applied_for:)
    @discount_type         = discount_type
    @discount_value        = discount_value
    @apply_condition_type  = apply_condition_type
    @apply_condition_value = apply_condition_value
    @applied_for           = applied_for
  end

  def apply_promotion(price)
    price = if self.is_discount_by_percent?
      price * (100.00 - self.discount_value) / 100.00
    elsif self.is_discount_by_price?
      price - self.discount_value
    end
  end

  def is_discount_by_percent?
    self.discount_type == :discount_by_percent
  end

  def is_discount_by_price?
    self.discount_type == :discount_by_price
  end

  def is_applied_on_each_item?
    self.applied_for == :item
  end

  def is_applied_on_purchase?
    self.applied_for == :purchase
  end

  def is_total_purchase_condition?
    self.apply_condition_type == :total_purchase
  end

  def is_items_count_condition?
    self.apply_condition_type == :items_count
  end
end
