fuel-plugin-vxlan-vlan-7
========================

Overview
--------

By default Fuel deploys only one type of neutron segmentation for tenant networks per environment (choice is done while creating environment).  
Plugin can be used in VxLAN deployments to change neutron ml2 config file in order to configure VLAN ranges and bridge mappings.

Supported MOS versions 
----------------------
- MOS 7.0
- MOS 8.0
- MOS 9.0

Prerequisites
-------------
- Modify and update fuel network-template as plugin does not create any intefaces by itself and relay on template to do this

Installing the plugin
---------------------
1. Download and build the plugin from
    [GitHub: Fuel vxlan vlan plugin](https://github.com/Mirantis/fuel-plugin-vxlan-vlan-7)

        # git clone https://github.com/Mirantis/fuel-plugin-vxlan-vlan-7.git
        # fpb --build ./fuel-plugin-vxlan-vlan-7/
        # ls -lash ./fuel-plugin-vxlan-vlan-7/fuel-plugin-vxlan-vlan-*.noarch.rpm

2. Copy the plugin on already installed Fuel Master node; ssh can be used for
    that. If you do not have the Fuel Master node yet, see
    [Quick Start Guide](https://software.mirantis.com/quick-start/) :

        # scp fuel-plugin-vxlan-vlan-*.noarch.rpm root@<Fuel_Master_ip>:~/

3. Install the plugin:

        # cd
        # fuel plugins --install fuel-plugin-vxlan-vlan-*.noarch.rpm

4. Check if the plugin was installed successfully:

        # fuel plugins
        id | name                     | version | package_version
        ---|--------------------------|---------|----------------
        .. | ..                       | ..      | ..
        n  | fuel-plugin-vxlan-vlan-7 | 1.1     | 3.0.0

Configuring the plugin
----------------------
You are safe to go with defaults.  
Before deployment please create/update network template and apply it.  
For network-template examples take a look at ./examples/

Applying network template
-------------------------
Create new environment.  
Before deploy switch to Fuel CLI and perform next steps:  

        # fuel env

To find out env id.  
Ensure your network template has name *network_template_<env_id\>.yaml*, otherwise you will fail to update your environment network settings.  
Make changes to your network template to apply your interface names and roles.  
Perform network settings update

        # fuel network-template --env <env_id> --delete
        # fuel network-template --env <env_id> --upload

Deploy with DVR
---------------
This plugin can be deployed with DVR option enabled.  
To get DVR working, we've added br-ex and br-floating bridges on compute nodes so physnet1 is mapped to br-floating.  
To get rid of unnecessary IP reservations for compute nodes, we've created new role *public-noip* that has no endpoints.  
Take a look on examples/lnx-br-bond-dvr.yaml for details.

Verification
------------
You should be able to create VLAN segmentation network. Please use *providernet* as physical network name.
