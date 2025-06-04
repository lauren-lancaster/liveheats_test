require 'rails_helper'

RSpec.describe "Races", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/races/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /races" do 
    context "with valid parameters" do
      let(:valid_params) { { race: { name: "500m Dash" } } }

      it "creates a new Race" do
        expect {
          post races_path, params: valid_params
        }.to change(Race, :count).by(1)
      end

      it "redirects to the created race's show page" do
        post races_path, params: valid_params
        expect(response).to redirect_to(race_path(Race.last))
        expect(response).to have_http_status(:found) # 302
      end

      it "sets a success flash message" do
        post races_path, params: valid_params
        follow_redirect!
        expect(flash[:notice]).to match(/'#{Race.last.name}' was successfully created/)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { race: { name: "" } } }

      it "does not create a new Race" do
        expect {
          post races_path, params: invalid_params
        }.not_to change(Race, :count)
      end

      it "has http status unprocessable entity" do
        post races_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
