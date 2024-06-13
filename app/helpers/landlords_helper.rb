module LandlordsHelper
  include Pagy::Frontend

  def rate_or_fee(landlord)
    if landlord.rate.present?
      landlord.rate + '%'
    elsif landlord.fee.present?
      '£' + landlord.fee
    else

    end
  end
end
