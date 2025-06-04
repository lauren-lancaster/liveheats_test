require 'rails_helper'

RSpec.describe Lane, type: :model do
  let!(:race) { Race.create!(name: "100m Sprint") }
  let!(:race_2) { Race.create!(name: "300m race") }
  let!(:student) { Student.create!(name: "Rosa") }
  let!(:student_2) { Student.create!(name: "George") }
  let!(:student_3) { Student.create!(name: "Jessica") }

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

    context "when creating a new lane and student_place is present but below 1" do
      it "is invalid" do
        lane = Lane.new(student: student, race: race, lane_number: 1, student_place: 0)

        expect(lane).not_to be_valid
        expect(lane.errors[:student_place]).to include("must be greater than 0")
      end

      it "does not create a new lane" do
        lane = Lane.new(student: student, race: race, lane_number: 1, student_place: 0)

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
        lane_1 = Lane.new(student: student, race: race, lane_number: 1)
        lane_2 = Lane.new(student: student, race: race_2, lane_number: 1)

        expect(lane_1.save).to be true
        expect(lane_2).to be_valid
      end
    end

    context "when a lane number has multiple students in a given race" do
      it "is invalid for the second instance of the lane number" do
        lane = Lane.new(student: student, race: race, lane_number: 1)
        lane_duplicate = Lane.new(student: student_2, race: race, lane_number: 1)

        expect(lane.save).to be true
        expect(lane_duplicate).to be_invalid
        expect(lane_duplicate.errors[:lane_number]).to include("can only have one student")
      end
    end

    context "when a lane number is in different races" do
      it "is valid for both instances of the lane number" do
        lane = Lane.new(student: student, race: race, lane_number: 1)
        lane_duplicate = Lane.new(student: student, race: race_2, lane_number: 1)

        expect(lane.save).to be true
        expect(lane_duplicate).to be_valid
      end
    end
  end

  describe "update lane with place attribute" do
    let!(:race_confirmed) do
      race = Race.create!(name: "Triathlon", status: "SETUP")
      Lane.create!(race: race, student: student, lane_number: 1)
      Lane.create!(race: race, student: student_2, lane_number: 2)
      Lane.create!(race: race, student: student_3, lane_number: 3)
      race.update!(status: "CONFIRMED")
      race
    end

    it "can record a valid numerical place" do
      success = race_confirmed.lanes[0].update(student_place: 1)
      
      expect(success).to be true
      race_confirmed.reload 
      expect(race_confirmed.lanes[0].student_place).to eq(1)
    end

    context "when places are updated" do
      let(:lane_1) { race_confirmed.lanes.find_by!(student: student) }
      let(:lane_2) { race_confirmed.lanes.find_by!(student: student_2) }
      let(:lane_3) { race_confirmed.lanes.find_by!(student: student_3) }

      context "and the places are correct" do
        context "and places are sequential" do
          before do
            lane_1.update!(student_place: 1)
            lane_2.race.lanes.reload
            lane_2.update!(student_place: 2)
          end

          it "is valid" do
            lane_3.student_place = 3
            lane_3.race.lanes.reload

            expect(lane_3).to be_valid
          end
        end

        context "and the places include a tie" do
          before do
            lane_1.update!(student_place: 1)
          end

          it "is valid" do
            lane_2.student_place = 1
            lane_2.race.lanes.reload
          
            expect(lane_2).to be_valid
          end
        end

        context "and the places include a three way tie" do
          before do
            lane_1.update!(student_place: 1)
            lane_2.race.lanes.reload
            lane_2.update!(student_place: 1)
          end

          it "is valid" do
            lane_3.student_place = 1
            lane_3.race.lanes.reload

            expect(lane_3).to be_valid
          end
        end

        context "and the places have a gap after a tie" do
          before do
            lane_1.update!(student_place: 1)
            lane_2.race.lanes.reload
            lane_2.update!(student_place: 1)
          end

          it "is valid" do
            lane_3.student_place = 3
            lane_3.race.lanes.reload

            expect(lane_3).to be_valid
          end
        end
      end

      context "and the places are incorrect" do
        context "and there is a gap" do
          before do
            lane_1.update!(student_place: 1)
            lane_2.race.lanes.reload
            lane_2.update!(student_place: 2)
          end

          it "is invalid" do
            lane_3.student_place = 4
            lane_3.race.lanes.reload

            expect(lane_3).to be_invalid
          end

          it "throws an error message" do
            lane_3.student_place = 4
            lane_3.race.lanes.reload
            lane_3.valid? #calls lane_3

            expect(lane_3.errors[:student_place]).to include(a_string_matching(/is not valid/))
          end
        end

        context "and there is no gap after a tie" do
          before do
            lane_1.update!(student_place: 1)
            lane_2.race.lanes.reload
            lane_2.update!(student_place: 1)
          end

          it "is invalid" do
            lane_3.student_place = 2
            lane_3.race.lanes.reload

            expect(lane_3).to be_invalid
          end

          it "throws an error message" do
            lane_3.student_place = 2
            lane_3.race.lanes.reload
            lane_3.valid? #calls lane_3

            expect(lane_3.errors[:student_place]).to include(a_string_matching(/is not valid/))
          end
        end

        context "and the first place is not 1" do
          it "is invalid" do
            lane_1.student_place = 2

            expect(lane_1).to be_invalid
          end

          it "throws an error message" do
            lane_1.student_place = 2
            lane_1.race.lanes.reload
            lane_1.valid? #calls lane_3

            expect(lane_1.errors[:student_place]).to include(a_string_matching(/is not valid/))
          end
        end
      end
    end
  end
end

