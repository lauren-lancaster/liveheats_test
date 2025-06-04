# spec/system/races_spec.rb

require 'rails_helper'

RSpec.describe "Race System", type: :system do
  before do
    driven_by(:rack_test)
    stub_const("Race::MINIMUM_CAPACITY", 2)
  end

  describe "Creating a Race (new page)" do
    let!(:existing_race) { Race.create!(name: "Existing Race for Index View") }

    context "when filling out the new race form" do
      before do
        visit new_race_path
      end

      it "successfully creates a new race with valid data" do
        expect(page).to have_content("Create Race")

        fill_in "Name", with: "Cross Country"

        click_button "Create Race"

        expect(page).to have_content("was successfully created.")
        expect(page).to have_content("Cross Country")
        expect(current_path).to eq(race_path(Race.find_by(name: "Cross Country")))
      end

      it "fails to create a new race with invalid data" do
        expect(page).to have_content("Create Race")

        fill_in "Name", with: ""
        click_button "Create Race"

        expect(page).to have_selector("div#error_message")
        expect(page).to have_content("prevented this race from being saved:")
        expect(page).to have_content("Name can't be blank")

        expect(page).to have_content("Create Race")
        expect(current_path).to eq(races_path)
      end
    end

    context "navigation from the new race page" do
      it "allows navigating back to the home page" do
        visit new_race_path

        expect(page).to have_link("Back to Home", href: root_path)
        click_link "Back to Home"

        expect(current_path).to eq(root_path)
        expect(page).to have_content("LiveHeats")
      end
    end
  end

  describe "Viewing and Managing a Race (Show Page)" do
    let!(:race_in_setup) { Race.create!(name: "200m Swim", status: "SETUP") }
    
    let!(:race_confirmed) do
      race = Race.create!(name: "Triathalon", status: "SETUP")
      Lane.create!(race: race, student: student_1, lane_number: 1)
      Lane.create!(race: race, student: student_2, lane_number: 2)
      race.update!(status: "CONFIRMED")
      race
    end

    let!(:student_1) { Student.create!(name: "Jane") }
    let!(:student_2) { Student.create!(name: "Lizzy") }

    context "basic display and navigation links" do
      before { visit race_path(race_in_setup) }

      it "displays the race name in the heading" do
        expect(page).to have_selector("h1", text: "Race Details: #{race_in_setup.name}")
      end

      it "shows a link to 'Back home'" do
        expect(page).to have_link("Back home", href: root_path)
      end

      it "shows a link to 'Manage Students'" do
        expect(page).to have_link("Manage Students", href: new_student_path)
      end

      it "shows a link to 'Create Race'" do
        expect(page).to have_link("Create Race", href: new_race_path)
      end
    end

    context "when race status is 'SETUP'" do
      before { visit race_path(race_in_setup) }

      describe "registered students list" do
        it "shows 'No students have been registered' if none are assigned" do
          expect(race_in_setup.lanes.count).to eq(0) # Sanity check
          expect(page).to have_content("No students have been registered for this race yet.")
        end

        context "when students are registered" do
          let!(:lane1) { Lane.create!(race: race_in_setup, student: student_1, lane_number: 1) }
          let!(:lane2) { Lane.create!(race: race_in_setup, student: student_2, lane_number: 2) }

          before do
            visit race_path(race_in_setup)
          end

          it "lists registered students with their lanes" do
            expect(page).to have_content("Registered Students & Lanes")
            expect(page).to have_content("Lane #{lane1.lane_number}: #{student_1.name}")
            expect(page).to have_content("Lane #{lane2.lane_number}: #{student_2.name}")
          end
        end
      end

      describe "minimum capacity note" do
        it "shows the note if below minimum capacity" do
          Lane.create!(race: race_in_setup, student: student_1, lane_number: 1)
          visit race_path(race_in_setup)

          expect(page).to have_content("Note: This race needs at least #{Race::MINIMUM_CAPACITY} participants to be confirmed.")
          expect(page).to have_content("Currently: 1 participant.")
        end

        it "does not show the note if at or above minimum capacity" do
          Lane.create!(race: race_in_setup, student: student_1, lane_number: 1)
          Lane.create!(race: race_in_setup, student: student_2, lane_number: 2)
          visit race_path(race_in_setup)

          expect(page).not_to have_content("Note: This race needs at least #{Race::MINIMUM_CAPACITY} participants to be confirmed.")
        end
      end

      describe "assign student to lane form" do
        context "when students are available for registration" do
          before do
            race_in_setup.lanes.destroy_all
            visit race_path(race_in_setup)
          end

          it "displays the registration form with available students" do
            expect(page).to have_content("Register Student for Next Lane")
            expect(page).to have_content(/Assigning to Lane: \d+/)
            expect(page).to have_select("lane[student_id]", with_options: [student_1.name, student_2.name])
            expect(page).to have_button("Register Student to Lane")
          end

          it "successfully registers an available student to the next lane" do
            select student_1.name, from: "lane[student_id]"
            click_button "Register Student to Lane"

            expect(page).to have_content("#{student_1.name} has been registered for Lane 1.")
          end
        end

        context "when all students are registered for this race" do
          before do
            Lane.create!(race: race_in_setup, student: student_1, lane_number: 1)
            Lane.create!(race: race_in_setup, student: student_2, lane_number: 2)
            visit race_path(race_in_setup)
          end

          it "shows 'All available students have been registered'" do
            expect(page).to have_content("All available students have been registered for this race")
            expect(page).not_to have_button("Register Student to Lane")
          end
        end

        context "when no students exist in the system at all" do
          before do
            Lane.destroy_all
            Student.destroy_all
            visit race_path(race_in_setup)
          end

          it "shows 'There are no students in the system' with a link" do
            expect(page).to have_content("There are no students in the system.")
            expect(page).to have_link("add students", href: new_student_path)
          end
        end
      end

      describe "'Confirm Race' section" do
        it "displays the 'Confirm Race' button and information" do
          expect(page).to have_content("Confirm Race")
          expect(page).to have_content("Race must have minimum 2 students")
          expect(page).to have_button("Confirm Race")
        end

        it "allows confirming the race if minimum capacity is met" do
          Lane.create!(race: race_in_setup, student: student_1, lane_number: 1)
          Lane.create!(race: race_in_setup, student: student_2, lane_number: 2)
          visit race_path(race_in_setup)

          click_button "Confirm Race"

          expect(page).to have_content("Race '#{race_in_setup.name}' has been confirmed.")

          race_in_setup.reload

          expect(race_in_setup.status).to eq("CONFIRMED")
          expect(page).not_to have_content("Register Student for Next Lane")
          expect(page).not_to have_button("Confirm Race")
          expect(page).to have_content("Student registration is closed.")
        end

        it "prevents confirming if minimum capacity is not met (controller should handle)" do
          Lane.create!(race: race_in_setup, student: student_1, lane_number: 1)
          visit race_path(race_in_setup)

          click_button "Confirm Race"

          expect(page).to have_content("Could not confirm race: must have at least 2 participants to be ready")
          race_in_setup.reload
          expect(race_in_setup.status).to eq("SETUP")
          expect(page).to have_button("Confirm Race")
        end
      end
    end

    context "when race status is not SETUP" do
      let!(:lane_for_student_1) { Lane.create!(race: race_in_setup, student: student_1, lane_number: 1) }
      
      before { visit race_path(race_confirmed) }

      it "displays 'Student registration is closed.'" do
        expect(page).to have_content("Student registration is closed.")
      end

      it "does not display the 'Register Student for Next Lane' form" do
        expect(page).not_to have_content("Register Student for Next Lane")
        expect(page).not_to have_button("Register Student to Lane")
      end

      it "does not display the 'Confirm Race' section" do
        expect(page).not_to have_content("Confirm Race")
        expect(page).not_to have_button("Confirm Race")
      end

      it "still lists registered students" do
        expect(page).to have_content("Registered Students & Lanes")
        expect(page).to have_content("Lane #{lane_for_student_1.lane_number}: #{student_1.name}")
      end
    end
  end
end