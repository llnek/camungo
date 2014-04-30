<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:output method="text" />
   <xsl:variable name="xslversion" select="'2009-07-15-207071'"/>

   <xsl:template match="/">
      <xsl:text># Amazon Web Services
# Virtual Private Cloud
#
# AWS utilizes unique identifiers to manipulate the configuration of 
# a VPN Connection. Each VPN Connection is assigned a VPN Connection Identifier
# and is associated with two other identifiers, namely the 
# Customer Gateway Identifier and the VPN Gateway Identifier.
#
# Your VPN Connection ID   : </xsl:text>
        <xsl:value-of select="vpn_connection/@id"/><xsl:text>
# Your VPN Gateway ID      : </xsl:text>
        <xsl:value-of select="vpn_connection/vpn_gateway_id"/><xsl:text>
# Your Customer Gateway ID : </xsl:text>
        <xsl:value-of select="vpn_connection/customer_gateway_id"/><xsl:text>
#
# This configuration consists of two tunnels. Both tunnels must be 
# configured on your Customer Gateway.
#
# This configuration was tested on a Juniper SSG-5 running ScreenOS 6.1R6.
#
</xsl:text>
      <xsl:apply-templates select="vpn_connection" />
      <xsl:text>
# Additional Notes and Questions</xsl:text>
      <xsl:text>
#  - Amazon Virtual Private Cloud Getting Started Guide: 
#       http://docs.amazonwebservices.com/AWSVPC/latest/GettingStartedGuide
#  - Amazon Virtual Private Cloud Network Administrator Guide: 
#       http://docs.amazonwebservices.com/AWSVPC/latest/NetworkAdminGuide
#  - XSL Version: </xsl:text><xsl:value-of select="$xslversion"/><xsl:text>
      </xsl:text>
   </xsl:template>

   <!-- VPN Connection -->
   <xsl:template match="vpn_connection">
      <xsl:apply-templates select="ipsec_tunnel">
         <xsl:with-param name="cgwid" select="./customer_gateway_id" />
         <xsl:with-param name="vgwid" select="./vpn_gateway_id" />
      </xsl:apply-templates>
   </xsl:template> <!-- VPN Connection -->

   <!-- IPSec Tunnel -->
   <xsl:template match="vpn_connection/ipsec_tunnel">
      <xsl:param name="cgwid"/>
      <xsl:param name="vgwid"/>
      <xsl:variable name="id" select="concat(./../@id, '-', string(position()))"/>
      <xsl:variable name="peer" select="./vpn_gateway/tunnel_inside_address/ip_address" />
      <xsl:variable name="gateway" select="./vpn_gateway/tunnel_outside_address/ip_address" />
      <xsl:variable name="cgwip" select="./customer_gateway/tunnel_outside_address/ip_address" />
      <xsl:variable name="ipsec_protocol" select="./ipsec/protocol"/>

      <xsl:variable name="cgwcidr"
         select="concat('/', ./customer_gateway/tunnel_inside_address/network_cidr)" />
      <xsl:variable name="cgwaddr" 
         select="concat(./customer_gateway/tunnel_inside_address/ip_address, $cgwcidr)" />
      <xsl:variable name="tunintf" select="concat('tunnel.',string(position()))" />

<xsl:text># --------------------------------------------------------------------------------
# IPSec Tunnel #</xsl:text><xsl:value-of select="position()"/><xsl:text>
# --------------------------------------------------------------------------------
</xsl:text>

      <xsl:apply-templates select="./ike">
         <xsl:with-param name="id" select="$id" />
         <xsl:with-param name="gateway" select="$gateway" />
         <xsl:with-param name="cgwip" select="$cgwip" />
         <xsl:with-param name="cgwid" select="$cgwid" />
         <xsl:with-param name="ipsec_protocol" select="$ipsec_protocol" />
      </xsl:apply-templates>

      <xsl:apply-templates select="./ipsec">
         <xsl:with-param name="id" select="$id" />
         <xsl:with-param name="tunintf" select="$tunintf" />
      </xsl:apply-templates>
      <xsl:text>
# #3: Tunnel Interface Configuration
# The tunnel interface is configured with the internal IP address.
#
# To establish connectivity between your internal network and the VPC, you
# must have an interface facing your internal network in the "Trust" zone.
#
#
set interface </xsl:text><xsl:value-of select="$tunintf"/>
      <xsl:text> zone Trust
set interface </xsl:text><xsl:value-of select="$tunintf"/>
      <xsl:text> ip </xsl:text><xsl:value-of select="$cgwaddr"/>
      <xsl:text>
set vpn IPSEC-</xsl:text><xsl:value-of select="$id"/>
      <xsl:text> bind interface </xsl:text><xsl:value-of select="$tunintf"/>
      <xsl:text>
      
# By default, the router will block asymmetric VPN traffic, which may occur
# with this VPN Connection. This occurs, for example, when routing policies
# cause traffic to sent from your router to VPC through one IPSec tunnel
# while traffic returns from VPC through the other. 
# 
# This command allows this traffic to be received by your device.
set zone Trust asymmetric-vpn
</xsl:text>
      <xsl:apply-templates select="./ipsec/tcp_mss_adjustment"/>
<xsl:text>
# --------------------------------------------------------------------------------
</xsl:text>

      <xsl:text># #4: Border Gateway Protocol (BGP) Configuration
#                                                                                     
# BGP is used within the tunnel to exchange prefixes between the
# VPN Gateway and your Customer Gateway. The VPN Gateway    
# will announce the prefix corresponding to your VPC.
#            
# Your Customer Gateway must announce a default route (0.0.0.0/0).
# Only one prefix is accepted by the VPN Gateway.
#                                                                               
# The BGP timers are adjusted to provide more rapid detection of outages.       
# 
# The local BGP Autonomous System Number (ASN) (</xsl:text><xsl:value-of select="./customer_gateway/bgp/asn"/>
      <xsl:text>) is configured
# as part of your Customer Gateway. If the ASN must be changed, the 
# Customer Gateway and VPN Connection will need to be recreated with AWS.
#

set vrouter trust-vr
set max-ecmp-routes 2
set protocol bgp </xsl:text> <xsl:value-of select="./customer_gateway/bgp/asn"/>
      <xsl:text>
set hold-time 30
set network 0.0.0.0/0
set enable
set neighbor </xsl:text> <xsl:value-of select="$peer"/>
      <xsl:text> remote-as </xsl:text><xsl:value-of select="./vpn_gateway/bgp/asn"/>
      <xsl:text>
set neighbor </xsl:text> <xsl:value-of select="$peer"/>
      <xsl:text> enable 
exit
exit
set interface </xsl:text><xsl:value-of select="$tunintf"/>
      <xsl:text> protocol bgp

</xsl:text>
   </xsl:template> <!-- IPSec Tunnel -->

   <!-- IKE Settings -->
   <xsl:template match="ipsec_tunnel/ike">
      <xsl:param name="id" />
      <xsl:param name="gateway" />
      <xsl:param name="cgwip" />
      <xsl:param name="cgwid" />
      <xsl:param name="ipsec_protocol" />

      <xsl:variable name="ikeprop" select="concat('ike-prop-', $id)" />

      <xsl:text># #1: Internet Key Exchange (IKE) Configuration
#
# A proposal is established for the supported IKE encryption, 
# authentication, Diffie-Hellman, and lifetime parameters.
#

set ike p1-proposal </xsl:text><xsl:value-of select="$ikeprop"/>
      <xsl:text> preshare </xsl:text><xsl:value-of select="./perfect_forward_secrecy"/>
      <xsl:text> </xsl:text><xsl:value-of select="$ipsec_protocol"/>
      <xsl:text> </xsl:text>
      <xsl:choose>
          <xsl:when test="./encryption_protocol = 'aes-128-cbc'">
               <xsl:text>aes128</xsl:text>
          </xsl:when>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:choose>
          <xsl:when test="./authentication_protocol = 'sha1'">
               <xsl:text>sha-1</xsl:text>
          </xsl:when>
      </xsl:choose>
      <xsl:text> second </xsl:text><xsl:value-of select="./lifetime"/><xsl:text>
</xsl:text>

      <xsl:text>
# The IKE gateway is defined to be the VPN Gateway. The gateway 
# configuration associates a local interface, remote IP address, and
# IKE policy.
#
# This example shows the outside of the tunnel as interface ethernet0/0.
# This should be set to the interface that IP address </xsl:text>
      <xsl:value-of select="$cgwip" /><xsl:text> is
# associated with.
# This address is configured with the setup for your Customer Gateway.
#
# If the address changes, the Customer Gateway and VPN Connection must be recreated.
#
set ike gateway gw-</xsl:text>
      <xsl:value-of select="$id" /><xsl:text> address </xsl:text>
      <xsl:value-of select="$gateway"/>
      <xsl:text> id </xsl:text><xsl:value-of select="$gateway"/>
      <xsl:text> </xsl:text><xsl:value-of select="./mode"/>
      <xsl:text> outgoing-interface ethernet0/0 preshare "</xsl:text> 
      <xsl:value-of select="./pre_shared_key"/>

      <xsl:text>" proposal </xsl:text>
      <xsl:value-of select="$ikeprop"/><xsl:text>

# Troubleshooting IKE connectivity can be aided by enabling IKE debugging.
# To do so, run the following commands:
# clear dbuf         -- Clear debug buffer
# debug ike all      -- Enable IKE debugging
# get dbuf stream    -- View debug messages
# undebug all        -- Turn off debugging

</xsl:text>
   </xsl:template> <!-- IKE Settings -->

   <!-- IPSEC Settings -->
   <xsl:template match="ipsec_tunnel/ipsec">
      <xsl:param name="id" />
      <xsl:param name="tunintf" />

      <xsl:variable name="ipsecprop" select="concat('ipsec-prop-',$id)" />

      <xsl:text># #2: IPSec Configuration
#
# The IPSec (Phase 2) proposal defines the protocol, authentication, 
# encryption, and lifetime parameters for our IPSec security association.
#

set ike p2-proposal </xsl:text><xsl:value-of select="$ipsecprop"/>
      <xsl:text> </xsl:text><xsl:value-of select="./perfect_forward_secrecy"/>
      <xsl:text> </xsl:text><xsl:value-of select="./protocol" />
      <xsl:text> </xsl:text>
      <xsl:choose>
          <xsl:when test="./encryption_protocol = 'aes-128-cbc'">
               <xsl:text>aes128</xsl:text>
          </xsl:when>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:choose>
          <xsl:when test="./authentication_protocol = 'hmac-sha1-96'">
               <xsl:text>sha-1</xsl:text>
          </xsl:when>
      </xsl:choose>
      <xsl:text> second </xsl:text><xsl:value-of select="./lifetime"/><xsl:text>
set ike gateway gw-</xsl:text><xsl:value-of select="$id"/>
      <xsl:text> dpd-liveness interval </xsl:text><xsl:value-of select="./dead_peer_detection/interval"/>
      <xsl:text> 
set vpn IPSEC-</xsl:text><xsl:value-of select="$id"/>
      <xsl:text> gateway gw-</xsl:text><xsl:value-of select="$id"/>
      <xsl:text> replay </xsl:text><xsl:value-of select="./mode"/>
      <xsl:text> proposal </xsl:text><xsl:value-of select="$ipsecprop"/>
      <xsl:text>
</xsl:text>
   </xsl:template> <!-- IPSec -->

   <xsl:template match="ipsec/tcp_mss_adjustment">
      <xsl:text>
# This option causes the router to reduce the Maximum Segment Size of
# TCP packets to prevent packet fragmentation.
#
set flow vpn-tcp-mss </xsl:text><xsl:value-of select="."/><xsl:text>
</xsl:text>
   </xsl:template>

   <xsl:template match="ipsec/clear_df_bit">
      <xsl:param name="id" />
      <xsl:text>
set security ipsec vpn </xsl:text>
      <xsl:value-of select="$id" />
      <xsl:text> df-bit clear 
</xsl:text>
   </xsl:template>

   <xsl:template match="ipsec/dead_peer_detection">
      <xsl:param name="id" />
      <xsl:text>
# This option enables IPSec Dead Peer Detection, which causes periodic
# messages to be sent to ensure a Security Association remains operational.
#
set security ike gateway gw-</xsl:text>
      <xsl:value-of select="$id" /><xsl:text> dead-peer-detection
</xsl:text>
   </xsl:template>

</xsl:stylesheet>
