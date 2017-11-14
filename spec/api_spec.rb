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

  let(:user) do
    User.create(
      email: USER_EMAIL,
    )
  end

  before do
    clear_database
    user # these accessors are lazy, so ensure user exists
  end

  describe "POST /rides" do
    it "succeeds and creates a ride" do
      post "/rides", VALID_PARAMS, headers
      expect(last_response.status).to eq(201)
      expect(unwrap_field(last_response.body, :distance)).to eq(
        VALID_PARAMS["distance"].round(1)
      )

      expect(Ride.count).to eq(1)

      # A `min_lsn` should have been set on the user after the ride was
      # created.
      user.reload
      expect(user.min_lsn).not_to be_nil
    end

    describe "failure" do
      it "denies requests without authorization" do
        post "/rides", VALID_PARAMS, {}
        expect(last_response.status).to eq(401)
        expect(unwrap_error(last_response.body)).to \
          eq(Messages.error_auth_required)
      end

      it "denies requests with invalid authorization" do
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

  describe "GET /rides/:id" do
    let(:ride) do
      Ride.create(
        distance: 123.0,
        user_id: user.id,
      )
    end

    it "succeeds and retrieves a ride" do
      get "/rides/#{ride.id}", {}, headers
      expect(last_response.status).to eq(200)
      expect(unwrap_field(last_response.body, :distance)).to eq(
        ride.distance.round(1),
      )
    end

    it "reads from a replica given a user min_sln" do
      # Note that while we do set a `min_sln` for the user, we're not actually
      # confirming that the API is reading off the replica in this test (it
      # probably is, but it's not actually checked). We should try to do a
      # little better.
      update_user_min_lsn(user)

      get "/rides/#{ride.id}", {}, headers
      expect(last_response.status).to eq(200)
      expect(unwrap_field(last_response.body, :distance)).to eq(
        ride.distance.round(1),
      )
    end

    describe "failure" do
      it "denies requests without authorization" do
        get "/rides/#{ride.id}", {}, {}
        expect(last_response.status).to eq(401)
        expect(unwrap_error(last_response.body)).to \
          eq(Messages.error_auth_required)
      end

      it "denies requests with invalid authorization" do
        get "/rides/#{ride.id}", {}, {
          "HTTP_AUTHORIZATION" => "user-does-not-exist@example.com"
        }
        expect(last_response.status).to eq(401)
        expect(unwrap_error(last_response.body)).to \
          eq(Messages.error_auth_invalid)
      end

      it "404s requests that ask for IDs that don't exist" do
        get "/rides/0", {}, headers
        expect(last_response.status).to eq(404)
        expect(unwrap_error(last_response.body)).to \
          eq(Messages.error_not_found(object: "ride", id: "0"))
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
    unwrap_field(body, :error)
  end

  private def unwrap_field(body, field)
    data = JSON.parse(body, symbolize_names: true)
    expect(data).to have_key(field)
    data[field]
  end
end
