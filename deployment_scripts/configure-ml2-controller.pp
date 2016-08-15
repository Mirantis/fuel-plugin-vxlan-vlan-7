$plugin_name     = 'fuel-plugin-vxlan-vlan-7'
notice("MODULAR: ${plugin_name}/configure-ml2-controller.pp")

$plugin_metadata = hiera($plugin_name, false)

if $plugin_metadata {

  $vlan_range  = pick($plugin_metadata['vlan_range'], '2:4094')
  $vlan_bridge = pick($plugin_metadata['vlan_bridge'], 'br-prv')
  $physnet     = pick($plugin_metadata['physnet'], 'providernet')

  include neutron::params

  neutron_plugin_ml2 {
    'ml2_type_vlan/network_vlan_ranges': value => "${physnet}:${vlan_range}";
  }

  ini_subsetting {'ovs/bridge_mappings':
    ensure               => present,
    section              => 'ovs',
    key_val_separator    => '=',
    subsetting_separator => ',',
    path                 => '/etc/neutron/plugins/ml2/ml2_conf.ini',
    setting              => 'bridge_mappings',
    subsetting           => "${physnet}:",
    value                => $vlan_bridge,
  }

  service { 'neutron-server':
    ensure  => running,
    enable  => true,
  } ->

  service { 'neutron-ovs-agent-service':
    name       => $::neutron::params::ovs_agent_service,
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => false,
    provider   => 'pacemaker',
  }

  Neutron_plugin_ml2<||> ~> Service['neutron-server', 'neutron-ovs-agent-service']
  Ini_subsetting['ovs/bridge_mappings'] ~> Service['neutron-server', 'neutron-ovs-agent-service']

}
