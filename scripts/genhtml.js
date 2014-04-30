var UTIL=require('util'),
FS=require('fs'),
MU=require('./mustache.js'),
TPL=FS.readFileSync(process.argv[2],'utf-8'),
OUTDIR=process.argv[3],
CSF=function(pfx,fn) {
return '<link rel="stylesheet" type="text/css" href="chrome://camungo/skin/'+pfx+'/'+fn+'"/>';
},
JSF=function(pfx,fn) {
return '<script type="text/javascript" src="chrome://camungo/'+pfx+'/'+fn+'"></script>';
};


function MK_Input() {
  this.tpclcss= { 'css': '' };
  this.viewcss= { 'css': '' };
  this.pivotitems= [];
  this.modalpop= {};
  this.busywait= {};
  this.ctxmenu= { 'title': 'FieldValues' };
  this.tpcljs= {'js':''};
  this.corejs= {'js':''};
  this.viewjs= {'js':''};
  this.bootcode= {'code':''};
  this.tpclcss.css=[
    CSF('bootstrap/css','bootstrap-mod.css'),
    CSF('bootstrap/css','bootstrap-responsive.min.css'),
    CSF('jqmetro','jquery.metro.css'),
    CSF('dtable/css','dtable.ext.css')
  ].join('\n');
  this.tpcljs.js= [
    JSF('content/tpcl','underscore-min.js'),
    JSF('content/tpcl','mustache.js'),
    JSF('content/tpcl','jquery.min.js'),
    JSF('content/tpcl','jquery.glob.min.js'),
    JSF('locale','jquery.glob.en-US.js'),
    JSF('skin/bootstrap/js','bootstrap.min.js'),
    JSF('skin/dtable','jquery.dataTables.min.js'),
    JSF('skin/dtable','dtable.js'),
    JSF('skin/jqmetro','jquery.metro.mod.js'),
    JSF('content/tpcl','crypto-min.js'),
    JSF('content/tpcl','crypto-sha256-hmac.js'),
    JSF('content/tpcl','crypto-sha1-hmac-pbkdf2-blockmodes-aes.js'),
    JSF('content/tpcl','cloudapi-browser-min.js'),
    JSF('content/tpcl','io.js')
  ].join('\n');
  this.corejs.js= JSF('content/js','camungo-core.min.js');
}

var FUNCS={
'databases-view':function(input) {
  input.pivotitems=[]
  input.pivotitems.push({ 'itemid': 'rdbms', 'ctnid':'rdbms-tpl' });
  input.pivotitems.push({ 'itemid': 'nosql', 'ctnid':'nosql-tpl' });
  input.viewjs.js=[
    JSF('content/js','databases.min.js')
  ].join('\n');
  input.bootcode.code='new ComZotoh.Camungo.DatabasesView().render();';
  return input;
},

'machines-view':function(input) {
  input.tpclcss.css=[ input.tpclcss.css, 
      CSF('smartwiz/styles','smart_wizard.css')].join('\n');
  input.tpcljs.js=[ input.tpcljs.js, 
      JSF('skin/smartwiz/js','jquery.smartWizard-2.0.min.js')].join('\n');
  input.pivotitems=[]
  input.pivotitems.push({ itemid: 'vms', ctnid:'vms-tpl' });
  input.pivotitems.push({ itemid: 'images', ctnid:'images-tpl' });
  input.pivotitems.push({ itemid: 'scaling', ctnid:'scaling-tpl' });
  input.pivotitems.push({ itemid: 'lcfg', ctnid:'lcfg-tpl' });
  input.pivotitems.push({ itemid: 'lbs', ctnid:'lbs-tpl' });
  input.viewjs.js=[
    JSF('content/js','machines.min.js')
  ].join('\n');
  input.bootcode.code='new ComZotoh.Camungo.MachinesView().render();';
  return input;
},

'messaging-view':function(input) {
  input.pivotitems=[]
  input.pivotitems.push({ itemid: 'metrics', ctnid:'metrics-tpl' });
  input.pivotitems.push({ itemid: 'queues', ctnid:'queues-tpl' });
  input.pivotitems.push({ itemid: 'notify', ctnid:'notify-tpl' });
  input.viewjs.js=[
    JSF('content/js','messaging.min.js')
  ].join('\n');
  input.bootcode.code='new ComZotoh.Camungo.MessagingView().render();';
  return input;
},

'networks-view':function(input) {
  input.pivotitems=[]
  input.pivotitems.push({ itemid: 'fwalls', ctnid:'fwalls-tpl' });
  input.pivotitems.push({ itemid: 'keys', ctnid:'sshkeys-tpl' });
  input.pivotitems.push({ itemid: 'ipaddrs', ctnid:'ipaddrs-tpl' });
  input.viewjs.js=[
    JSF('content/js','networks.min.js')
  ].join('\n');
  input.bootcode.code='new ComZotoh.Camungo.NetworksView().render();';
  return input;
},

'settings-view':function(input) {
  input.pivotitems=[]
  input.pivotitems.push({ itemid: 'accts', ctnid:'accts-tpl' });
  input.pivotitems.push({ itemid: 'sshcfg', ctnid:'sshcfg-tpl' });
  input.pivotitems.push({ itemid: 'prefs', ctnid:'prefs-tpl' });
  input.pivotitems.push({ itemid: 'jsrun', ctnid:'jsrun-tpl' });
  input.viewjs.js=[
    JSF('content/js','settings.min.js')
  ].join('\n');
  input.bootcode.code='new ComZotoh.Camungo.SettingsView().render();';
  return input;
},

'storage-view': function(input) {
  input.pivotitems=[]
  input.pivotitems.push({ itemid: 'vols', ctnid:'vols-tpl' });
  input.pivotitems.push({ itemid: 'snaps', ctnid:'snaps-tpl' });
  input.pivotitems.push({ itemid: 'cfiles', ctnid:'cfiles-tpl' });
  input.viewjs.js=[
    JSF('content/js','storage.min.js')
  ].join('\n');
  input.bootcode.code='new ComZotoh.Camungo.StorageView().render();';
  return input;
},

'vpcs-view' : function(input) {
  input.pivotitems=[]
  input.pivotitems.push({ itemid: 'vlans', ctnid:'vlans-tpl' });
  input.pivotitems.push({ itemid: 'subnets', ctnid:'subnets-tpl' });
  input.pivotitems.push({ itemid: 'dhcps', ctnid:'dhcps-tpl' });
  input.pivotitems.push({ itemid: 'gates', ctnid:'gates-tpl' });
  input.pivotitems.push({ itemid: 'conns', ctnid:'conns-tpl' });
  input.viewjs.js=[
    JSF('content/js','vpcs.min.js')
  ].join('\n');
  input.bootcode.code='new ComZotoh.Camungo.VPCsView().render();';
  return input;
}

};




['databases-view','machines-view','storage-view','vpcs-view',
'messaging-view','networks-view', 'settings-view' ].forEach(function(name){

  var fp,a = FUNCS[name]( new MK_Input() );
  a=MU.render(TPL,a);
  try {
    fp=OUTDIR+"/"+name+".html";
    FS.writeFileSync(fp, a,'utf-8');
    console.log("genHtml: created file "+ fp + ". OK.");
  } catch (e) {
    console.log(e);
  }

});




