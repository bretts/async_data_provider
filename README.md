# Async Data Provider

Allows the user to update data in the background on a schedule and return the most recent data.

### 1. Basic Usage

```
# Create a subclass of AsyncDataProvider
class SomeSqlData < AsyncDataProvider
	def initialize
		super()
		@time_retrieve_interval = 120
		@query = "SELECT some_data FROM some_table WHERE some_condition"
	end

	def update_data(**args)
		sql = Sql.new

		return sql.query(@query)
	end
end

# Ask for the data for the first time
SomeSqlData.instance.get_data
=> nil

# Ask if data exists yet
SomeSqlData.instance.has_data?
=> false

# Ask again for data after the query has completed in the background
SomeSqlData.instance.get_data
=> "bunch of data at timestamp 100"

# Ask again if data exists yet
SomeSqlData.instance.has_data?
=> true

# Ask again for data - The previously found data will get returned until new data is updated in the background
SomeSqlData.instance.get_data
=> "bunch of data at timestamp 100"

# After the time_retrieve_interval of 120 seconds has passed and the data is updated in the background again
# Ask for data again
SomeSqlData.instance.get_data
=> "bunch of data at timestamp 200"
```