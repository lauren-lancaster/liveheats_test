require 'rails_helper'

RSpec.describe Race, type: :model do
  describe "creating a race" do
    let!(:student) { Student.create!(name: "Noelle") }
    let!(:student_2) { Student.create!(name: "Kris") }

    context "when transitioning the race status from setup" do
      context "with multiple valid participants" do
        let(:race_with_minimum_capicity_achieved) { Race.create!(name: "200m hurdles", status: "SETUP") }

        before do
          Lane.create!(race: race_with_minimum_capicity_achieved, student: student, lane_number: 1)
          Lane.create!(race: race_with_minimum_capicity_achieved, student: student_2, lane_number: 2)
          race_with_minimum_capicity_achieved.status = "CONFIRMED"
        end

        # TODO: could be done with factoryBot for cleaner code
        it "creates a new race" do
          expect { Race.create!(name: "200m hurdles", status: "SETUP") }.to change { Race.count }.by(1)
        end

        it "is valid" do
          expect(race_with_minimum_capicity_achieved).to be_valid
        end
      end

      context "when a race has 1 student" do
        let(:race_below_capacity) { Race.create!(name: "100m sprint", status: "SETUP") }

        before do
          Lane.create!(race: race_below_capacity, student: student, lane_number: 1)
          race_below_capacity.status = "CONFIRMED"
        end

        it "does not create a new race" do
          expect { race_below_capacity }.not_to change { Race.count }
        end
                
        it "is not valid when status is set to CONFIRMED" do
          expect(race_below_capacity).not_to be_valid
        end

        it "adds a base error message" do
          race_below_capacity.valid?
          expect(race_below_capacity.errors[:base]).to include("must have at least 2 participants to be ready.")
        end
      end
    end
  end
end
