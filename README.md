# Five9s

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Idea
Five 9s is an idea to track your website or companies status, uptime and operations.

### Concepts

##### Pings
Minute by minute pings (HTTP requests) to an endpoint. Results: Success/Failure. (Uptime)

Multiple endpoints: Name and URL

##### External Services
JSON parsing from S3 or URL to describe exteral services. Good/Warning/Bad. Refreshed hourly and by

##### Metrics
Yes, no?

##### Incidents
JSON parsing from S3 or URL to describe incidents. Refreshed hourly and by request

##### Response Times
How to read these. Where to get the data?
Malartu integration?

##### Scheduled Maintance
Schedule: Start Time, End Time

Services: Name, Description

##### Subscriptions
