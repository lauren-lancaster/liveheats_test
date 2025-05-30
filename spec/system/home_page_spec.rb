# spec/system/home_page_spec.rb
require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns a successful response" do
      get root_path
      expect(response).to have_http_status(200)
    end
  end
end