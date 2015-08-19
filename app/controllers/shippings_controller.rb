class ShippingsController < ApplicationController

  def quotes

    @request = request.parameters
    render json: {your_params: request.parameters, party: @munged}
  end

  private

  def munge_request(request)

  city = request[:origin][:origin_city]
  state = request[:origin][:origin_state]
  zip = request[:origin][:origin_zip]
  country = request[:origin][:origin_country]

  @origin = ActiveShipping::Location.new(country: country,
                                         state: state,
                                         city: city,
                                         zip: zip
                                        )
  
  end


  def get_fedex

  end

  def get_ups

  end

end
