require 'rails_helper'
require 'vcr_setup'

RSpec.describe ShippingsController, type: :controller do
  let(:request) {{origin: {:origin_city =>"Texarkana", :origin_state =>"TX", :origin_zip =>"75505", :origin_country =>"US"}, destination: {:destination_city =>"Seattle", :destination_state =>"WA", :destination_zip =>"98115", :destination_country =>"US"}, packages: {1 =>{:quantity => "1", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}, 2 =>{:quantity => "2", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}}}}

  describe "get #quotes" do

    it "is successful" do
      VCR.use_cassette 'controller/quotes_response' do
        get :quotes, origin: {:origin_city =>"Texarkana", :origin_state =>"TX", :origin_zip =>"75505", :origin_country =>"US"}, destination: {:destination_city =>"Seattle", :destination_state =>"WA", :destination_zip =>"98115", :destination_country =>"US"}, packages: {1 =>{:quantity => "1", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}, 2 =>{:quantity => "2", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}}
        expect(response.response_code).to eq 200
      end
    end

    it "is not successful (due to excess weight)" do
      VCR.use_cassette 'controller/bad_response' do
        get :quotes, origin: {:origin_city =>"Texarkana", :origin_state =>"TX", :origin_zip =>"75505", :origin_country =>"US"}, destination: {:destination_city =>"Seattle", :destination_state =>"WA", :destination_zip =>"98115", :destination_country =>"US"}, packages: {1 =>{:quantity => "1", :weight => "506794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}, 2 =>{:quantity => "2", :weight => "6794.0", :length => "4.0", :width =>"13.0", :height =>"70.0"}}
        expect(response.body).to include "Sorry, there's something wrong with the carrier processing."
      end
    end
  end

  describe "munging the request that we receive from bEtsy" do

    it "creates a ActiveShipping Location object for origin" do
      VCR.use_cassette 'controller/quotes_response' do
        expect(controller.send(:munge_origin, request)).to be_an_instance_of ActiveShipping::Location
      end
    end

    it "creates a ActiveShipping Location object for destination" do
      VCR.use_cassette 'controller/quotes_response' do
        expect(controller.send(:munge_destination, request)).to be_an_instance_of ActiveShipping::Location
      end
    end

    it "creates a ActiveShipping Package object for packages" do
      VCR.use_cassette 'controller/quotes_response' do
        expect(controller.send(:munge_packages, request).first).to be_an_instance_of ActiveShipping::Package
      end
    end

    it "creates a Package object for the total quantity of packages" do
      VCR.use_cassette 'controller/quotes_response' do
        expect(controller.send(:munge_packages, request).count).to eq 3
      end
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
        expect(quote_response[1][0]).to include("UPS")
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
        expect(quote_response[1][0]).to include("FedEx")
      end
    end
  end

  describe "it receives chosen shipping option for audit" do

    it "gets an object from the store" do
      post :audit, carrier: "FedEx", service_name: "FedEx Next Day", price: "12345", est_date: "2015-08-20 20:15:19", order_id: "27", store: "TuxBetsy"

      expect(request.class).to eq Hash
    end
  end
end
