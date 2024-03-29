# alexandria_api_infra-dev

The contents of this repository should let a user run a dev instance of the
Alexandria API through docker.

Currently Alexandria's production environment depends on a few things to be
fully functional:
  * postgresql
  * nginx
  * uwsgi

The first is setup by the docker-compose.yml file, but the latter two are
currently missing in lieu of Flask's development web server.

# Quickstart

## One-time preparation

1. Run `./build.sh` to clone `hermes` locally and build the docker image, which
should fail the first time with an error:
    error: no priv.py file

2. Create a local `priv.py` file.
    1. In the `hermes/` directory, copy `priv.ex.py` into `priv.py`
    2. Edit `priv.py` so that `skitterClients` is set to an empty list `[]`

3. Run `./build.sh` to build the dev container image.

At this point all one-time preparation should be complete.

### docker engine vs docker desktop

The main Dockerfile creates a user inside the container matching the host user
to match permissions on the mounted source. On docker desktop, mounts are
always mounted as root so an alternate desktop.Dockerfile is included which
should work better there.

`./build.sh` will auto detect whether docker desktop or docker engine is being
used, but can be forced to build one container or the other via the second
argument:
    `./build.sh engine`
or
    `./build.sh desktop`

See also `./build.sh --help` .

## Run in docker-compose

1. Start all db and app containers:
    `docker-compose up -d`
which will make Alexandria available on `localhost:59394`.

2. To view logs, use
    `docker-compose logs app`
or
    `docker-compose logs -f app`
to tail the logs.

3. The status endpoint can be `curl`ed to check basic sanity:
    `curl http://localhost:59394/v0/status`

4. For a more complete check, the lookup endpoint can be used:
    `curl -s -D/dev/stderr 'http://localhost:59394/v0/lookup?q=FIC_URL_HERE' | jq`

The local `./hermes` checkout is mounted into the app container, and the app
container is set to run in dev mode. This means that you can make edits to the
source in `./hermes` and Flask will automatically reload inside the container
to pick up the changes.

## Using the docker-compose db outside of docker-compose

If you want to use `hermes` directly but don't want to bother configuring an
instance of postgres yourself, you can use the one provided by this
docker-compose file.

By default the db only listens on the docker-compose network. To make it
available to other programs running on your host computer, Uncomment the
`ports` definition of the `db` container (lines 12-13):

```
    ports:
      - "127.0.0.1:15432:5432"
```

which makes the db accessible on `localhost:15432`. If this port is already in
use you will need to change it.

Run `docker-compose up -d db` to get `docker-compose` to pick up the new ports
assignment.

### With hermes

The `hermes` CLI can be pointed to the docker-compose db fairly easily. If you
don't already have a venv for it locally, create it either with the make target:
    `make venv`

or manually via:
1. `cd hermes`
2. `python -m venv ./venv`
3. `./venv/bin/python -m pip install --upgrade pip`
4. `./venv/bin/python -m pip install -r requirements.txt`

Then use the `OIL_DB_` env variables to point to the docker-compose postgres:
    `export OIL_DB_HOST=localhost OIL_DB_PORT=15432 OIL_DB_USER=hermes OIL_DB_PASSWORD=pgpass`

You can check that `hermes` is working by using the info command:
    `./hermes info FIC_URL_HERE`

See its `docs/` folder or `./hermes help` for a list of commands and
interactive controls.

