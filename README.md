Apache2 IPv6 Prefix Updater
===========================

This utility is designed to keep the Apache2 IPv6Local variable in sync with the current delegated IPv6 prefix 
assigned by the ISP. It consists of a script that fetches the current IPv6 prefix and updates the Apache2 
configuration file accordingly. A systemd service and timer are used to automate the process of updating the 
prefix and restarting Apache2 if necessary.

Features
--------

* Automatically updates the IPv6Local variable in the Apache2 configuration file
* Restarts Apache2 only if the IPv6 prefix has changed
* Runs as a systemd service, triggered periodically by a systemd timer
* Provides a pre-built Debian package for easy installation

Installation
------------
Download the latest apache2-ipv6local_1.0.0_all.deb package from the Releases section of the GitHub repository.

Install the package using the following command (replace package_name.deb with the actual file name):

```bash
sudo dpkg -i apache2-ipv6local_1.0.0_all.deb
```

The post-install script automatically activates the service.

Usage
-----
After installation, the utility will automatically update the IPv6Local variable in the Apache2 configuration file and 
reload the Apache2 configuration if necessary. It will run periodically, as specified by the systemd timer (the default
setting is every 8 hours).

If you need to manually trigger an update, run the following command:

```bash
sudo systemctl start update-ipv6local.service
```

The command below will tell you when the next update is scheduled by the systemd timers:
```bash
systemctl list-timers update-ipv6local
```

To temporarily disable the service, you have to stop the timer.
```bash
systemctl stop update-ipv6local.timer
```

To re-enable it, use the `start` command instead of `stop`.

Contributing
------------
The project was developed and is maintained by [CalCool Studios](https://calool.ai), an IT company in the Critical Optimisation portfolio.
We welcome contributions to this project. Please submit a pull request or open an issue on the GitHub repository.

License
-------
This project is released under the MIT License.
