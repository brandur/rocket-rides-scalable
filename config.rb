require "logger"
require "pg"
require "sequel"

NUM_REPLICAS  = Integer(ENV["NUM_REPLICAS"]  || abort("need NUM_REPLICAS"))
POSTGRES_PORT = Integer(ENV["POSTGRES_PORT"] || abort("need POSTGRES_PORT"))

DB = Sequel.connect("postgres://localhost:#{POSTGRES_PORT}/rocket-rides-reads",
  servers: Hash[NUM_REPLICAS.times.map { |i|
    [:"replica#{i}", { port: POSTGRES_PORT + 1 + i }]
  }]
)

# a verbose mode to help with debugging
if ENV["VERBOSE"] == "true"
  DB.loggers << Logger.new($stdout)

  # Emits the name of the server that a query was sent to in logs. Useful for
  # verifying that queries that we think are going to replicas are actually
  # going to replicas.
  DB.extension :server_logging
end
