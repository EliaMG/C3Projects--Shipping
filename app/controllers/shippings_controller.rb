class ShippingsController < ApplicationController

  def quotes
    @request = request.parameters
    ups_response = get_ups_quote(@request)
    fedex_response = get_fedex_quote(@request)
    render json: {ups: ups_response, fedex: fedex_response}
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

    package_array = []

    request[:packages].each_value do |package|
      weight = package[:weight].to_i
      height = package[:height].to_i
      length = package[:length].to_i
      width = package[:width].to_i

      new_package = ActiveShipping::Package.new(weight, [height, length, width])

      package_array << new_package
    end

    @packages = package_array
  end


  def get_fedex_quote(request)
    munge_origin(request)
    munge_destination(request)
    munge_packages(request)

    fedex = fedex_cred
    fedex_quote = fedex.find_rates(@origin, @destination, @packages)
  end

  def get_ups_quote(request)
    munge_origin(request)
    munge_destination(request)
    munge_packages(request)

    ups = ups_cred
    ups_quote = ups.find_rates(@origin, @destination, @packages)
  end

  def ups_cred
    ActiveShipping::UPS.new(login: ENV["UPS_LOGIN"], password: ENV["UPS_PASSWORD"],
    key: ENV["UPS_KEY"])
  end

  def fedex_cred
    ActiveShipping::FedEx.new(login: ENV["FEDEX_LOGIN"], password: ENV["FEDEX_PASSWORD"],
    key: ENV["FEDEX_KEY"], meter:  ENV["FEDEX_METER"], account:  ENV["FEDEX_ACCOUNT"], test: true)
  end

end
