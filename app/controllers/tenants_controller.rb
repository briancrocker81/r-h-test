class TenantsController < ApplicationController
  before_action :set_tenant, only: [:show, :edit, :update, :destroy]

  # GET /tenants
  # GET /tenants.json
  def index
    @tenants = Tenant.all
  end

  # GET /tenants/1
  # GET /tenants/1.json
  def show
  end

  # GET /tenants/new
  def new
    @tenant = Tenant.new
    # @tenant.student_tenants.build
    @properties = Property.all.map{|p| [p.property_name,p.id ]}
    # @rooms = Room.all.map{ |r| [r.title,r.id]}
  end

  # GET /tenants/1/edit
  def edit
    @properties = Property.all.map{|p| [p.property_name,p.id ]}
    @rooms = @tenant.property.rooms.map{ |r| [r.title,r.id]} rescue []
    # @student = @tenant.student_tenants.rooms.map{ |s| [s.id]} rescue []
  end

  # POST /tenants
  # POST /tenants.json
  def create
    @tenant = Tenant.new(tenant_params)

    respond_to do |format|
      if @tenant.save
        format.html { redirect_to @tenant, notice: 'Tenant was successfully created.' }
        format.json { render :show, status: :created, location: @tenant }
      else
        format.html { render :new }
        format.json { render json: @tenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tenants/1
  # PATCH/PUT /tenants/1.json
  def update
    respond_to do |format|
      if @tenant.update(tenant_params)
        format.html { redirect_to @tenant, notice: 'Tenant was successfully updated.' }
        format.json { render :show, status: :ok, location: @tenant }
      else
        format.html { render :edit }
        format.json { render json: @tenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tenants/1
  # DELETE /tenants/1.json
  def destroy
    @tenant.destroy
    respond_to do |format|
      format.html { redirect_to tenants_url, notice: 'Tenant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tenant
      @tenant = Tenant.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tenant_params
      params.require(:tenant).permit(:first_name, :surname, :dob, :mobile_number, :email, :nationality, :studying_at,
                                     :student_id_number, :course, :guarantor_name, :guarantor_address,
                                     :guarantor_post_code, :guarantor_email, :guarantor_mobile, :guarantor_relationship,
                                     :property_id, :room_id,
                                     student_tenants_attributes: [:studying_at, :student_id_number, :course,
                                                                  :guarantor_name, :guarantor_address,
                                                                  :guarantor_post_code, :guarantor_email,
                                                                  :guarantor_mobile, :guarantor_relationship])
    end
end
