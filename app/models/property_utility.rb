class PropertyUtility < ApplicationRecord
  belongs_to :property

  SERVICE_AND_UTILITIES = ["Water", "Gas", "Electricity", "Communal Wifi", "Council Tax"]
  FREQUENCY = ["Per tenancy per week", "Per tenancy per month", "Per tenancy per year", "Per household per week", "Per household per month", "Annually per tenancy", "Annually per household"]
end
