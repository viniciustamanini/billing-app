class OverdueRangesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_overdue_range, only: %i[edit update]

  def index
    @overdue_ranges = @company.overdue_ranges.order(:days_from)
  end

  def new
    @overdue_range = @company.overdue_ranges.new
  end

  def create
    @overdue_range = @company.overdue_ranges.new(overdue_range_params)

    if @overdue_range.save
      redirect_to company_segments_path, notice: "Overdue range created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @overdue_range.update(overdue_range_params)
      redirect_to company_segments_path, notice: "Overdue range updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_overdue_range
    @overdue_range = @company.overdue_ranges.find(params[:id])
  end

  def overdue_range_params
    params.require(:overdue_range).permit(
      :days_from, :days_to, :name, :active)
  end
end
