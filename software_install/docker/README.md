![Solano Labs Logo](https://www.solanolabs.com/assets/solano-labs-1cfeb8f4276fc9294349039f602d5923.png) 
# Latest Docker and Docker Compose Version

The example [solano.yml](./solano.yml) demonstrates checking if minimum versions of [Docker](https://www.docker.com/)
and [Docker Compose](https://docs.docker.com/compose/) are installed and available.
If not, the latest versions will be installed. The version comparison and
installation logic could be altered to install specific versions.

The latest versions of Docker are no longer compatible with Solano CI's default Ubuntu 12 based worker model.
[Custom Worker Volumes](https://docs.solanolabs.com/Beta/custom-worker-volumes/) must be used for newer versions of Docker.