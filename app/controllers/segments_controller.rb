class SegmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_segment, only: %i[edit update activate deactivate]

  def index
    @segments = @company.segments.includes(:overdue_range).order(:id)

    if params[:search].present?
      @segments = @segments.where("segments.description ILIKE ?", "%#{params[:search]}%")
    end

    @overdue_ranges = @company.overdue_ranges.active.order(:days_from)
  end

  def new
    @segment = Segment.new
  end

  def create
    @segment = @company.segments.new(segment_params)

    if @segment.save
      flash[:success] = "Segment created"
      redirect_to company_segments_path
    else
      flash.now[:error] = @segment.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @segment.update(segment_params)
      flash[:success] = "Segment updated"
      redirect_to company_segments_path
    else
      flash.now[:error] = @segment.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def deactivate
    toggle_active(false, "Segmentacao desativada")
  end

  def activate
    toggle_active(true, "Segmentacao ativada")
  end

  private

  def toggle_active(value, message)
    if @segment.update(active: value)
      flash[:success] = message
      redirect_to company_segments_path
    else
      flash.now[:error] = @segment.errors.full_messages.to_sentence
      redirect_to company_segments_path
    end
  end

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
