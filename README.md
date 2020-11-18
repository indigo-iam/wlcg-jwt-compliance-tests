# WLCG JWT compliance testsuite

This is the first incarnation of the WLCC JWT compliance testsuite.
The objective is to have a [Robot framework][robot] testsuite to check WLCG JWT
profile support at services (starting with the data management services).

## Storage area configuration pre-requisites

The WLCG storage area authorization at SEs tested by this testsuite should 
be configured as follows:

- WLCG JWT profile capability-based authorization enabled
  - AuthZ will be based on the `storage.*` scopes in the token, e.g. a token
    with the `storage.modify:/` issued by the WLCG token issuer will grant
    write access on the whole storage area.
- Read-only access (i.e., the ability to list directory contents and
  read files) to all members of the WLCG VO, i.e.:
  - all clients presenting a valid VOMS proxy for the WLCG VO
  - all clients presenting a valid JWT token issued by the WLCG token issuer
- Write access (with the exclusion of the `/protected` folder) is granted
  to any client presenting a valid WLCG VO proxy
- Write-access to the `/protected` folder (and sub-folders) is granted to the following principals:
  - all clients presenting a valid VOMS proxy with the `/wlcg/Role=test` role
  - all clients presenting a valid JWT token with the `/wlcg/test` group

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
