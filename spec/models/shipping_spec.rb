require 'rails_helper'

RSpec.describe Shipping, type: :model do

  describe "model validations" do

    it "a shipping object with all required validations is valid" do
      shipping = (create :shipping)

      expect(shipping).to be_valid
    end

    it "requires a carrier" do
      invalid_shipping = build(:shipping, carrier: nil)

      expect(invalid_shipping).to be_invalid
      expect(invalid_shipping.errors.keys).to include(:carrier)
    end

    it "requires a service name" do
      invalid_shipping = build(:shipping, service_name: nil)

      expect(invalid_shipping).to be_invalid
      expect(invalid_shipping.errors.keys).to include(:service_name)
    end

    it "requires a store" do
      invalid_shipping = build(:shipping, store: nil)

      expect(invalid_shipping).to be_invalid
      expect(invalid_shipping.errors.keys).to include(:store)
    end

    it "requires a price" do
      invalid_shipping = build(:shipping, price: nil)

      expect(invalid_shipping).to be_invalid
      expect(invalid_shipping.errors.keys).to include(:price)
    end

    it "price must be a number" do
      invalid_shipping = build(:shipping, price: "bananas")

      expect(invalid_shipping).to be_invalid
      expect(invalid_shipping.errors.keys).to include(:price)
    end

    it "requires an order id" do
      invalid_shipping = build(:shipping, order_id: nil)

      expect(invalid_shipping).to be_invalid
      expect(invalid_shipping.errors.keys).to include(:order_id)
    end

    it "order id cannot be a float" do
      invalid_shipping = build(:shipping, order_id: 12.3)

      expect(invalid_shipping).to be_invalid
      expect(invalid_shipping.errors.keys).to include(:order_id)
    end

    it "order id must be a number" do
      invalid_shipping = build(:shipping, order_id: "apples")

      expect(invalid_shipping).to be_invalid
      expect(invalid_shipping.errors.keys).to include(:order_id)
    end

    it "order id must be unique by store" do
      shipping = (create :shipping)
      dup_shipping = build(:shipping)

      expect(dup_shipping).to be_invalid
      expect(dup_shipping.errors.keys).to include(:order_id)
    end

    it "order id can be the same for different stores" do
      shipping = (create :shipping)
      newstore = build(:shipping, store: "bitsy")

      expect(newstore).to be_valid
    end
  end
end
