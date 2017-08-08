![Solano Labs Logo](https://www.solanolabs.com/assets/solano-labs-1cfeb8f4276fc9294349039f602d5923.png) 
# Specific Chrome Version

Chrome versions 59 and above are no longer compatible with Solano CI's default Ubuntu 12 based worker volume.
[Custom Worker Volumes](https://docs.solanolabs.com/Beta/custom-worker-volumes/) must be used for newer versions of Chrome.

The example [solano.yml](./solano.yml) demonstrates checking if minimum versions of
[Google Chrome browser](https://www.google.com/chrome/) and
[ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/) are installed and available,
and installing them if not.

The Chrome `.deb` file in the scripting is hosted by Solano because Google does not host older versions of Chrome.

[chromedriver-helper](https://github.com/flavorjones/chromedriver-helper) could be used to install the latest version of ChromeDriver.
