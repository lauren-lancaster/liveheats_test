require 'rails_helper'

RSpec.describe Race, type: :model do
  describe "creating a race" do
    context "when creating a new race with a name" do
      let(:new_race_with_name) { Race.new(name: "200m sprint") }

      it "is valid" do
        expect(new_race_with_name).to be_valid
      end

      it "creates a new race" do
        expect { new_race_with_name.save }.to change { Race.count }.by(1)
      end
    end

    context "when registering a student without a name" do
      let(:new_race_without_name) { Student.new(name: nil) }

      it "is not valid" do
        expect(new_race_without_name).not_to be_valid
      end

      it "does not create a new race" do
        expect { new_race_without_name.save }.not_to change { Race.count }
      end
    end
  end
end
