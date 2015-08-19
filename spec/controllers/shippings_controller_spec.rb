require 'rails_helper'

RSpec.describe ShippingsController, type: :controller do
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
    before (:each) do
      @response = {origin: {:origin_city =>"Texarkana", :origin_state =>"TX", :origin_zip =>"75505", :origin_country =>"US"}, destination: {:destination_city =>"Seattle", :destination_state =>"WA", :destination_zip =>"98115", :destination_country =>"US"}, packages: {1 =>{:quantity => "1", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}}}
    end

    it "creates a ActiveShipping Location object for origin" do
      expect(controller.send(:munge_origin, @response)).to be_an_instance_of ActiveShipping::Location
    end

    it "creates a ActiveShipping Location object for destination" do
      expect(controller.send(:munge_destination, @response)).to be_an_instance_of ActiveShipping::Location
    end

    it "creates a ActiveShipping Package object for packages" do
      expect(controller.send(:munge_packages, @response)).to be_an_instance_of ActiveShipping::Package
    end
  end
end
