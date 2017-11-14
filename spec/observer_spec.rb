require_relative "./spec_helper"
require_relative "../observer"

RSpec.describe Observer do
  before do
    clear_database
    suppress_stdout
  end

  it "runs and updates replica lsns" do
    insert_tuples = Observer.new.run_once
    expect(insert_tuples).not_to be_empty
    expect(insert_tuples.map { |t| t[:name] }).not_to include(:default)
    expect(insert_tuples.map { |t| t[:name] }).to \
      eq(DB.servers[1..-1].map { |name| name.to_s })
  end
end
