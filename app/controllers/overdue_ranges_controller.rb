class OverdueRangesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_overdue_range, only: %i[edit update activate deactivate]
  before_action :set_overdue_range_list, only: %i[index new create edit update]

  def index
  end

  def new
    @overdue_range = @company.overdue_ranges.new
  end

  def create
    @overdue_range = @company.overdue_ranges.new(overdue_range_params)

    if @overdue_range.save
      flash[:success] = "Overdue range created"
      redirect_to edit_company_overdue_range_path(@company, @overdue_range)
    else
      flash.now[:error] = @overdue_range.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @overdue_range.update(overdue_range_params)
      flash[:success] = "Overdue range updated"
      redirect_to edit_company_overdue_range_path(@company, @overdue_range)
    else
      flash.now[:error] = @overdue_range.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def deactivate
    toggle_active(false, "Faixa de atraso desativada")
  end

  def activate
    toggle_active(true, "Faixa de atraso ativada")
  end

  private

  def toggle_active(value, message)
    if @overdue_range.update(active: value)
      redirect_to company_segments_path, flash: { success: message }
    else
      redirect_to company_segments_path(@company),
      flash: { error: @overdue_range.errors.full_messages.to_sentence }
    end
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_overdue_range
    @overdue_range = @company.overdue_ranges.find(params[:id])
  end

  def set_overdue_range_list
    @overdue_ranges = @company.overdue_ranges.display_order
  end

  def overdue_range_params
    params.require(:overdue_range).permit(
      :days_from, :days_to, :name, :active)
  end
end
