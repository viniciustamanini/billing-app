class SegmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_segment, only: %i[edit update]

  def index
    @segments = @company.segments.includes(:overdue_range).order(:id)

    if params[:search].present?
      @segments = @segments.where("segments.description ILIKE ?", "%#{params[:search]}%")
    end

    @overdue_ranges = @company.overdue_ranges.order(:days_from)
  end

  def new
    @segment = Segment.new
  end

  def create
    @segment = @company.segments.new(segment_params)

    if @segment.save
      redirect_to company_segments_path, notice: "Segment created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @segment.update(segment_params)
      redirect_to company_segments_path, notice: "Segment updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_segment
    @segment = @company.segments.find(params[:id])
  end

  def segment_params
    params.require(:segment).permit(
      :name, :description, :overdue_range_id, :debt_min, :debt_max,
      :include_active_customer, :include_inactive_customer, :active)
  end
end
