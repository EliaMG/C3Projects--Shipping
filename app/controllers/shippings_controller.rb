class ShippingsController < ApplicationController

  def quotes
    render json: {party: "everywhere"}
  end
end
