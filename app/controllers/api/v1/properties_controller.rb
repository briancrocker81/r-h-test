module Api::V1
  class PropertiesController < ApiController
    include Pagy::Backend
    def index
      render json: { properties: Property.to_jsn }
    end
  end
end
