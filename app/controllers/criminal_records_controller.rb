class CriminalRecordsController < ApplicationController
  before_action :get_criminal, except: [:create]

  def create
    @tenancy = Tenancy.find(params[:tenancy_id])
    @criminal_record = @tenancy.criminal_records.create(criminal_record_params)
    redirect_to tenancy_path(@tenancy)
  end

  def edit
    @criminal_record = CriminalRecord.find_by(id: params[:id])
  end

  def update
    @criminal_record.update(criminal_record_params)
    redirect_to request.referer, notice: "Criminal Record updated successfully!!"
  end

  def destroy
    @criminal_record.destroy
    redirect_to request.referer, notice: "Criminal Record deleted successfully!!"
  end

  private

  def get_criminal
    @criminal_record = CriminalRecord.find_by(id: params[:id])
  end

  def criminal_record_params
    params.require(:criminal_record).permit(:conviction_status, :offence, :date, :judgement)
  end
end
