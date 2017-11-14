require "rspec"
require 'webmock/rspec'

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
