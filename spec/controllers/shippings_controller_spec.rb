require 'rails_helper'
RSpec.describe ShippingsController, type: :controller do
  let(:request) {{origin: {:origin_city =>"Texarkana", :origin_state =>"TX", :origin_zip =>"75505", :origin_country =>"US"}, destination: {:destination_city =>"Seattle", :destination_state =>"WA", :destination_zip =>"98115", :destination_country =>"US"}, packages: {1 =>{:quantity => "1", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}}}}

  describe "get #quotes" do
    before :each do
      get :quotes, origin: {:origin_city =>"Texarkana", :origin_state =>"TX", :origin_zip =>"75505", :origin_country =>"US"}, destination: {:destination_city =>"Seattle", :destination_state =>"WA", :destination_zip =>"98115", :destination_country =>"US"}, packages: {1 =>{:quantity => "1", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}}
    end

    it "is successful" do
      # binding.pry
      expect(response.response_code).to eq 200
    end

    it "returns json" do
      expect(response.header["Content-Type"]).to include 'application/json'
    end
  end

  describe "munging the request that we receive from bEtsy" do

    it "creates a ActiveShipping Location object for origin" do
      expect(controller.send(:munge_origin, request)).to be_an_instance_of ActiveShipping::Location
    end

    it "creates a ActiveShipping Location object for destination" do
      expect(controller.send(:munge_destination, request)).to be_an_instance_of ActiveShipping::Location
    end

    it "creates a ActiveShipping Package object for packages" do
      expect(controller.send(:munge_packages, request).first).to be_an_instance_of ActiveShipping::Package
    end
  end

  describe "get UPS quote" do

    it "creates a UPS carrier instance with valid credentials" do
      expect(controller.send(:ups_cred).valid_credentials?).to eq true
      expect(controller.send(:ups_cred)).to be_an_instance_of ActiveShipping::UPS
    end

    it "returns a UPS response hashy mash" do
      expect(controller.send(:get_ups_quote, request)).to be_an_instance_of ActiveShipping::RateResponse
    end
  end

  describe "get FedEx quote" do

    it "creates a FedEx carrier instance with valid credentials" do
      expect(controller.send(:fedex_cred).valid_credentials?).to eq true
      expect(controller.send(:fedex_cred)).to be_an_instance_of ActiveShipping::FedEx
    end

    it "returns a FedEx response hashy mash" do
      expect(controller.send(:get_fedex_quote, request)).to be_an_instance_of ActiveShipping::RateResponse
    end
  end
end
