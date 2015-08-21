class Shipping < ActiveRecord::Base
  validates :order_id, presence: true, numericality: { only_integer: true },
                       uniqueness: { scope: :store }
  validates :price, presence: true, numericality: true
  validates :carrier, :service_name, :store, presence: true
end
