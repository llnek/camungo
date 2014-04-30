###
# file: images.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gc=genv.ComZotoh,
gcc=gc.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class DumbFm extends gcc.HtmlForm #{
  constructor:()-> super('form-horizontal')
  renderFormFooter:()->
#}
class BootImageFm extends gcc.HtmlForm #{
  constructor: (@dlg, @img) -> super()
  preShow: (ctx) ->
    me=this
    nok=(err)-> me.dlg.onNOK(ctx, err)
    ok=(rc)-> me.dlg.onSaveOK(ctx, rc)
    fin=()-> me.doSave(ctx,ok,nok)
    ls=(obj)-> me.doCheckStep(ctx,obj)
    $('#boot-wiz',ctx).smartWizard({transitionEffect:'fade',labelNext:'&raquo;', labelPrevious:'&laquo;', labelFinish:@l10n('%launch'),onFinish: fin, onLeaveStep: ls })
    super()
  doSave:(ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    pms={}
    pd= $('#fld11',ctx).val()
    pd=gc.CloudAPI.Compute.VirtualMachineProduct.entrySet()[ pd]
    mc= $('#fld12',ctx).val()
    pms.MaxCount=mc
    sg=[]
    $('#fld21 option',ctx).filter(':selected').each( () -> sg.push($(this).text()) )
    kp= $('#fld22',ctx).val()
    dc=$('#fld31',ctx).val()
    sn=''
    if dc is '-1' then dc=null
    if $('#fld32',ctx).is(':checked')
      sn=$('#fld33',ctx).val()
    if sn is '-1' then sn=''
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.launch(@img.getProviderMachineImageId(), pd, dc, kp, sn, false, [sg], pms, cbs)
  doCheckStep:(ctx,obj)->
    rc=false
    switch obj.attr('rel')
      when '1' then rc=@doCheckStep1()
      when '2' then rc=@doCheckStep2()
      when '3' then rc=@doCheckStep3()
      when '4' then rc=@doCheckStep4()
    rc
  doCheckStep1:()-> true
  doCheckStep2:()-> true
  doCheckStep3:()-> true
  doCheckStep4:()-> true
  postShow: (ctx) ->
    super()
    @cfgStep2(ctx)
    @cfgStep3(ctx)
  syncDOM:(id,ctx,htm)-> $('#'+id,ctx).empty().html( g_ute.trim(htm))
  postGetSubnets: (flag,ctx,rc) ->
    em=$('#fld32',ctx)
    id='fld33'
    me=this
    @clrDDList(id,ctx)
    if not flag
      @dispErrorDDList(id,ctx)
    else if rc.length is 0
        em.attr('checked',false)
        em.attr('disabled',true)
    else
      s=_.map(rc, (v)-> me.htmOneDDListOpt( v.getProviderSubnetId())).join('')
      s= [ @htmOneDDListOpt('-1', @l10n('%load.none')) , s ].join('')
      @syncDOM(id,ctx,s)
  cfgStep3:(ctx)->
    bw=g_xul.getBrowser()
    c=bw.getUserData('cloud.acct')
    dcs=bw.getUserData('cloud.'+c.vendor+'.dcs') || {}
    id='fld31'
    me=this
    s=_.map(_.keys(dcs).sort(), (z)-> me.htmOneDDListOpt(z) ).join('')
    s= [ @htmOneDDListOpt('-1', @l10n('%load.none')) , s ].join('')
    @clrDDList(id,ctx)
    @syncDOM(id,ctx,s)
    fc=()->
      b= $('#fld32',ctx).is(':checked')
      if not b then $('#fld33',ctx).val('-1')
      $('#fld33',ctx).attr('disabled', (not b))
    $('#fld32',ctx).on('change',fc)
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    nok=(err)-> me.postGetSubnets(false,ctx,err)
    ok=(rc)-> me.postGetSubnets(true,ctx,rc)
    svc.listSubnets('', gcc.PivotItem.CBS(ok,nok))
  postGetFwalls:(flag,ctx,rc)->
    id='fld21'
    me=this
    @clrDDList(id,ctx)
    if not flag
      @dispErrorDDList(id,ctx)
    else
      s=_.map(rc, (v)-> me.htmOneDDListOpt(v.getProviderFirewallId(),v.getName())).join('')
      @syncDOM(id,ctx,s)
  postGetKeys:(flag,ctx,rc)->
    id='fld22'
    me=this
    @clrDDList(id,ctx)
    if not flag
      @dispErrorDDList(id,ctx)
    else
      s=_.map(rc, (v)-> me.htmOneDDListOpt(v.keyName)).join('')
      @syncDOM(id,ctx,s)
  cfgStep2:(ctx)->
    svc=gcc.HtmlPage.cloud.getIdentityServices().getShellKeySupport()
    me=this
    nok=(err)-> me.postGetKeys(false,ctx,err)
    ok=(rc)-> me.postGetKeys(true,ctx,rc)
    svc.list(gcc.PivotItem.CBS(ok,nok))
    svc=gcc.HtmlPage.cloud.getNetworkServices().getFirewallSupport()
    nok=(err)-> me.postGetFwalls(false,ctx,err)
    ok=(rc)-> me.postGetFwalls(true,ctx,rc)
    svc.list(gcc.PivotItem.CBS(ok,nok))
  render:()->
    v0= {s1:@l10n('%general'), s2:@l10n('%security'),s3:@l10n('%network'),s4:@l10n('%advanced')}
    v1={ws1hdr:@l10n('%bi.wiz.s1.hdr'), ws2hdr:@l10n('%bi.wiz.s2.hdr'), ws3hdr:@l10n('%bi.wiz.s3.hdr'),ws4hdr:@l10n('%bi.wiz.s4.hdr')}
    _.extend(v0,v1)
    v0.ws1html= @renderStep1()
    v0.ws2html= @renderStep2()
    v0.ws3html= @renderStep3()
    v0.ws4html= @renderStep4()
    htm=Mustache.render(@wizTpl, v0)
    g_ute.trim(htm)
  renderStep1:()->
    f=new DumbFm()
    args={ flds: {} }
    a=@img.getArchitecture()
    a=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport().listProducts(a)
    a=_.map(a,(v)-> { disp: v.getProductId(), value: v.getProductId() } )
    args.flds.fld11={kind:'list',lbl:@l10n('%bi.wiz.pick.type'),choices:a }
    args.flds.fld12={kind:'number',lbl:@l10n('%bi.wiz.pick.icnt'), value: '1' }
    args.flds.fld13={lbl:@l10n('%bi.wiz.pick.imageid'), off:1, value: @img.getProviderMachineImageId() }
    f.iniz(args)
    f.render()
  renderStep2:()->
    f=new DumbFm()
    args={ flds: {} }
    a=[{ disp: @l10n('%load.wait'), value: '-1' }]
    args.flds.fld21= { lbl:@l10n('%bi.wiz.pick.fwall'), kind:'list', multi:1, choices: a }
    args.flds.fld22= { lbl:@l10n('%bi.wiz.pick.key'), kind:'list', choices: a }
    f.iniz(args)
    f.render()
  renderStep3:()->
    f=new DumbFm()
    args={ flds: {} }
    a=[{ disp: @l10n('%load.wait'), value: '-1' }]
    args.flds.fld31= { lbl:@l10n('%bi.wiz.pick.dc'), kind:'list', choices: a }
    args.flds.fld32= { lbl:@l10n('%bi.wiz.pick.vpc'), kind:'cbox',inline:false }
    args.flds.fld33= { lbl:@l10n('%bi.wiz.pick.subnets'), kind:'list', choices: a, off:1 }
    f.iniz(args)
    f.render()
  renderStep4:()->
    f=new DumbFm()
    args={ flds: {} }
    args.flds.fld41= { lbl:@l10n('%bi.wiz.pick.data'), kind:'tbox', rows: 9, cols: 32 }
    f.iniz(args)
    f.render()

  wizTpl: """
<div id="boot-wiz" class="swMain">
  <ul>
    <li><a href="#ws1"> <span class="stepDesc">{{s1}}</span> </a></li>
    <li><a href="#ws2"> <span class="stepDesc">{{s2}}</span> </a></li>
    <li><a href="#ws3"> <span class="stepDesc">{{s3}}</span> </a></li>
    <li><a href="#ws4"> <span class="stepDesc">{{s4}}</span> </a></li>
  </ul>
  <div id="ws1"> <h2 class="StepTitle">{{{ws1hdr}}}</h2></br></br>
    {{{ws1html}}}
  </div>
  <div id="ws2"><h2 class="StepTitle">{{{ws2hdr}}}</h2></br></br>
    {{{ws2html}}}
  </div>
  <div id="ws3"> <h2 class="StepTitle">{{{ws3hdr}}}</h2></br></br>
    {{{ws3html}}}
  </div>
  <div id="ws4"> <h2 class="StepTitle">{{{ws4hdr}}}</h2></br></br>
    {{{ws4html}}}
  </div>

</div>

  """
#}
class BootImageDlg extends gcc.ModalDlg #{
  constructor: (@img) -> super({ title: gcc.L10N('%launch.vm') })
  onOK: (ctx,rc) -> @callerCB?()
  renderFormFooter:(ctx,form)->
  show: (cb) ->
    f=new BootImageFm(this, @img)
    @callerCB=cb
    f.iniz({} )
    @inizAsForm(f)
#}

class ShareImageFm extends gcc.HtmlForm #{
  constructor: (@img) -> super()
  postShow: (ctx) ->
    $('#fld3',ctx).css({margin:0,padding:0})
    @pub=$('#fld2',ctx).is(':checked')
    super(ctx)
  doSave:(ctx,ok,nok) ->
    pc=$('#fld2',ctx).is(':checked')
    it=[1,2,3,4]
    add={}
    rem={}
    fc=(bin,pfx)->
      (n) -> bin[ g_ute.trim($(pfx+n, ctx).val()).replace(/[^0-9]/g,'') ]=''
    _.each(it,fc(add,'#grt'))
    _.each(it,fc(rem,'#rev'))
    pms={ groups: {}, accts: {} }
    _.each(_.keys(add), (v)-> if g_ute.vstr(v) then pms.accts[v]=true)
    _.each(_.keys(rem), (v)-> if g_ute.vstr(v) then pms.accts[v]=false)
    if @pub isnt pc
      pms.groups['all']=pc
      @pub=pc
    svc=gcc.HtmlPage.cloud.getComputeServices().getImageSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.shareMachineImageBatch(@img.getProviderMachineImageId(),pms,cbs)
#}

class ShareImageDlg extends gcc.ModalDlg #{
  constructor: (@img) -> super({ title: gcc.L10N('%share.image') })
  onOK: (ctx,rc) -> @callerCB?(@fm.pub)
  fmtHtml: (id) ->
    fc=(n)->
      v={ fid:id+n,kind:'text', width:'dlg-s8s',hint: gcc.L10N('%sample.aws.acct.no') }
      Mustache.render(gcc.Widget.EditBoxTpl(), v)
    v={ flabel: {lbl: @l10n('%acct.no')}, fid: id+1, html: _.map([1,2,3,4],fc).join('') }
    g_ute.trim(Mustache.render(gcc.Widget.FormCtlTpl(), v))
  show: (cb) ->
    ispub= if @img.getTag('isPublic') then 1 else 0
    @fm=new ShareImageFm(@img)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { off:1,lbl: @l10n('%image.id'),width:'dlg-s8s',value: @img.getProviderMachineImageId() }
    args.flds.fld2= { kind: 'cbox', lbl: @l10n('%public.access'),chkd: ispub }
    a=[]
    a.push { pid: 'revoke', ptitle:@l10n('%del.access'), phtml: @fmtHtml('rev') }
    a.push { pid: 'grant', ptitle:@l10n('%add.access'), phtml: @fmtHtml('grt') }
    args.flds.fld3= { kind:'accordion', groups: a, isown: true }
    args.yesLabel= @l10n('%savebtn')
    @fm.iniz(args)
    @inizAsForm(@fm)
#}


`

gcc.ShareImageDlg=ShareImageDlg;
gcc.BootImageDlg=BootImageDlg;


})(window, window.document, jQuery);


`
