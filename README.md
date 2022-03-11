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
- Read and write access (with the exclusion of the `/protected` folder) is allowed to all members of the WLCG VO, i.e.:
  - all clients presenting a valid VOMS proxy for the WLCG VO
  - all clients presenting a valid JWT token with a group attribute
- Write-access to the `/protected` folder (and sub-folders) is granted to the following principals:
  - all clients presenting a valid VOMS proxy with the `/wlcg/Role=test` role
  - all clients presenting a valid JWT token with the `/wlcg/test` group

## Running the testsuite

### Requirements

Basic requirements for running the testsuite are:

- have a local oidc-agent configuration for a client named `wlcg` and registered on the WLCG IAM instance (more details [here][iam-doc-oidc]);
- be member of the `/wlcg/test` optional group in the WLCG IAM.  
  In order to join IAM groups you have to login to IAM and click the "Add to group" button; membership requests will be granted by VO admins afterwards.

[iam-doc-oidc]: https://indigo-iam.github.io/v/v1.7.2/docs/tasks/user/getting-a-token/#registering-a-client

### Run with docker

This is the recommended way of running the testsuite.

To setup an environment for running the testsuite in docker,
run the following commands:

```bash
docker-compose up trust # and wait for fetch crl to be done
docker-compose up -d ts
```



You can now log into the testsuite container:

```
docker-compose exec ts bash
```

You will need to initialize oidc-agent inside the container. 

```
$ eval $(oidc-agent --no-autoload)
$ oidc-add wlcg
```

You can then run the testsuite against one of the registered endpoint

```
cd test-suite
./run-testsuite.sh se-cnaf-amnesiac-storm
```

Additional arguments to `run-testsuite.sh` are forwarded to `robot`, e.g.

```sh
./run-testsuite.sh se-cnaf-amnesiac-storm --test "Token with correct audience is accepted"
```

To add an endpoint, edit the `./test/variables.yaml` file.

### Run without docker

Find out all the things you need on your machine by looking at the [docker
image][docker-image] used to run the testsuite.

## CI test suite run

### GH actions 

The test suite is run on GH actions:

- at each commit on the master branch
- every day at 13 UTC

Reports are stored
[here](https://amnesiac.cloud.cnaf.infn.it:8443/wlcg/jwt-compliance-reports/).

### CNAF SD Jenkins

The test suite is also run on the CNAF software develop group Jenkins instance:

- at each commit of the master branch
- every day at 15 CET (or CEST)

Reports can be accessed
[here](https://ci.cloud.cnaf.infn.it/view/wlcg/job/wlcg-jwt-compliance-tests)

[robot]: https://robotframework.org/
[docker-image]: https://github.com/indigo-iam/robot-framework-docker/blob/main/docker/Dockerfile
