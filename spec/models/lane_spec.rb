require 'rails_helper'

RSpec.describe Lane, type: :model do
  let!(:race) { Race.create!(name: "100m Sprint") }
  let!(:student) { Student.create!(name: "Rosa") }

  describe "new lane" do
    context "when creating a new lane with a student, race, lane number, and student place" do
      it "is valid" do
        lane = Lane.new(student: student, race: race, lane_number: 1, student_place: 3)

        expect(lane).to be_valid
      end

      it "creates a new lane" do
        lane = Lane.new(student: student, race: race, lane_number: 1, student_place: 3)

        expect { lane.save } .to change { Lane.count }.by(1)
      end
    end

    context "when creating a new lane without a student place" do
      it "is valid" do
        lane = Lane.new(student: student, race: race, lane_number: 1, student_place: nil)

        expect(lane).to be_valid
      end

      it "creates a new lane" do
        lane = Lane.new(student: student, race: race, lane_number: 1, student_place: nil)

        expect { lane.save }.to change { Lane.count }.by(1)
      end
    end

    context "when creating a new lane without an assigned student" do
      it "is invalid" do
        lane = Lane.new(student: nil, race: race, lane_number: 2, student_place: 2)

        expect(lane).to be_invalid
      end

      it "does not create a new lane" do
        lane = Lane.new(student: nil, race: race, lane_number: 2, student_place: 2)

        expect { lane.save }.not_to change { Lane.count }
      end
    end

    context "when creating a new lane without an associated race" do
      it "is invalid" do
        lane = Lane.new(student: student, race: nil, lane_number: 3, student_place: 4)

        expect(lane).to be_invalid
      end

      it "does not create a new lane" do
        lane = Lane.new(student: student, race: nil, lane_number: 3, student_place: 4)

        expect { lane.save }.not_to change { Lane.count }
      end
    end

    context "when creating a new lane without a lane number" do
      it "is invalid" do
        lane = Lane.new(student: student, race: race, lane_number:nil, student_place: 5)

        expect(lane).to be_invalid
      end

      it "does not create a new lane" do
        lane = Lane.new(student: student, race: race, lane_number:nil, student_place: 5)

        expect { lane.save }.not_to change { Lane.count }
      end
    end

    context "when creating a new lane with an invalid lane number" do
      it "is invalid" do
        lane = Lane.new(student: student, race: race, lane_number: "three", student_place: 5)

        expect(lane).to be_invalid
      end

      it "does not create a new lane" do
        lane = Lane.new(student: student, race: race, lane_number: "three", student_place: 5)

        expect { lane.save }.not_to change { Lane.count }
      end
    end

    context "when creating a new lane and student_place is present and not an integer" do
      it "is invalid" do
        lane = Lane.new(student: student, race: race, lane_number: 1, student_place: "first")

        expect(lane).not_to be_valid
        expect(lane.errors[:student_place]).to include("is not a number")
      end

      it "does not create a new lane" do
        lane = Lane.new(student: student, race: race, lane_number: 1, student_place: "first")

        expect { lane.save }.not_to change { Lane.count }
      end
    end

    context "when the student is not unique in a given race" do
      it "is invalid for the second instance of the student" do
        lane_1 = Lane.new(student: student, race: race, lane_number: 1)
        lane_2 = Lane.new(student: student, race: race, lane_number: 2)

        expect(lane_1.save).to be true
        expect(lane_2).to be_invalid
        expect(lane_2.errors[:student_id]).to include("can only be assigned to one lane per race")
      end
    end

    context "when the same student is in different races" do
      it "is valid for both instances" do
        race_2 = Race.create(name: "300m race")
        lane_1 = Lane.new(student: student, race: race, lane_number: 1)
        lane_2 = Lane.new(student: student, race: race_2, lane_number: 1)

        expect(lane_1.save).to be true
        expect(lane_2).to be_valid
      end
    end
  end
end

