require 'rails_helper'

RSpec.describe Student, type: :model do
  describe "registering a student" do
    context "when registering a new student with a name" do
      let(:new_student_with_name) { Student.new(name: "Eva") }

      it "is valid" do
        expect(new_student_with_name).to be_valid
      end
    end

    context "when registering a student without a name" do
      let(:new_student_without_name) { Student.new(name: nil) }

      it "is not valid" do
        expect(new_student_without_name).not_to be_valid
      end

      it "throws an error message" do
        # TODO: expect an error message
      end
    end
  end
end
