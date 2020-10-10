# CtiKaltura

Implements a client redirect to the nearest Edge server in the CDN network.

# Amnesia
The database in CtiKaltura uses the Amnesia wrapper on Elixir around Mnesia.
Allows you to use Mnesia much more conveniently. For example, when querying, it returns a structure with named fields
, not a tuple, where you need to figure out which value is which field. 
The tables are described in the file `/lib/cti_kaltura/caching/domain_model.ex`
You must initiate the database before using it.

```elixir
mix amnesia.create -d DomainModel --memory
```

The schema will be created using the `--memory`parameter indicates that the data will be stored in memory.

## Possible problems

### Changing attributes of one of the tables

If the fields of one of the DomainModel tables have changed, read and write operations will return :badarg.

Reason:     
The schema is saved to disk and it contains the old table structure.      

Decision:      
Locally or after deployment - drop and re-create the database schema.     

```elixir
mix amnesia.drop -d DomainModel
mix amnesia.create -d DomainModel --memory
mix amnesia.create_indexes
```

### What to do in production mode or on stage when changing the attributes of one of the tables

1. log in via SSH to one of the nodes
2. It is necessary to simultaneously both nodes were running.
3. Log in to the remote console on one of the nodes `./cti_kaltura remote_console`
4. To run the following code:

```
alias CtiKaltura.ReleaseTasks
ReleaseTasks.make_mnesia_cluster_again()
```


5. Wait for the script to complete.  

# Load testing

K6 is used as a framework for load testing https://github.com/loadimpact/k6

Documentation is available at the link https://docs.k6.io/docs

Download and install the framework as directed on Github.
Make the k6 file executable so that you can run tests using ' k6 --option1 --option2 load_testing/test.js`

load testing files are located in `load_testing/*`

To test live requests, run:
`k6 run --vus 300 --rps 200 --duration 300s load_testing/test_live.js`, where:

* `--vus` - number of virtual users;
* `--rps` - number of requests per second;
* `--duration` - duration of testing. Available formats: 40s, 20m40s.

To test all queries:      
`k6 run --vus 300 --rps 200 --duration 300s load_testing/test_requests.js`     

You can also build more complex script scenarios - different number of people, different number
of requests, different testing duration. To do this, use the options https://docs.k6.io/docs/options 
You need to mark the appropriate settings in the `options` variable and run the test without parameters. 

# Deploy

Deploy is performed using a script `deploy.sh` located at the root of the project.
Before you log in to the stage, make sure that you have added a password for remote ssh access to:
<Removed acording to security reasons>

Deploy commands:
1. to deploy to production core1 - `./deploy.sh prod1`;
2. to deploy to production core2 - `./deploy.sh prod2` (There is no second server yet);
3. To deploy to stage core1 - `./deploy.sh stage1`;
4. to deploy to stage core2 - `./deploy.sh stage2`.

## Changes to assets

If changes were made to assets (css or js files were added or changed), a new digest must be generated: `mix phx.digest`.
After that, changes will be made to priv/static - you need to commit the changes and start them.
After the deployment, the changes will be available on the server.

## Migrations

After deployment, migrations are automatically run using the `migrate`command
If you need to perform them manually, run `~/cti_kaltura/bin/cti_kaltura migrate`

## preparing for deployment

<REMOVED>

# Remote keyless entry

Automatic restart is implemented using Monit. The restart algorithm is as follows:

1. Check whether the process specified in the pid file is running;
2. If the corresponding process is not started, the project is restarted using the script;
3. the Script starts the project runs through the list of PID processes and writes it to the pid file;
4. if the process is not started, the cycle is repeated from point 2, Otherwise it is completed.

## Implementation details

### Monit

<REMOVED>

### Scripts

<REMOVED>
