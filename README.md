![Solano Labs Logo](https://www.solanolabs.com/assets/solano-labs-1cfeb8f4276fc9294349039f602d5923.png) 
# solano_plugins

This repository contains a collection of helpful scripts and examples
for Solano CI.  Pull requests are encouraged.

- [Enumeration](./enumeration) (programatically control which tests are run in a Solano CI Session)
- [Update BitBucket Status](./update_bitbucket_status) (update commit build status during Solano CI Session)
- [VPNC](./external_vpnc) (use vpnc to connect to external VPNs during Solano CI Sessions)

[Solano CI](https://www.solanolabs.com/) is a hosted continuous deployment platform that runs your build
and test suites in the cloud, in parallel.  Your tests run isolated in
freshly prepared workers that are automatically configured with real
database and search engine instances to match your development and
production environments.  Solano CI also supports parallel test running
in our cloud even before you push to a shared branch.
