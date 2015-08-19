class ShippingsController < ApplicationController

  def quotes

    @request = request.parameters
    render json: {your_params: request.parameters, party: @munged}
  end

  private

  def munge_origin(request)

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

  def munge_destination(request)

    city = request[:destination][:destination_city]
    state = request[:destination][:destination_state]
    zip = request[:destination][:destination_zip]
    country = request[:destination][:destination_country]

    @destination = ActiveShipping::Location.new(country: country,
                                                state: state,
                                                city: city,
                                                zip: zip
                                               )
  end

  def munge_packages(request)

    package = request[:packages][1]

    weight = package[:weight].to_i
    height = package[:height].to_i
    length = package[:length].to_i
    width = package[:width].to_i

    new_package = ActiveShipping::Package.new(weight, [height, length, width])


  end


  def get_fedex

  end

  def get_ups

  end

end
