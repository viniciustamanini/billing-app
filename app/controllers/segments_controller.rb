class SegmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company

  def index
    @segments = @company.segments.includes(:overdue_range).order(:id)
    @overdue_ranges = @company.overdue_ranges.order(:days_from)
  end

  def new
    @segment = Segment.new
  end

  def create
    @segment = @company.segments.new(segment_params)

    if @segment.save
      redirect_to segments_path, notice: "Segment created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_company
  @company = Company.find(params[:company_id])
  end

  def segment_params
    params.require(:segment).permit(
      :name, :description, :overdue_range_id, :debt_min, :debt_max,
      :include_active_customer, :include_inactive_customer, :active)
  end
end
