class PropertyListingLocation < ApplicationRecord
  belongs_to :property
  belongs_to :user

  enum listing_type: %i[website]
end
