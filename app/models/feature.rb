class Feature < ApplicationRecord
  belongs_to :property, optional: true
end
