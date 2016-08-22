# Digital Ocean - VMAuto

### Usage

This tool was created to assist with deployment via automation software such as Chef, Puppet, Ansible for cloud deployments on DigitalOcean. The tool is a simple ruby tool that integrates with the DigitalOcean API and can create any number of VM's dynamically.

## Flags

-o | The output directory

-s | The VM's RAM Spec

-n | Name or Names ( ex. test,test2,test3,test4 )

-r | The VMs Region on DO

-i | The VMs operating system image

-t | The token file location
