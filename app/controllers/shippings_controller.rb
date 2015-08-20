class ShippingsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def quotes
    api_call = request.parameters
    ups_response = get_ups_quote(api_call)
    fedex_response = get_fedex_quote(api_call)
    render json: {ups: ups_response, fedex: fedex_response}
  end

  def audit
    audit_data = request.parameters
    binding.pry
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
    # would be nice to extract the to_i if time, this is how the data comes in through json

    request[:packages].each_value do |package|
      package[:quantity].to_i.times do
        weight = package[:weight].to_i
        height = package[:height].to_i
        length = package[:length].to_i
        width = package[:width].to_i

        new_package = ActiveShipping::Package.new(weight, [height, length, width])

        package_array << new_package
      end
    end

    @packages = package_array
  end


  def get_fedex_quote(request)
    munge_origin(request)
    munge_destination(request)
    munge_packages(request)

    fedex = fedex_cred
    fedex_hashymash= fedex.find_rates(@origin, @destination, @packages)
    fedex_quote = fedex_hashymash.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price, rate.delivery_date]}
  end

  def get_ups_quote(request)
    munge_origin(request)
    munge_destination(request)
    munge_packages(request)

    ups = ups_cred
    ups_hashymash = ups.find_rates(@origin, @destination, @packages)
    ups_quote = ups_hashymash.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price, rate.delivery_date]}
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
