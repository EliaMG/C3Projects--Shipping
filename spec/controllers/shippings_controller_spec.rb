require 'rails_helper'

RSpec.describe ShippingsController, type: :controller do
  describe "get #quotes" do
    before :each do
      get :quotes, order:
      "?origin=Texarkana TX 75505 US&destination=Seattle WA 98101 US&packages={quantity: 4, weight: 5, length: 6, height: 6, width: 6}, {quantity: 3, weight: 5, length: 6, height: 6, width: 6}, {quantity: 2, weight: 5, length: 6, height: 6, width: 6}"
    end

    it "is successful" do
      expect(response.response_code).to eq 200
    end

    it "returns json" do
      expect(response.header["Content-Type"]).to include 'application/json'
    end
  end
end
