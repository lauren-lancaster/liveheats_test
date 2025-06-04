require 'rails_helper'

RSpec.describe RacesController, type: :controller do
  let(:valid_attributes) do
    { name: '100m Dash: Heat One' }
  end
  let(:invalid_attributes) do
    { name: "" }
  end

  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new race in the database" do
        expect {
          post :create, params: { race: valid_attributes }
        }.to change(Race, :count).by(1)
      end

      it "sets the race to the default status" do
        post :create, params: { race: valid_attributes }
        expect(assigns(:race).status).to eq("SETUP")
      end

      it "redirects to the created race's show page" do
        post :create, params: { race: valid_attributes }
        expect(response).to redirect_to(Race.last)
      end

      it "sets a success flash notice" do
        post :create, params: { race: valid_attributes }
        expect(flash[:notice]).to match(/'#{Race.last.name}' was successfully created/)
      end
    end

    context "with invalid params" do
      it "does not create a new Race" do
        expect {
          post :create, params: { race: invalid_attributes }
        }.not_to change(Race, :count)
      end

      it "re-renders the 'new' template with unprocessable_entity status" do
        post :create, params: { race: invalid_attributes }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #edit_results" do
    let!(:student_1) { Student.create!(name: "Michelle") }
    let!(:student_2) { Student.create!(name: "Orla") }
    let!(:confirmed_race) do
          race = Race.create!(name: "Confirmed Race", status: "SETUP")
          Lane.create!(race: race, student: student_1, lane_number: 1)
          Lane.create!(race: race, student: student_2, lane_number: 2)
          race.update!(status: "CONFIRMED")

          race
    end

    context "when race exists and has lanes" do
      before { get :edit_results, params: { id: confirmed_race.id } }

      it "renders the edit_results template" do
        expect(response).to render_template(:edit_results)
      end
    end

    context "when race exists and has no lanes" do
      let!(:race_no_lanes) { Race.create!(name: "400m Swim", status: "SETUP") }

      before { get :edit_results, params: { id: race_no_lanes.id } }

      it "redirects to the race show page" do
        expect(response).to redirect_to(race_path(race_no_lanes))
      end

      it "sets an alert flash message" do
        expect(flash[:alert]).to eq("This race has no participants assigned to lanes yet.")
      end
    end

    context "when race does not exist" do
      it "redirects to the races index page" do
        # TODO: redirect to index path
      end

      it "sets a flash alert message" do
        # expect(flash[:alert]).to eq("Race not found.")
      end
    end
  end

  describe "PATCH #update_results" do
    let!(:student_1) { Student.create!(name: "Michelle") }
    let!(:student_2) { Student.create!(name: "Orla") }
    let!(:race_for_update) do
          race = Race.create!(name: "Confirmed Race", status: "SETUP")
          Lane.create!(race: race, student: student_1, lane_number: 1)
          Lane.create!(race: race, student: student_2, lane_number: 2)
          race.update!(status: "CONFIRMED")

          race
    end
    let(:lane_1) { race_for_update.lanes.find_by(lane_number: 1) }
    let(:lane_2) { race_for_update.lanes.find_by(lane_number: 2) }

    context "with valid parameters" do
      let(:valid_params) do
        {
          id: race_for_update.id,
          race: {
            lanes_attributes: {
              "0" => { id: lane_1.id, student_place: "1" },
              "1" => { id: lane_2.id, student_place: "2" }
            }
          }
        }
      end

      it "updates the student_place for the lanes" do
        patch :update_results, params: valid_params
        expect(lane_1.reload.student_place).to eq(1)
        expect(lane_2.reload.student_place).to eq(2)
      end

      it "redirects to the race show page" do
        patch :update_results, params: valid_params
        expect(response).to redirect_to(race_path(race_for_update))
      end

      it "sets a success notice flash message" do
        patch :update_results, params: valid_params
        expect(flash[:notice]).to eq('Race results were successfully updated.')
      end

      it "updates the race status to COMPLETE" do
        patch :update_results, params: valid_params
        race_for_update.reload
        
        expect(race_for_update.status).to eq("COMPLETE")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params_gap) do
        {
          id: race_for_update.id,
          race: {
            lanes_attributes: {
              "0" => { id: lane_1.id, student_place: "1" },
              "1" => { id: lane_2.id, student_place: "3" }
            }
          }
        }
      end

      before { patch :update_results, params: invalid_params_gap }

      it "does not update the student_place for the lanes" do
        expect(lane_1.reload.student_place).to be_nil
        expect(lane_2.reload.student_place).to be_nil
      end

      it "re-renders the edit_results template with unprocessable_entity status" do
        expect(response).to render_template(:edit_results)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "sets an alert flash message" do
        expect(flash.now[:alert]).to eq("Failed to update results.")
      end
    end
  end

  describe "GET #show" do
    let!(:student_1) { Student.create!(name: "Bert") }
    let!(:student_2) { Student.create!(name: "Ernie") }

    context "when race exists" do
      let!(:race_in_setup) { Race.create!(name: "Setup Race", status: "SETUP") }
      let!(:lane_1) { Lane.create!(race: race_in_setup, student: student_1, lane_number: 1) }
      let!(:lane_2) { Lane.create!(race: race_in_setup, student: student_2, lane_number: 2) }
      
      before { get :show, params: { id: race_in_setup.to_param } }

      it "renders the 'show' template and responds with success" do
        expect(response).to render_template(:show)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when race does not exist" do
      it "redirects to races_path with an alert" do
        get :show, params: { id: "nonexistent-id" }
        expect(response).to redirect_to(races_path)
        expect(flash[:alert]).to eq("Race not found.")
      end
    end
  end

  describe "POST #add_student_to_lane" do
    let!(:race_in_setup) { Race.create!(name: "100m sprint", status: "SETUP") }
    let!(:student_1) { Student.create!(name: "Maya") }
    let!(:student_2) { Student.create!(name: "Phoenix") }

    let(:lane_params) { { student_id: student_1.id } }

    context "when the race exists" do
      context "and race status is 'SETUP'" do
        context "with valid student_id" do
          it "creates a new lane for the race" do
            expect {
              post :add_student_to_lane, params: { id: race_in_setup.to_param, lane: lane_params }
            }.to change(race_in_setup.lanes, :count).by(1)
          end

          it "assigns the correct sequential lane number" do
            post :add_student_to_lane, params: { id: race_in_setup.to_param, lane: lane_params }
            expect(race_in_setup.lanes.last.lane_number).to eq(1)

            post :add_student_to_lane, params: { id: race_in_setup.to_param, lane: { student_id: student_2.id } }
            expect(race_in_setup.lanes.last.lane_number).to eq(2)
          end

          it "redirects to the race show page" do
            post :add_student_to_lane, params: { id: race_in_setup.to_param, lane: lane_params }
            expect(response).to redirect_to(race_path(race_in_setup))
          end

          it "sets a success flash notice" do
            post :add_student_to_lane, params: { id: race_in_setup.to_param, lane: lane_params }
            expect(flash[:notice]).to match(/#{student_1.name} has been registered for Lane \d+/)
          end
        end

        context "when the same student is added to the race twice" do
          before do
            Lane.create!(race: race_in_setup, student: student_1, lane_number: 1)
          end

          it "does not create an additional Lane" do
            expect { 
              post :add_student_to_lane, params: { id: race_in_setup.to_param, lane: lane_params }
            }.not_to change(race_in_setup.lanes, :count)
          end

          it "sets an alert flash message with model errors" do
            post :add_student_to_lane, params: { id: race_in_setup.to_param, lane: lane_params }
            expect(flash[:alert]).to match(/Student can only be assigned to one lane per race/)
          end
        end
      end

      context "and race status is not SETUP" do
        let!(:confirmed_race) do
          race = Race.create!(name: "Confirmed Race", status: "SETUP")
          Lane.create!(race: race, student: student_1, lane_number: 1)
          Lane.create!(race: race, student: student_2, lane_number: 2)
          race.update!(status: "CONFIRMED")

          race
        end

        it "does not create a new Lane" do
          expect {
            post :add_student_to_lane, params: { id: confirmed_race.to_param, lane: lane_params }
          }.not_to change(Lane, :count)
        end

        it "sets an alert flash message" do
          post :add_student_to_lane, params: { id: confirmed_race.to_param, lane: lane_params }
          expect(flash[:alert]).to match(/Cannot add students as the race status is currently in 'confirmed'/)
        end

        it "redirects to the race show page" do
          post :add_student_to_lane, params: { id: confirmed_race.to_param, lane: lane_params }
          expect(response).to redirect_to(race_path(confirmed_race))
        end
      end
    end

    context "when race does not exist" do
      it "redirects to races_path with an alert flash message" do
        post :add_student_to_lane, params: { id: "nonexistent-id", lane: lane_params }
        expect(response).to redirect_to(races_path)
        expect(flash[:alert]).to eq("Race not found.")
      end
    end
  end

  describe "PATCH #confirm" do
    let!(:student_1) { Student.create!(name: "Wilson") }
    let!(:student_2) { Student.create!(name: "Clive") }

    context "when race exists" do
      context "and race status is SETUP" do
        let!(:race_to_confirm) { Race.create!(name: "Swim Heat 1", status: "SETUP") }

        context "and meets minimum student capacity" do
          before do
            Lane.create!(race: race_to_confirm, student: student_1, lane_number: 1)
            Lane.create!(race: race_to_confirm, student: student_2, lane_number: 2)
          end

          it "updates the race status to CONFIRMED" do
            patch :confirm, params: { id: race_to_confirm.to_param }
            race_to_confirm.reload
            expect(race_to_confirm.status).to eq("CONFIRMED")
          end

          it "sets a success flash notice" do
            patch :confirm, params: { id: race_to_confirm.to_param }
            expect(flash[:notice]).to match(/Race '#{race_to_confirm.name}' has been confirmed/)
          end

          it "redirects to the race show page" do
            patch :confirm, params: { id: race_to_confirm.to_param }
            expect(response).to redirect_to(race_path(race_to_confirm))
          end
        end

        context "and minimum student capacity is not met" do
          it "does not update the race status" do
            patch :confirm, params: { id: race_to_confirm.to_param }
            race_to_confirm.reload
            expect(race_to_confirm.status).to eq("SETUP")
          end

          it "sets an alert flash message with model validation errors" do
            patch :confirm, params: { id: race_to_confirm.to_param }
            expect(flash[:alert]).to match(/Could not confirm race: must have at least #{Race::MINIMUM_CAPACITY} participants to be ready./)
          end
        end
      end

      context "and race status is not SETUP" do
        let!(:completed_race) { Race.create!(name: "Completed Race", status: "COMPLETE") }

        it "does not update the race status" do
          patch :confirm, params: { id: completed_race.to_param }
          completed_race.reload
          expect(completed_race.status).to eq("COMPLETE")
        end

        it "sets an alert flash message" do
          patch :confirm, params: { id: completed_race.to_param }
          expect(flash[:alert]).to eq("Race is not in 'SETUP' state and cannot be confirmed at this time.")
        end
      end
    end

    context "when race does not exist" do
      it "redirects to races_path with an alert" do
        patch :confirm, params: { id: "nonexistent-id" }
        expect(response).to redirect_to(races_path)
        expect(flash[:alert]).to eq("Race not found.")
      end
    end
  end
end