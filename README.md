# Digital Ocean - VMAuto

### Usage

This tool was created to assist with deployment via automation software such as Chef, Puppet, Ansible for cloud deployments on DigitalOcean. The tool is a simple ruby tool that integrates with the DigitalOcean API and can create any number of VM's dynamically.

## Flags

-o | --output | The output directory

-s | --size | The VM's RAM Spec

-n | --name | Name or Names ( ex. test,test2,test3,test4 )

-r | --region | The VMs Region on DO

-i | --image | The VMs operating system image

-t | --token | The token file location
