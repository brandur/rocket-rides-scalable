require_relative "./spec_helper"
require_relative "../simulator"

WebMock.disable_net_connect!

RSpec.describe Simulator do
  before do
    suppress_stdout
    WebMock.enable!
  end

  it "initiates a request" do
    stub_request(:post, "http://localhost:5000/rides").to_return(
      body: JSON.generate({ id: "123" })
    )
    stub_request(:get, "http://localhost:5000/rides/123")

    Simulator.new(port: "5000").run_once

    assert_requested :post, "http://localhost:5000/rides"
    assert_requested :get, "http://localhost:5000/rides/123"
  end
end
