class SystemContentDataCategoriesController < ApplicationController
  before_action :set_system_content_data_category, only: [:show, :edit, :update, :destroy]

  # GET /system_content_data_categories
  # GET /system_content_data_categories.json
  def index
    @system_content_data_categories = SystemContentDataCategory.all
  end

  # GET /system_content_data_categories/1
  # GET /system_content_data_categories/1.json
  def show
  end

  # GET /system_content_data_categories/new
  def new
    @system_content_data_category = SystemContentDataCategory.new
  end

  # GET /system_content_data_categories/1/edit
  def edit
  end

  # POST /system_content_data_categories
  # POST /system_content_data_categories.json
  def create
    @system_content_data_category = SystemContentDataCategory.new(system_content_data_category_params)

    respond_to do |format|
      if @system_content_data_category.save
        format.html { redirect_to @system_content_data_category, notice: 'System content data category was successfully created.' }
        format.json { render :show, status: :created, location: @system_content_data_category }
      else
        format.html { render :new }
        format.json { render json: @system_content_data_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /system_content_data_categories/1
  # PATCH/PUT /system_content_data_categories/1.json
  def update
    respond_to do |format|
      if @system_content_data_category.update(system_content_data_category_params)
        format.html { redirect_to @system_content_data_category, notice: 'System content data category was successfully updated.' }
        format.json { render :show, status: :ok, location: @system_content_data_category }
      else
        format.html { render :edit }
        format.json { render json: @system_content_data_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /system_content_data_categories/1
  # DELETE /system_content_data_categories/1.json
  def destroy
    @system_content_data_category.destroy
    respond_to do |format|
      format.html { redirect_to system_content_data_categories_url, notice: 'System content data category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_system_content_data_category
      @system_content_data_category = SystemContentDataCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def system_content_data_category_params
      params.require(:system_content_data_category).permit(:category, :title)
    end
end
