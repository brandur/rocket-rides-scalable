require "rspec"
require 'webmock/rspec'

# port on which the primary is running
POSTGRES_PORT = ENV["POSTGRES_PORT"] || abort("need POSTGRES_PORT")

ENV["DATABASE_URL"] = "postgres://localhost:#{POSTGRES_PORT}/rocket-rides-reads-test"
ENV["RACK_ENV"] = "test"

require_relative "../api"

def clear_database
  DB.transaction do
    DB.run("TRUNCATE rides CASCADE")
    DB.run("TRUNCATE users CASCADE")
  end
end

def suppress_stdout
  $stdout = StringIO.new unless verbose?
end

def verbose?
  ENV["VERBOSE"] == "true"
end
