class StudentsController < ApplicationController
  def new
    @student = Student.new
  end

  def create
    Rails.logger.debug "PARAMS RECEIVED: #{params.inspect}"

    @student = Student.new(student_params)

    if @student.save
      saved_student_name = @student.name
      flash.now[:notice] = "'#{saved_student_name}' was successfully registered."
      @student = Student.new
      render :new
    else
      render :new
    end
  end

  private 

  def student_params
    params.require(:student).permit(:name)
  end
end
