# WLCG JWT compliance testsuite

This is the first incarnation of the WLCC JWT compliance testsuite.
The objective is to have a [Robot framework][robot] testsuite to check WLCG JWT
profile support at services (starting with the data management services).

## Running the testsuite with docker

This the recommended way of running the testsuite.
To setup an environment for running the testsuite in docker,
run the following commands:

```bash
docker-compose up trust # and wait for fetch crl to be done
docker-compose up -d ts
```

## Running the testsuite without docker

Find out all the things you need on your machine by looking at the [docker
image](./docker/Dockerfile) used to run the testsuite.

## CI test suite run

The test suite is run on GH actions:

- at each commit on the master branch
- every day at 13 UTC

Reports are stored
[here](https://amnesiac.cloud.cnaf.infn.it:8443/wlcg/jwt-compliance-reports/).

[robot]: https://robotframework.org/
