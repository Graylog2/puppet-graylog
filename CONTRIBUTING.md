# Contributing Guide

Please follow [the instructions on graylog.org](https://www.graylog.org/get-involved/).

## Code of Conduct

In the interest of fostering an open and welcoming environment, we as
contributors and maintainers pledge to making participation in our project and
our community a harassment-free experience for everyone, regardless of age, body
size, disability, ethnicity, gender identity and expression, level of experience,
nationality, personal appearance, race, religion, or sexual identity and
orientation.

Please read and understand the [Code of Conduct](https://github.com/Graylog2/puppet-graylog/blob/master/CODE_OF_CONDUCT.md).

## Development

### testing
PDK supports three different types of tests, and contributions are expected to pass all three suites.

#### Validation
PDK should be used to validate the following items:
* metadata.json syntax
* Puppet syntax
* Puppet code style
* Ruby code style

To run the validation is simple.

```bash
pdk validate --parallel
```

#### Unit tests
All classes should have associated unit tests. If you are developing a new class or contributing code to an existing one, it is expected that the code will be accompanied by associated unit test(s).

To run the unit test suite is fairly easy
```bash
# Run the full suite in parallel
pdk test unit --parallel

# Run a specific test
pdk test unit --tests=./spec/classes/init_spec.rb 
```

#### Acceptance testing
To ensure that this module actually does what is expected on a managed machine, we need to test the actual application of it. This is accomplished via litmus, which utilizes docker containers to run the module. The running of this suite is broken up into several different steps.

1. Provision the container(s)
2. Install the puppet agent on the container(s)
3. Install the graylog module (and dependencies) on the container(s)
4. Apply the module and test the container(s)
5. Clean up the container(s)

A normal development process would follow steps 1-4 and then repeat 3 and 4 until all tests pass and then step 5.

For more information about litmus, please see [the documentation](https://puppetlabs.github.io/litmus/).

##### Provision container(s)
There are several sets of containers defined for this module in `provision.yaml`. The full test suite is called default, but this is an arbitrary name. For development, it may be desirable to have only a single container to test against for that you could utilize the set named single.

```bash
# The full set of supported OS containers
pdk bundle exec rake 'litmus:provision_list[default]'

# A single Ubuntu 22.04 container (for quicker test runs)
pdk bundle exec rake 'litmus:provision_list[single]'

# Debian family containers
pdk bundle exec rake 'litmus:provision_list[debian]'

# RedHat family containers
pdk bundle exec rake 'litmus:provision_list[redhat]'
```

##### Install the puppet agent
In order to run puppet code on the containers, puppet needs to be installed on them. It is possible to specify which version of the agent to install, but the default is the latest version.

```bash
# Install latest
pdk bundle exec rake 'litmus:install_agent'

# Install puppet 7
pdk bundle exec rake 'litmus:install_agent[puppet7]'
```

##### Install the module (and dependencies)
Every time you change module code, you need to ensure that code is installed on the test containers.

```bash
pdk bundle exec rake 'litmus:install_module'
```

##### Run the acceptance tests
The acceptance tests run puppet code on the test containers and examines the containers after to ensure that the systems look the way the tests say they should. The thing to note about the acceptance tests is that they don't revert the state of the container between units.

```bash
pdk bundle exec rake 'litmus:acceptance:parallel'
```

##### Clean up the containers
Once you no longer need the containers or need to start again with clean containers, you can run the command to delete all of them.

```bash
pdk bundle exec rake 'litmus:tear_down'
```
