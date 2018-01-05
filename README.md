# Five9s

Setup

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Setup your five9s configution see [configuring five9s](https://github.com/davidrichey/five9s/wiki/Confirguration)
  * Run server with your env variables `AWS_ACCESS_KEY_ID=key AWS_SECRET_ACCESS_KEY=secret S3_BUCKET=bucket mix phx.server`
 

## Idea
Five 9s is an idea to track your website or companies status, uptime and operations.

### Concepts

##### Pings
Minute by minute pings (HTTP requests) to an endpoint. Results: Success/Failure. (Uptime)

  * Send to [Malartu](https://www.malartu.co) to track your uptime metrics
  * Send to Zapier to start a workflow

##### External Services
JSON parsing from S3 or URL to describe exteral services. Good/Warning/Bad. Refreshed hourly and by

##### Incidents
JSON parsing from S3 to describe incidents.

##### Scheduled Maintance
Schedule: Start Time, End Time

Services: Name, Description, Serverity


### Admin Interface

To access the admin interface to update your status page in the brower. You'll need to set two environment variables:

* ADMIN_KEY
* ADMIN_VERIFIER

You will use these to access the admin pages.

```
/status/admin/services?key=ADMIN_KEY&verifier=ADMIN_VERIFIER
/status/admin/incidents?key=ADMIN_KEY&verifier=ADMIN_VERIFIER
/status/admin/maintenance?key=ADMIN_KEY&verifier=ADMIN_VERIFIER
```
