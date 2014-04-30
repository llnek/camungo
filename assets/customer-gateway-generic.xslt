<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
	<xsl:output method="text" />
    <xsl:variable name="xslversion" select="'2009-07-15-207071'"/>

	<!-- The basic function with header and footer info -->
	<xsl:template match="/">
		<xsl:text>Amazon Web Services
Virtual Private Cloud
</xsl:text>
		<xsl:apply-templates select="vpn_connection" />
		<xsl:text>
Additional Notes and Questions</xsl:text>
		<xsl:call-template name="put_line" />
		<xsl:text>
  - Amazon Virtual Private Cloud Getting Started Guide: 
      http://docs.amazonwebservices.com/AWSVPC/latest/GettingStartedGuide
  - Amazon Virtual Private Cloud Network Administrator Guide: 
      http://docs.amazonwebservices.com/AWSVPC/latest/NetworkAdminGuide
  - XSL Version: </xsl:text><xsl:value-of select="$xslversion"/><xsl:text>
</xsl:text>
	</xsl:template>

	<!-- PEERING -->
	<xsl:template match="vpn_connection">
		<xsl:text>
VPN Connection Configuration</xsl:text>
		<xsl:call-template name="put_line" />

		<xsl:text>AWS utilizes unique identifiers to manipulate the configuration of 
a VPN Connection. Each VPN Connection is assigned a VPN Connection Identifier 
and is associated with two other identifiers, namely the 
Customer Gateway Identifier and the VPN Gateway Identifier.

Your VPN Connection ID       : </xsl:text>
        <xsl:value-of select="@id"/><xsl:text>
Your VPN Gateway ID          : </xsl:text>
        <xsl:value-of select="vpn_gateway_id"/><xsl:text>
Your Customer Gateway ID     : </xsl:text>
        <xsl:value-of select="customer_gateway_id"/><xsl:text>
		
A VPN Connection consists of a pair of IPSec tunnel security associations (SAs). 
It is important that both tunnel security associations be configured. 
</xsl:text>
        
		<!-- Now call the IPSEC Tunnel template -->
		<xsl:apply-templates select="./ipsec_tunnel" />
		<xsl:text> <!-- Leave a blank line in the end -->
 
</xsl:text>
	</xsl:template> 	<!-- End of VPN Connection Template -->


	<!-- IPSEC Tunnel -->
	<xsl:template match="vpn_connection/ipsec_tunnel">
		<xsl:variable name="ptmp"
			select="concat('/',./vpn_gateway/tunnel_inside_address/network_cidr)" />
		<xsl:variable name="pgwaddr"
			select="concat(./vpn_gateway/tunnel_inside_address/ip_address,$ptmp)" />
		<xsl:variable name="ctmp"
			select="concat('/',./customer_gateway/tunnel_inside_address/network_cidr)" />
		<xsl:variable name="cgwaddr"
			select="concat(./customer_gateway/tunnel_inside_address/ip_address,$ctmp)" />
		<xsl:text>
		<!-- Leave some extra space between individual tunnel configs -->		
IPSec Tunnel #</xsl:text><xsl:value-of select="position()" />
		<xsl:call-template name="put_line" />
		<xsl:apply-templates select="./ike"/>
		<xsl:apply-templates select="./ipsec"/>
		
		<xsl:text>
#3: Tunnel Interface Configuration

Your Customer Gateway must be configured with a tunnel interface that is
associated with the IPSec tunnel. All traffic transmitted to the tunnel
interface is encrypted and transmitted to the VPN Gateway.

Additionally, the VPN Gateway and Customer Gateway establish the BGP
peering from your tunnel interface.  
</xsl:text>
		<xsl:call-template name="IPSEC_tunnel_header" />
		<xsl:text>
Outside IP Addresses:
  - Customer Gateway:        : </xsl:text>
		<xsl:value-of select="./customer_gateway/tunnel_outside_address/ip_address" />
		<xsl:text> 
  - VPN Gateway              : </xsl:text>
		<xsl:value-of select="./vpn_gateway/tunnel_outside_address/ip_address" />
		<xsl:text>
		
Inside IP Addresses
  - Customer Gateway         : </xsl:text>
		<xsl:value-of select="$cgwaddr" />
		<xsl:text>
  - VPN Gateway              : </xsl:text>
		<xsl:value-of select="$pgwaddr" />

		<xsl:call-template name="bgp_configuration" />
		
	</xsl:template>

	<!-- IKE Settings -->
	<xsl:template match="ipsec_tunnel/ike">
		<xsl:param name="tunid" />
		<xsl:text>#1: Internet Key Exchange Configuration
		
Configure the IKE SA as follows
  - Authentication Method    : Pre-Shared Key 
  - Pre-Shared Key           : </xsl:text>
		<xsl:value-of select="./pre_shared_key" />
		<xsl:call-template name='do-common-ike-ipsec'>
			<xsl:with-param name="modename"
				select="string('Phase 1 Negotiation Mode')" />
		</xsl:call-template>
		<xsl:text>
</xsl:text>
	</xsl:template>


	<!-- IPSEC Settings -->
	<xsl:template match="ipsec_tunnel/ipsec">
		<xsl:param name="tunid" />
		<xsl:text>
#2: IPSec Configuration

Configure the IPSec SA as follows:
  - Protocol                 : </xsl:text>
		<xsl:value-of select="./protocol" />
		<xsl:call-template name='do-common-ike-ipsec'>
			<xsl:with-param name="modename" select="string('Mode')" />
		</xsl:call-template>
		<xsl:apply-templates select="./dead_peer_detection" />
		<xsl:text>
</xsl:text>
		<xsl:call-template name="IPSec_Recommendations" />
	</xsl:template>
	<!-- End of IPSEC -->


	<!--Things common to ike and ipsec settings in one place-->
	<xsl:template name="do-common-ike-ipsec">
		<xsl:param name="modename" />
		<xsl:text>
  - Authentication Algorithm : </xsl:text>
		<xsl:value-of select="./authentication_protocol" />
		<xsl:text>
  - Encryption Algorithm     : </xsl:text>
		<xsl:value-of select="./encryption_protocol" />
		<xsl:text>
  - Lifetime                 : </xsl:text>
		<xsl:value-of select="./lifetime" />
		<xsl:text> seconds
  - </xsl:text>
		<xsl:value-of
			select="substring(concat($modename, '                           '), 1, 24)" />
		<xsl:text> : </xsl:text>
		<xsl:value-of select="./mode" />
		<xsl:text>
  - Perfect Forward Secrecy  : </xsl:text>
		<xsl:choose>
			<xsl:when test="./perfect_forward_secrecy = 'group2'">
				<xsl:text>Diffie-Hellman Group 2</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="./perfect_forward_secrecy" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="IPSec_Recommendations">
		<xsl:text>
IPSec ESP (Encapsulating Security Payload) inserts additional
headers to transmit packets. These headers require additional space, 
which reduces the amount of space available to transmit application data.
To limit the impact of this behavior, we recommend the following 
configuration on your Customer Gateway:
  - TCP MSS Adjustment       : </xsl:text>
		<xsl:value-of select="./tcp_mss_adjustment" />
		<xsl:text> bytes</xsl:text>
		<xsl:if test="./clear_df_bit">
			<xsl:text>
  - Clear Don't Fragment Bit : </xsl:text>
			<xsl:choose>
				<xsl:when test="./clear_df_bit/text() = 'true'">
					<xsl:text>enabled</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>disabled</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="./fragmentation_before_encryption/text() = 'true'">
			<xsl:text>
  - Fragmentation            : Before encryption
</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="IPSEC_tunnel_header">
		<xsl:text>
The Customer Gateway and VPN Gateway each have two addresses that relate
to this IPSec tunnel. Each contains an outside address, upon which encrypted
traffic is exchanged. Each also contain an inside address associated with
the tunnel interface.
 
The Customer Gateway outside IP address was provided when the Customer Gateway
was created. Changing the IP address requires the creation of a new
Customer Gateway.

The Customer Gateway inside IP address should be configured on your tunnel
interface. 
</xsl:text>
	</xsl:template>



	<xsl:template match="ipsec/dead_peer_detection">
		<xsl:text>
	
IPSec Dead Peer Detection (DPD) will be enabled on the AWS Endpoint. We
recommend configuring DPD on your endpoint as follows:
  - DPD Interval             : </xsl:text>
		<xsl:value-of select="./interval" />
		<xsl:text>
  - DPD Retries              : </xsl:text>
		<xsl:value-of select="./retries" />
	</xsl:template>

	<xsl:template name="bgp_configuration">
		<xsl:text>	

#4: Border Gateway Protocol (BGP) Configuration:

The Border Gateway Protocol (BGPv4) is used within the tunnel, between the inside
IP addresses, to exchange routes from the VPC to your home network. Each
BGP router has an Autonomous System Number (ASN). Your ASN was provided 
to AWS when the Customer Gateway was created.

BGP Configuration Options:
  - Customer Gateway ASN     : </xsl:text>
		<xsl:value-of select="./customer_gateway/bgp/asn" />
		<xsl:text> 
  - VPN Gateway ASN          : </xsl:text>
		<xsl:value-of select="./vpn_gateway/bgp/asn" />
		<xsl:text>
  - Neighbor IP Address      : </xsl:text>
		<xsl:value-of select="./vpn_gateway/tunnel_inside_address/ip_address" />
		<xsl:text>
  - Neighbor Hold Time       : </xsl:text>
		<xsl:value-of select="./vpn_gateway/bgp/hold_time" />
		<xsl:text>

Configure BGP to announce the default route (0.0.0.0/0) to the VPN Connection
Gateway. The VPN Gateway will announce prefixes to your Customer 
Gateway based upon the prefixes assigned in the creation of the VPC.
</xsl:text>
	</xsl:template>

	<!-- Miscellaneous formatting templates -->

	<xsl:template name="put_line">
		<xsl:text>
================================================================================
</xsl:text>
	</xsl:template>

</xsl:stylesheet>
