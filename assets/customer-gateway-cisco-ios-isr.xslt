<?xml version="1.0" ?>
<!-- Overall structure:
  /
  +- VPN Connection
     +- IPSec tunnel (x N)
        +- IKE
         +- IPSec
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="text"/>
	<xsl:variable name="xslversion" select="'2009-07-15-207071'"/>

	<xsl:template match="/">
		<xsl:text>! Amazon Web Services
! Virtual Private Cloud

! AWS utilizes unique identifiers to manipulate the configuration of 
! a VPN Connection. Each VPN Connection is assigned an identifier and is 
! associated with two other identifiers, namely the 
! Customer Gateway Identifier and VPN Gateway Identifier.
!
! Your VPN Connection ID   : </xsl:text>
        <xsl:value-of select="vpn_connection/@id"/><xsl:text>
! Your VPN Gateway ID      : </xsl:text>
        <xsl:value-of select="vpn_connection/vpn_gateway_id"/><xsl:text>
! Your Customer Gateway ID : </xsl:text>
        <xsl:value-of select="vpn_connection/customer_gateway_id"/><xsl:text>
!
!
! This configuration consists of two tunnels. Both tunnels must be 
! configured on your Customer Gateway.
!
</xsl:text>
		<xsl:apply-templates select="vpn_connection"/>
		<xsl:text>
! Additional Notes and Questions</xsl:text>
		<xsl:text>
!  - Amazon Virtual Private Cloud Getting Started Guide: 
!       http://docs.amazonwebservices.com/AWSVPC/latest/GettingStartedGuide
!  - Amazon Virtual Private Cloud Network Administrator Guide: 
!       http://docs.amazonwebservices.com/AWSVPC/latest/NetworkAdminGuide
!  - XSL Version: </xsl:text>
		<xsl:value-of select="$xslversion"/>
		<xsl:text>
</xsl:text>
	</xsl:template>

	<!-- VPN Connection -->
	<xsl:template match="vpn_connection">
		<xsl:apply-templates select="ipsec_tunnel">
			<xsl:with-param name="cgwid" select="./customer_gateway"/>
			<xsl:with-param name="vgwid" select="./vpn_gateway_id"/>
		</xsl:apply-templates>
		<xsl:text>
! To establish connectivity between your internal network and your VPC, you
! must have an interface facing your internal network in the "YOUR_VRF" VRF.
! This is done using configuration like that shown below.
!interface FastEthernet1
!  ip vrf forwarding YOUR_VRF
!exit

</xsl:text>
	</xsl:template>

	<!-- IPSEC Tunnels -->
	<xsl:template match="vpn_connection/ipsec_tunnel">
		<xsl:param name="cgwid"/>
		<xsl:param name="vgwid"/>
		<xsl:variable name="id" select="concat(./../@id, '-', string(position()-1))"/>
		<xsl:variable name="peer" select="./vpn_gateway/tunnel_inside_address/ip_address"/>
		<xsl:variable name="gateway" select="./vpn_gateway/tunnel_outside_address/ip_address"/>
		<xsl:variable name="cgwip" select="./customer_gateway/tunnel_outside_address/ip_address"/>
		<xsl:variable name="tunnel" select="concat('Tunnel',string(position()))"/>

		<xsl:text>! --------------------------------------------------------------------------------
! IPSec Tunnel #</xsl:text><xsl:value-of select="position()"/><xsl:text>
! --------------------------------------------------------------------------------
</xsl:text>
		
		<xsl:apply-templates select="./ike">
			<xsl:with-param name="id" select="$id"/>
			<xsl:with-param name="gateway" select="$gateway"/>
			<xsl:with-param name="position" select="string(position()-1)"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="./ipsec">
			<xsl:with-param name="id" select="$id"/>
		</xsl:apply-templates>
		<xsl:text>
! #3: Tunnel Interface Configuration
!  
! This configuration assumes the presence of an internal 
! Virtual Routing and Forwarding (VRF) instance. For more details, see the 
! associated diagram. Here, we assume the internal VRF is named "YOUR_VRF".
!
ip vrf YOUR_VRF
  rd 1:1
exit

! A tunnel interface is configured to be the logical interface associated  
! with the tunnel. All traffic routed to the tunnel interface will be 
! encrypted and transmitted to the VPC. Similarly, traffic from the VPC
! will be logically received on this interface.
!
! The interface is a member of the internal routing instance (YOUR_VRF).
! Association with the IPSec security association is done through the 
! "tunnel protection" command.
!
! This example shows the outside of the tunnel as interface FastEthernet0. 
!
! This should be set to the interface that IP address </xsl:text>
		<xsl:value-of select="$cgwip"/>
		<xsl:text> is 
! associated with.
!
! This address is configured with the setup for your Customer Gateway.
!
! If the address changes, the Customer Gateway and VPN Connection must be 
! recreated with AWS.
!
interface </xsl:text>
		<xsl:value-of select="$tunnel"/>

		<xsl:text>
  ip vrf forwarding YOUR_VRF
  ip address </xsl:text>
		<xsl:value-of select="./customer_gateway/tunnel_inside_address/ip_address"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="./customer_gateway/tunnel_inside_address/network_mask"/>
		<xsl:text>
  ip virtual-reassembly
  tunnel source FastEthernet0
  tunnel destination </xsl:text>
		<xsl:value-of select="$gateway"/>
		<xsl:text> 
  tunnel mode ipsec ipv4
  tunnel protection ipsec profile ipsec-</xsl:text>
		<xsl:value-of select="$id"/>
		<xsl:text>
</xsl:text>
		<xsl:apply-templates select="./ipsec/tcp_mss_adjustment"/>
		<xsl:text> 
  no shutdown
exit

! --------------------------------------------------------------------------------
</xsl:text>

		<xsl:text>! #4: Border Gateway Protocol (BGP) Configuration
!                                                                                     
! BGP is used within the tunnel to exchange prefixes between the
! VPN Gateway and your Customer Gateway. The VPN Gateway    
! will announce the prefix corresponding to your VPC.
!            
! Your Customer Gateway must announce a default route (0.0.0.0/0), 
! which can be done with the 'network' and 'default-originate' statements.
! Only one prefix is accepted by the VPN Gateway.
!
! The BGP timers are adjusted to provide more rapid detection of outages.
!
! The local BGP Autonomous System Number (ASN) (</xsl:text><xsl:value-of select="./customer_gateway/bgp/asn"/>
      <xsl:text>) is configured
! as part of your Customer Gateway. If the ASN must be changed, the 
! Customer Gateway and VPN Connection will need to be recreated with AWS.
!
router bgp </xsl:text>
		<xsl:value-of select="./customer_gateway/bgp/asn"/>
		<xsl:text>
  neighbor </xsl:text>
		<xsl:value-of select="$peer"/>
		<xsl:text> remote-as </xsl:text>
		<xsl:value-of select="./vpn_gateway/bgp/asn"/>
		<xsl:text>
  neighbor </xsl:text>
		<xsl:value-of select="$peer"/>
		<xsl:text> activate
  neighbor </xsl:text>
		<xsl:value-of select="$peer"/>
		<xsl:text> timers 10 30 30
  address-family ipv4 unicast vrf YOUR_VRF
    neighbor </xsl:text>
		<xsl:value-of select="$peer"/>
		<xsl:text> remote-as </xsl:text>
		<xsl:value-of select="./vpn_gateway/bgp/asn"/>
		<xsl:text>
    neighbor </xsl:text>
		<xsl:value-of select="$peer"/>
		<xsl:text> timers 10 30 30
    neighbor </xsl:text>
		<xsl:value-of select="$peer"/>
		<xsl:text> default-originate
    neighbor </xsl:text>
		<xsl:value-of select="$peer"/>
		<xsl:text> activate
    neighbor </xsl:text>
		<xsl:value-of select="$peer"/>
		<xsl:text> soft-reconfiguration inbound
    network 0.0.0.0
  exit
exit
!
</xsl:text>

	</xsl:template>
	<!-- End of IPSec tunnel -->

	<!-- IKE Settings -->
	<xsl:template match="ipsec_tunnel/ike">
		<xsl:param name="id"/>
		<xsl:param name="position"/>
		<xsl:param name="gateway"/>

		<xsl:text>! #1: Internet Key Exchange (IKE) Configuration
!
! A policy is established for the supported ISAKMP encryption, 
! authentication, Diffie-Hellman, lifetime, and key parameters.
!
! Note that there are a global list of ISAKMP policies, each identified by 
! sequence number. This policy is defined as #20</xsl:text>
		<xsl:value-of select="$position"/>
		<xsl:text>, which may conflict with
! an existing policy using the same number. If so, we recommend changing 
! the sequence number to avoid conflicts.
!
</xsl:text>
		<xsl:text>crypto isakmp policy 20</xsl:text>
		<xsl:value-of select="$position"/>
		<xsl:text>
  encryption </xsl:text>
        <xsl:choose>
          <xsl:when test="./encryption_protocol = 'aes-128-cbc'">
             <xsl:text>aes 128</xsl:text>
          </xsl:when>
        </xsl:choose>
		<xsl:text>
  authentication pre-share
  group </xsl:text>
		<xsl:value-of select="substring-after(./perfect_forward_secrecy,'group')"/>
		<xsl:text>
  lifetime </xsl:text>
		<xsl:value-of select="./lifetime"/>
		<xsl:text>
  hash </xsl:text>
        <xsl:choose>
          <xsl:when test="./authentication_protocol = 'sha1'">
             <xsl:text>sha</xsl:text>
          </xsl:when>
        </xsl:choose>
		<xsl:text>
exit

! The ISAKMP keyring stores the Pre Shared Key used to authenticate the 
! tunnel endpoints.
!
crypto keyring keyring-</xsl:text>
		<xsl:value-of select="$id"/>
		<xsl:text>
  pre-shared-key address </xsl:text>
		<xsl:value-of select="$gateway"/>
		<xsl:text> key </xsl:text>
		<xsl:value-of select="./pre_shared_key"/>
		<xsl:text>
exit

! An ISAKMP profile is used to associate the keyring with the particular 
! endpoint.
!
crypto isakmp profile isakmp-</xsl:text>
		<xsl:value-of select="$id"/>
		<xsl:text>
  match identity address </xsl:text>
		<xsl:value-of select="$gateway"/>
		<xsl:text>
  keyring keyring-</xsl:text>
		<xsl:value-of select="$id"/>
		<xsl:text>
exit
</xsl:text>
	</xsl:template>
	<!-- End of IKE Settings -->

	<!-- IPSEC Settings -->
	<xsl:template match="ipsec_tunnel/ipsec">
		<xsl:param name="id"/>
		<xsl:text>
! #2: IPSec Configuration
! 
! The IPSec transform set defines the encryption, authentication, and IPSec
! mode parameters.
!
crypto ipsec transform-set ipsec-prop-</xsl:text>
		<xsl:value-of select="$id"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="./protocol"/>
		<xsl:text>-</xsl:text>
        <xsl:choose>
          <xsl:when test="./encryption_protocol = 'aes-128-cbc'">
             <xsl:text>aes 128 </xsl:text>
          </xsl:when>
        </xsl:choose>
		<xsl:value-of select="./protocol"/>
		<xsl:text>-</xsl:text>
        <xsl:choose>
          <xsl:when test="./authentication_protocol = 'hmac-sha1-96'">
             <xsl:text>sha-hmac</xsl:text>
          </xsl:when>
        </xsl:choose>
		<xsl:text> 
  mode </xsl:text>
		<xsl:value-of select="./mode"/>
		<xsl:text>
exit

! The IPSec profile references the IPSec transform set and further defines
! the Diffie-Hellman group and security association lifetime.
!
crypto ipsec profile ipsec-</xsl:text>
		<xsl:value-of select="$id"/>
		<xsl:text>
  set pfs </xsl:text>
		<xsl:value-of select="./perfect_forward_secrecy"/>
		<xsl:text>
  set security-association lifetime seconds </xsl:text>
		<xsl:value-of select="./lifetime"/>
		<xsl:text>
  set transform-set ipsec-prop-</xsl:text>
		<xsl:value-of select="$id"/>
		<xsl:text>
exit

! Additional parameters of the IPSec configuration are set here. Note that 
! these parameters are global and therefore impact other IPSec 
! associations.
</xsl:text>
		<xsl:apply-templates select="clear_df_bit"/>
		<xsl:apply-templates select="dead_peer_detection"/>
		<xsl:text>! This configures the gateway's window for accepting out of order
! IPSec packets. A larger window can be helpful if too many packets 
! are dropped due to reordering while in transit between gateways.
!
crypto ipsec security-association replay window-size 128

! This option instructs the router to fragment the unencrypted packets
! (prior to encryption).
!
crypto ipsec fragmentation before-encryption
  
</xsl:text>
	</xsl:template>
	<!-- End of IPSec Settings -->

	<!-- Clear DF Bit -->
	<xsl:template match="ipsec/clear_df_bit">
		<xsl:text>! This option instructs the router to clear the "Don't Fragment" 
! bit from packets that carry this bit and yet must be fragmented, enabling
! them to be fragmented.
!
crypto ipsec df-bit clear

</xsl:text>
	</xsl:template>
	<!-- End of Clear DF Bit -->

	<!-- Dead Peer Detection -->
	<xsl:template match="ipsec/dead_peer_detection">
		<xsl:text>! This option enables IPSec Dead Peer Detection, which causes periodic
! messages to be sent to ensure a Security Association remains operational.
!
crypto isakmp keepalive 10 10 on-demand

</xsl:text>
	</xsl:template>
	<!-- End of Dead Peer Detection -->

	<!-- TCP Adjust MSS -->
	<xsl:template match="ipsec/tcp_mss_adjustment">
		<xsl:text>  ! This option causes the router to reduce the Maximum Segment Size of
  ! TCP packets to prevent packet fragmentation.
  ip tcp adjust-mss </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>
	<!-- End of TCP Adjust MSS -->

</xsl:stylesheet>
