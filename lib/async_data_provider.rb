##
# AsyncDataProvider allows the user to update data in the background on a schedule and return the most recent
# data it knows about. The provider will return nil until data is found for the first time
#
# User of this class should subclass it, implement the time_retrieve_interval, and implment update_data.
#
#
# === Examples
#
#  class SomeSqlData < AsyncDataProvider
#
#  	def initialize
#  		super()
#  		@time_retrieve_interval = 120
#  		@query = "\"SELECT some_data FROM some_table WHERE some_condition > 0;\""
#  	end
#
#  	def update_data(**args)
#  		sql = Sql.new
#
#  		return sql.query(@query)
#  	end
#  end
require 'thread'
require 'singleton'

class AsyncDataProvider
	include Singleton

	def initialize
		@last_time_retrieved       = nil
		@time_retrieve_interval    = "must be implemented"
		@mutex                     = Mutex.new
		@data                      = nil

		# Thread properties
		@thread_abort_on_exception = true
		@thread_priority           = nil
	end
	attr_accessor :thread_abort_on_exception, :thread_priority

	def get_data(**args)
		if(@last_time_retrieved.nil? || (Time.now - @last_time_retrieved >= @time_retrieve_interval))
			@last_time_retrieved = Time.now

			t = Thread.new do
				if(@mutex.try_lock)
					@data = update_data(args)
					@last_time_retrieved = Time.now
					@mutex.unlock
				end
			end
			t.abort_on_exception = @thread_abort_on_exception
			t.priority           = @thread_priority if @thread_priority
		end

		return @data
	end

	def has_data?
		return !@data.nil?
	end

	private
	def update_data(**args)
		raise "must be implemented"
	end
end