class Product
  attr_accessor :item_code, :name, :price_base, :price

  def initialize(item_code, name, price)
    @item_code  = item_code
    @name       = name
    @price_base = @price = price
  end

  class << self
    attr_accessor :products

    def register(item_code, name, price)
      new_product = self.new(item_code, name, price)

      if is_valid?(new_product) && !is_duplicate?(item_code)
        products.push(self.new(item_code, name, price))
      end
    end

    def find_by_code(item_code)
      products.detect {|item| item.item_code == item_code}
    end

    def include_item?(item_code)
      products.map { |item| item.item_code }.include?(item_code)
    end

    def delete(item_code)
      products.delete_if { |item| item.item_code == item_code }
    end

    def is_duplicate?(item_code)
      include_item?(item_code)
    end

    def is_valid?(product)
      product.item_code.is_a?(String) && product.name.is_a?(String) && product.price.is_a?(Float)
    end
  end

  @products = [
    self.new("001", "Lavender heart", 9.25),
    self.new("002", "Personalised cufflinks", 45.00),
    self.new("003", "Kids T-shirt", 19.95)
  ]
end