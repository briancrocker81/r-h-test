class EventsProperty < ApplicationRecord
  belongs_to :event
  belongs_to :property, optional: true
end