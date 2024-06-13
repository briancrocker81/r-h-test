module FurnishedStatus
  extend ActiveSupport::Concern

  def furnished_type
    if furnished == 0
      'Furnished'
    elsif furnished == 1
      'Partially'
    elsif furnished == 2
      'Furnished'
    elsif furnished == 3
      'Unfurnished'
    else
      ''
    end
  end

end