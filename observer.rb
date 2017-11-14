require_relative "./api"

class Observer
  def run
    loop do
      run_once
      sleep(SLEEP_DURATION)
    end
  end

  def run_once
    # exclude :default at the zero index
    replica_names = DB.servers[1..-1]

    last_lsns = replica_names.map do |name|
      DB.with_server(name) do
        # Note in PG 10 these changes come into effect and this code will need an
        # update:
        #
        #     pg_last_xlog_replay_location -> pg_last_wal_replay_lsn
        #
        DB[Sequel.lit(<<~eos)].first[:lsn]
          SELECT pg_last_xlog_replay_location() AS lsn;
        eos
      end
    end

    insert_tuples = []
    replica_names.each_with_index do |name, i|
      insert_tuples << { name: name.to_s, last_lsn: last_lsns[i] }
    end

    DB[:replica_statuses].
      insert_conflict(target: :name, update: { last_lsn: Sequel[:excluded][:last_lsn] }).
      multi_insert(insert_tuples)

    $stdout.puts "Updated replica LSNs: results=#{insert_tuples}"

    insert_tuples
  end

  #
  # private
  #

  # Sleep duration in seconds to sleep between runs so that we're not just
  # constantly churning against all our databases.
  SLEEP_DURATION = 0.5
  private_constant :SLEEP_DURATION
end

#
# run
#

if __FILE__ == $0
  # so output appears in Forego
  $stderr.sync = true
  $stdout.sync = true

  Observer.new.run
end
