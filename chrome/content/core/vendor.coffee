###
# file: vendor.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }

var CK_AWSRGS='aws.regions',
C_AWS='amazonaws',
gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_prefs=new gcx.Prefs(),
g_ute=new gcc.Ute();


`

class CloudVendor #{
  constructor: (@id, pms) -> @bagOfProps= pms || {}
  setProp: (prop,value) -> @bagOfProps[prop]=value
  getProp: (prop) -> @bagOfProps[prop]

CloudVendor.normalize=(vendor,acctno) ->
  acctno=g_ute.trim(acctno)
  switch vendor
    when C_AWS then acctno=acctno.replace(/[^0-9]+/g,'')
    else acctno

CloudVendor.newProps=(vendor) ->
  switch vendor
    when C_AWS then new gcc.CloudVendor(C_AWS, {  'region' : 'us-east-1' } )
    else null
#}


# not used
class CloudAWS #{
  constructor: () -> @iniz()
  setRegions:(rgs) -> g_prefs.saveStr( CK_AWSRGS, JSON.stringify(rgs || {} ))
  getRegions:() -> JSON.parse( g_prefs.getStr(CK_AWSRGS))
  iniz: () ->
    s=g_prefs.getStr(CK_AWSRGS)
    if not g_ute.vstr(s)
      rgs=
        'us-east-1':'ec2.us-east-1.amazonaws.com'
        'us-west-2':'ec2.us-west-2.amazonaws.com'
        'us-west-1':'ec2.us-west-1.amazonaws.com'
        'eu-west-1':'ec2.eu-west-1.amazonaws.com'
        'ap-southeast-1':'ec2.ap-southeast-1.amazonaws.com'
        'ap-northeast-1':'ec2.ap-northeast-1.amazonaws.com'
        'sa-east-1':'ec2.sa-east-1.amazonaws.com'
      g_prefs.saveStr(CK_AWSRGS, JSON.stringify(rgs))
#}
  
`
gcc.CloudVendor=CloudVendor;
gcc.CloudAWS=CloudAWS;
gcc.CloudVendor.AWS=C_AWS;

})(window, window.document, jQuery);


`
