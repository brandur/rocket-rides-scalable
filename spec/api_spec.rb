require "rack/test"
require "securerandom"

require_relative "./spec_helper"

RSpec.describe API do
  include Rack::Test::Methods

  USER_EMAIL = "user@example.com"

  VALID_PARAMS = {
    "distance" => 123.0,
  }.freeze

  def app
    API
  end

  before do
    clear_database

    @user = User.create(
      email: USER_EMAIL
    )
  end

  describe "POST /rides" do
    it "succeeds and creates a ride and log record" do
      post "/rides", VALID_PARAMS, headers
      expect(last_response.status).to eq(201)
      expect(unwrap_ok(last_response.body)).to eq(
        Messages.ok
      )

      expect(Ride.count).to eq(1)
    end

    describe "failure" do
      it "denis requests without authorization" do
        post "/rides", VALID_PARAMS, {}
        expect(last_response.status).to eq(401)
        expect(unwrap_error(last_response.body)).to \
          eq(Messages.error_auth_required)
      end

      it "denis requests with invalid authorization" do
        post "/rides", VALID_PARAMS, {
          "HTTP_AUTHORIZATION" => "user-does-not-exist@example.com"
        }
        expect(last_response.status).to eq(401)
        expect(unwrap_error(last_response.body)).to \
          eq(Messages.error_auth_invalid)
      end

      it "denies requests that are missing parameters" do
        post "/rides", {}, headers
        expect(last_response.status).to eq(422)
        expect(unwrap_error(last_response.body)).to \
          eq(Messages.error_require_param(key: "distance"))
      end

      it "denies requests that are the wrong type" do
        post "/rides", { "distance" => "foo" }, headers
        expect(last_response.status).to eq(422)
        expect(unwrap_error(last_response.body)).to \
          eq(Messages.error_require_float(key: "distance"))
      end
    end
  end

  #
  # helpers
  #

  private def headers
    # The demo API trusts that we are who we say we are. A record for this user
    # is created in the `before` block.
    { "HTTP_AUTHORIZATION" => USER_EMAIL }
  end

  private def unwrap_error(body)
    data = JSON.parse(body, symbolize_names: true)
    expect(data).to have_key(:error)
    data[:error]
  end

  private def unwrap_ok(body)
    data = JSON.parse(body, symbolize_names: true)
    expect(data).to have_key(:message)
    data[:message]
  end
end
