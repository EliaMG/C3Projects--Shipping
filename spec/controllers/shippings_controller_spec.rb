require 'rails_helper'
require 'vcr_setup'

RSpec.describe ShippingsController, type: :controller do
  let(:request) {{origin: {:origin_city =>"Texarkana", :origin_state =>"TX", :origin_zip =>"75505", :origin_country =>"US"}, destination: {:destination_city =>"Seattle", :destination_state =>"WA", :destination_zip =>"98115", :destination_country =>"US"}, packages: {1 =>{:quantity => "1", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}}}}

  describe "get #quotes" do

    it "is successful" do
      VCR.use_cassette 'controller/quotes_response' do
        get :quotes, origin: {:origin_city =>"Texarkana", :origin_state =>"TX", :origin_zip =>"75505", :origin_country =>"US"}, destination: {:destination_city =>"Seattle", :destination_state =>"WA", :destination_zip =>"98115", :destination_country =>"US"}, packages: {1 =>{:quantity => "1", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}, 2 =>{:quantity => "2", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}}
        expect(response.response_code).to eq 200
      end
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
      VCR.use_cassette 'controller/ups_creds' do
        expect(controller.send(:ups_cred).valid_credentials?).to eq true
        expect(controller.send(:ups_cred)).to be_an_instance_of ActiveShipping::UPS
      end
    end

    it "returns an array of UPS options" do
      VCR.use_cassette 'controller/ups_hashymash' do
        quote_response = (controller.send(:get_ups_quote, request))
        expect(quote_response).to be_an_instance_of Array
        expect(quote_response[1]).to include("UPS Three-Day Select")
      end
    end
  end

  describe "get FedEx quote" do

    it "creates a FedEx carrier instance with valid credentials" do
      VCR.use_cassette 'controller/fedex_creds' do
        expect(controller.send(:fedex_cred).valid_credentials?).to eq true
        expect(controller.send(:fedex_cred)).to be_an_instance_of ActiveShipping::FedEx
      end
    end

    it "returns an array of FedEx options" do
      VCR.use_cassette 'controller/fedex_hashymash' do
        quote_response = (controller.send(:get_fedex_quote, request))
        expect(quote_response).to be_an_instance_of Array
        expect(quote_response[1]).to include("FedEx Priority Overnight")
      end
    end
  end
end
