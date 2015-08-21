FactoryGirl.define do

  factory :shipping do
    store "tuxbetsy"
    carrier "ups"
    service_name "Next Day Air"
    price 12345
    order_id 1
  end
end
