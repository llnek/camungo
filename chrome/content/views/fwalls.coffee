###
# file: fwalls.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var g_nfc=function(){},
gc=genv.ComZotoh,
gcc=gc.Camungo,
gcx=gc.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class FireWalls extends gcc.PivotItemPC #{

  constructor: () ->
    super('%topic.fwalls','fwalls-grid','ports-grid')
    @cm1= [ @tct('%id'), @tct('%protocol'), @tct('%cidr'), @tct('%icmp.ports'), @tct('%user.grp') ]
    @cm0= [ @tct('%id'), @tct('%name'), @tct('%fw.id'), @tct('%desc') ]

  moniker: 'fwalls'
  id: 'fwalls-tpl'
  cid: 'fwtbr'

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('add')).click( ()-> me.onAddFwall() )
    $('#'+ @btnid('del')).click( () -> me.onDelFwall() )
    $('#btn-grant').click( () -> me.onAddRule() )
    $('#btn-revoke').click( () -> me.onDelRule() )

  postAddRule:(fw,rec)->
    m=@cache[@c_gid]
    m[rec.getProviderRuleId()]=rec
    fw.getRules().push(rec)
    @addOneChild( m, @dtbl(@c_gid), rec)
  onAddRule: () ->
    r= @getCurRow( @dtbl(@par_gid) )
    if is_alive(r)
      r=@cache[ @par_gid][r[0]]
      me=this
      new gcc.AddFwallRuleDlg(r).show( (rec) -> me.postAddRule(r,rec) )

  postDelRule:(fw,rule)->
    rid= rule.getProviderRuleId()
    arr=fw.getRules()
    pos= -1
    _.each(arr, (r,i)-> if r.getProviderRuleId() is rid then pos=i )
    if pos >= 0 then g_ute.delArrayElem(arr,pos)
    delete @cache[ @c_gid][ rid]
    @delOneRow(@c_gid)

  onDelRule: () ->
    pr=@getCurRow( @dtbl(@par_gid) )
    cr= if is_alive(pr) then @getCurRow( @dtbl(@c_gid)) else null
    if is_alive(cr)
      pr=@cache[ @par_gid][pr[0]]
      cr=@cache[ @c_gid][cr[0]]
      me=this
      new gcc.DelFwallRuleDlg(pr, cr).show( ()-> me.postDelRule(pr,cr) )

  postAddFwall: (rec) -> 
    @addOneRow( @dtbl(@par_gid), rec, @cache[@par_gid] )
  onAddFwall: () -> 
    me=this
    new gcc.AddFwallDlg().show( (rec) -> me.postAddFwall(rec) )

  postDelFwall: (rec) ->
    delete @cache[ @par_gid][rec.getProviderFirewallId() ]
    @delOneRow(@par_gid)
  onDelFwall: () ->
    r= @getCurRow( @dtbl(@par_gid) )
    if is_alive(r)
      r= @cache[ @par_gid][r[0]]
      me=this
      new gcc.DelFwallDlg(r).show( (rec) -> me.postDelFwall(rec))

  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add'), title: @l10n('%new.fwall'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.fwall'),icon:'minus'}
    bObj=[]
    bObj.push { bid:'btn-grant',btn: @l10n('%grant') }
    bObj.push { bid:'btn-revoke', btn: @l10n('%revoke') }
    s=Mustache.render(@midsect,{tbar: @l10n('%perms'), cid: @cid, btns:bObj })
    s= [ @tableHtml( @par_gid) , s , @tableHtml(@c_gid), @footerMenu(icons) ].join('')
    g_ute.trim(s)

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getFirewallSupport()
    @onSync(svc,svc.list,[], @par_gid)

  fmtAsRow: (dtb, row) ->
    if dtb.attr('id') is @par_gid
      id=row.getProviderFirewallId()
      data= [id, row.getName(), id, row.getDescription() ]
    else
      g= row.getGroup().join(' | ').trim().replace(/(^\||\|$)/g,'').trim()
      pr=row.getProtocol()?.toString() || ''
      id=row.getProviderRuleId()
      p0= row.getStartPort()
      p1= row.getEndPort()
      f4= [p0,p1].join( if pr is 'icmp' then ' / ' else ' .. ')
      data= [ id, pr, row.getCidr() || '', f4, g ]
    [ id, data ]

  childFilter: {tags:0,name:0}
  parFilter: {rules:0,tags:0}

  onParClicked: (table,data) ->
    #@showChildBusy(true, @cid)
    row=@cache[@par_gid][ data[0] ]
    @uploadTable( @c_gid, row.getRules())
    #@showChildBusy(false, @cid)

  addOneChild: (map,table, row) ->
    g= row.getGroup().join(' | ').trim().replace(/(^\||\|$)/g,'').trim()
    pr=row.getProtocol()?.toString() || ''
    id=row.getProviderRuleId()
    p0= row.getStartPort()
    p1= row.getEndPort()
    f4= [p0,p1].join( if pr is 'icmp' then ' / ' else ' .. ')
    table.fnAddData([ id, pr, row.getCidr() || '', f4, g ] )
    map[ id ]=row
    @addOneRow(table, row, bin)

#}

`

gcc.FireWalls=FireWalls;

})(window, window.document, jQuery);


`
