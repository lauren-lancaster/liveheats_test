# spec/controllers/students_controller_spec.rb
require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  let(:valid_attributes) do
    { name: 'William Tell' }
  end

  let(:invalid_attributes) do
    { name: nil }
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end

    it 'returns a successful response' do
      get :new
      expect(response).to be_successful # status 200
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new student in the database' do
        expect {
          post :create, params: { student: valid_attributes }
        }.to change(Student, :count).by(1)
      end

      it 'sets a flash notice' do
        post :create, params: { student: valid_attributes }
        expect(flash.now[:notice]).to eq("'#{valid_attributes[:name]}' was successfully registered.")
      end

      it 're-renders the new template' do
        post :create, params: { student: valid_attributes }
        expect(response).to render_template('new')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new student in the database' do
        expect {
          post :create, params: { student: invalid_attributes }
        }.not_to change(Student, :count)
      end

      it 're-renders the new template' do
        post :create, params: { student: invalid_attributes }
        expect(response).to render_template('new')
      end

      it 'does not set a flash notice' do
        post :create, params: { student: invalid_attributes }
        expect(flash.now[:notice]).to be_nil
      end
    end
  end
end