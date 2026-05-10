#cloud-config
package_update: true
packages:
  - strongswan
  - frr

write_files:
  - path: /etc/ipsec.conf
    permissions: '0644'
    content: |
      conn aws
          auto=start
          keyexchange=ikev2
          authby=psk
          left=%defaultroute
          leftid=${azure_public_ip}
          right=${aws_peer_ip}
          ike=aes256-sha256-modp2048
          esp=aes256-sha256
          type=tunnel

  - path: /etc/ipsec.secrets
    permissions: '0600'
    content: |
      ${azure_public_ip} ${aws_peer_ip} : PSK "${shared_key}"

  - path: /etc/frr/frr.conf
    permissions: '0644'
    content: |
      frr version 8.4
      service integrated-vtysh-config
      router bgp ${azure_bgp_asn}
       bgp router-id ${azure_bgp_ip}
       neighbor ${aws_peer_bgp_ip} remote-as 65010
       address-family ipv4 unicast
        network ${vnet_cidr}
       exit-address-family
      route-map PREPEND permit 10
       set as-path prepend ${azure_bgp_asn} ${azure_bgp_asn} ${azure_bgp_asn}

runcmd:
  - sysctl -w net.ipv4.ip_forward=1
  - sysctl -w net.ipv4.conf.all.rp_filter=0
  - systemctl enable strongswan
  - systemctl restart strongswan
  - systemctl enable frr
  - systemctl restart frr
