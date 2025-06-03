# spec/system/students_registration_spec.rb
require 'rails_helper'

RSpec.describe "StudentRegistrations", type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario "User successfully registers a new student" do
    visit new_student_path

    # 'page' is register new student page with form
    expect(page).to have_content("Register Student")
    expect(page).to have_field("Name")
    expect(page).to have_button("Register Student")

    student_name = "Clara Schubert"
    fill_in "Name", with: student_name
    click_button "Register Student"

    expect(page).to have_content("'#{student_name}' was successfully registered.")

    # Check that the form is cleared for a new entry
    expect(find_field("Name").value).to be_nil

    # Verify the student was created in the database
    expect(Student.count).to eq(1)
    expect(Student.last.name).to eq(student_name)

    expect(current_path).to eq(students_path)
  end

  scenario "User fails to register a student due to missing name" do
    visit new_student_path

    fill_in "Name", with: "" 
    click_button "Register Student"

    expect(page).to have_content("Name can't be blank")

    # Verify no student was created
    expect(Student.count).to eq(0)

    expect(page).to have_button("Register Student")
    expect(current_path).to eq(students_path)
  end

  scenario "User clicks 'Back to Home' link" do
    visit new_student_path
    click_link "Back to Home"

    expect(current_path).to eq(root_path)

    Rails.application.reload_routes!
  end
end