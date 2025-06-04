class RacesController < ApplicationController
  before_action :set_race, only: [:edit_results, :update_results, :show, :add_student_to_lane, :confirm]

  def index
  end
  
  def new
    @race = Race.new
  end

  def create
    @race = Race.new(race_params)
    if @race.save
      saved_race_name = @race.name
      redirect_to @race, notice: "'#{saved_race_name}' was successfully created. You can now assign registered students to lanes."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit_results
    @lanes = @race.lanes.includes(:student).order(:lane_number)
    if @lanes.empty?
      redirect_to @race, alert: "This race has no participants assigned to lanes yet."
      
      return
    end
  end

  def update_results
    if @race.update(race_params_for_results)
      @race.update(status: "COMPLETE") # Could also be done as a model method
      redirect_to race_path(@race), notice: 'Race results were successfully updated.'
    else
      @lanes = @race.lanes.includes(:student).order(:lane_number)
      flash.now[:alert] = "Failed to update results."
      render :edit_results, status: :unprocessable_entity
    end
  end

  def show
    # Fetch existing lane assignments for the view
    @lane_assignments = @race.lanes.includes(:student).order(:lane_number)

    if @race.status == "SETUP"
      @next_lane_number = @race.next_available_lane_number
      @available_students = @race.available_students_for_registration
      @new_lane_assignment = @race.lanes.new(lane_number: @next_lane_number) # prefill next lane number on form
    end
  end

  def add_student_to_lane
    unless @race.status == "SETUP"
      flash[:alert] = "Cannot add students as the race status is currently in '#{@race.status.downcase}'."
      redirect_to race_path(@race)
      return
    end

    assigned_lane_number = @race.next_available_lane_number

    # Create a new Lane record. student_place will be nil by default.
    @lane_assignment = @race.lanes.new(
      student_id: params[:lane][:student_id],
      lane_number: assigned_lane_number
    )

    if @lane_assignment.save
      student_name = @lane_assignment.student.name
      flash[:notice] = "#{student_name} has been registered for Lane #{assigned_lane_number}."
    else
      error_messages = @lane_assignment.errors.full_messages.join(', ')
      flash[:alert] = "Failed to register student: #{error_messages}"
    end
    redirect_to race_path(@race)
  end

  def confirm
    if @race.status == "SETUP"
      if @race.update(status: "CONFIRMED")
        flash[:notice] = "Race '#{@race.name}' has been confirmed."
      else
        flash[:alert] = "Could not confirm race: #{@race.errors.full_messages.join(', ')}"
      end
    else
      flash[:alert] = "Race is not in 'SETUP' state and cannot be confirmed at this time."
    end
    redirect_to race_path(@race)
  end

  private

  def set_race
    @race = Race.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Race not found."
    redirect_to races_path
  end

  def race_params
    params.require(:race).permit(:name, :status)
  end

  def race_params_for_results
    params.require(:race).permit(
      lanes_attributes: [:id, :student_place]
    )
  end
end

