###
# file: rdbms.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gc=genv.ComZotoh,
gcc=gc.Camungo,
C_DBCZS=['db.m1.small', 'db.m1.large', 'db.m1.xlarge','db.m2.xlarge', 'db.m2.2xlarge', 'db.m2.4xlarge' ].sort(),
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class AddRDBFm extends gcc.HtmlForm #{
  constructor: () -> 
    super()
    @dbes={}
  sortDBES:(r)->
    id=r.getProviderEngineId()
    v=r.getVersion()
    if not _.has(@dbes,id) then @dbes[id]={}
    @dbes[id][v]=''
  loadDBES:(ctx)->
    me=this
    a=_.keys(@dbes).sort()
    h=_.map( a, (v)-> me.htmOneDDListOpt(v)).join('')
    e3=$('#fld3',ctx)
    e3.empty().html(g_ute.trim(h))
    a=_.keys(@dbes[a[0]]).sort()
    h=_.map( a, (v)-> me.htmOneDDListOpt(v)).join('')
    e4=$('#fld4',ctx)
    e4.empty().html(g_ute.trim(h))
    fc=()->
      a=_.keys(me.dbes[ e3.val() ] ).sort()
      h=_.map( a, (v)-> me.htmOneDDListOpt(v)).join('')
      e4.empty().html(g_ute.trim(h))
    e3.on('change',fc)
  postShow:(dlg)->
    svc= gcc.HtmlPage.cloud.getPlatformServices().getRelationalDatabaseSupport()
    me=this
    nok=()->
      me.clrDDList('fld4')
      me.clrDDList('fld3')
      me.dispErrorDDList('fld4')
      me.dispErrorDDList('fld3')
    ok=(rc)->
      _.each(rc, (v)-> me.sortDBES(v))
      me.loadDBES(dlg)
    svc.getDatabaseEngines(gcc.PivotItem.CBS(ok,nok))
    super(dlg)
  doSave:(ctx,ok,nok) ->
    nm=g_ute.trim($('#fld1',ctx).val())
    sz=g_ute.trim($('#fld2',ctx).val())
    db=g_ute.trim($('#fld3',ctx).val())
    v=g_ute.trim($('#fld4',ctx).val())
    pz=g_ute.trim($('#fld5',ctx).val())
    z=g_ute.trim($('#fld6',ctx).val())
    uid=g_ute.trim($('#fld7',ctx).val())
    pwd=g_ute.trim($('#fld8',ctx).val())
    svc= gcc.HtmlPage.cloud.getPlatformServices().getRelationalDatabaseSupport()
    p=new gc.CloudAPI.Platform.DatabaseProduct()
    p.setStorageInGigabytes(sz)
    p.setEngineVersion(v)
    p.setEngine(db)
    p.setProductSize(pz)
    if z is '-1'
      p.setHighAvailability(true)
    else
      p.setProviderDataCenterId(z)
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.createFromScratch(nm,p,uid,pwd,null,null,cbs)
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld2' and isNaN(value) then @flagError(ctx,flags,id)
    if id is 'fld4' and value is '-1' then @flagError(ctx,flags,id)
    if id is 'fld3' and value is '-1' then @flagError(ctx,flags,id)

#}
class AddRDBDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.db') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddRDBFm()
    @callerCB=cb
    me=this
    args={flds:{}}
    a=[]
    args.flds.fld1= { reqd:1,focus:1,lbl: @l10n('%name') }
    args.flds.fld2= { reqd:1,lbl: @l10n('%db.size'),kind:'number',value:'10' }
    a=[{disp:@l10n('%load.wait'), value:'-1'}]
    args.flds.fld3= { lbl: @l10n('%db.engine.dc'),kind:'list',choices:a}
    args.flds.fld4= { kind:'list',choices:a}
    a=_.map(C_DBCZS,(v)->{disp:v,value:v})
    args.flds.fld5= { kind:'list',choices:a}
    a=[{disp: @l10n('%high.avail'), value: '-1' }]
    a=a.concat( @arrDcChoices())
    args.flds.fld6= { kind:'list',choices:a}
    args.flds.fld7= { reqd:1,lbl: @l10n('%db.admin'),width:'dlg-s8s',value:'sa'}
    args.flds.fld8= { reqd:1,width:'dlg-s8s',lbl: @l10n('%pwd'),kind:'password',hint: @l10n('%enter.pwd')}
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelRDBFm extends gcc.HtmlForm #{
  constructor: (@db) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getPlatformServices().getRelationalDatabaseSupport()
    c=$('#fld2',ctx).is(':checked')
    snap= if c then g_ute.trim($('#fld3',ctx).val()) else ''
    svc.removeDatabase(@db.getProviderDatabaseId(),snap, gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    e2=$('#fld2',dlg)
    fc=()->
      b=e2.is(':checked')
      em=$('#fld3',dlg)
      if b
        em.attr('disabled',false)
        em.removeClass('disabled')
      else
        em.attr('disabled',true)
        em.val('')
        em.addClass('disabled')
    e2.on('change',fc)
    super(dlg)
#}
class DelRDBDlg extends gcc.ModalDlg #{
  constructor: (@db) -> super({ title: gcc.L10N('%del.db') })
  onOK: (ctx,rc) -> @callerCB?(@db)
  show: (cb) ->
    f=new DelRDBFm(@db)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%db.id'),value: @db.getProviderDatabaseId(), off:1, width:'dlg-s8s' }
    args.flds.fld2= { kind:'cbox',lbl: @l10n('%req.finz.dbsnap') }
    args.flds.fld3= { lbl: @l10n('%snap.id'),width:'dlg-s8s' }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddRDBDlg=AddRDBDlg;
gcc.DelRDBDlg=DelRDBDlg;

})(window, window.document, jQuery);


`
