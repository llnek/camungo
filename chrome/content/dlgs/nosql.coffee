###
# file: nosql.coffee
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

class AddNoSQLFm extends gcc.HtmlForm #{
  constructor: () -> super()
  doSave:(ctx,ok,nok) ->
    n=g_ute.trim($('#fld1',ctx).val())
    svc= gcc.HtmlPage.cloud.getPlatformServices().getKeyValueDatabaseSupport()
    svc.createDatabase(n, '', gcc.PivotItem.CBS(ok,nok))
#}
class AddNoSQLDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.db') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddNoSQLFm()
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { reqd:1,focus:1,lbl: @l10n('%name'),width:'dlg-s8s' }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelNoSQLFm extends gcc.HtmlForm #{
  constructor: (@db) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getPlatformServices().getKeyValueDatabaseSupport()
    svc.removeDatabase(@db.getProviderDatabaseId(), gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelNoSQLDlg extends gcc.ModalDlg #{
  constructor: (@db) -> super({ title: gcc.L10N('%del.db') })
  onOK: (ctx,rc) -> @callerCB?(@db)
  show: (cb) ->
    f=new DelNoSQLFm(@db)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',value: @db.getProviderDatabaseId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


class AddSQLItemFm extends gcc.HtmlForm #{
  constructor: (@dbname,@name) ->
    @orig={}
    @kvs={}
    super()
  postShow:(dlg)->
    $('#fld1', dlg).addClass('disabled')
    me=this
    if g_ute.vstr(@name)
      $('#fld2', dlg).addClass('disabled')
      fc=(r)->
        k=r.getKey()
        me.kvs[k]=r
        me.orig[k]=''
      nok=()->
      ok=(rc)->
        _.each(rc.getFields(), fc)
        h=_.map(_.keys(me.kvs).sort(), (v) -> me.htmOneDDListOpt(v)).join('')
        $('#fld3',dlg).empty().html( g_ute.trim(h))
      svc=gcc.HtmlPage.cloud.getPlatformServices().getKeyValueDatabaseSupport()
      svc.getKeyValuePairs(@dbname,@name,true,gcc.PivotItem.CBS(ok,nok))
    $('#btnadditem',dlg).on('click', () -> me.onAddItem(dlg) )
    $('#btndelitem',dlg).on('click', ()->me.onDelItem(dlg) )
    $('#btnedtitem',dlg).on('click', ()->me.onEditItem(dlg) )
    $('#fld3',dlg).on('change', ()->me.onSelCol(dlg) )
    super(dlg)
  onSelCol:(dlg)->
    a=@getMultiDDList('fld3')
    nm=if a.length > 0 then a[0] else ''
    kv=if g_ute.vstr(nm) then @kvs[nm] else null
    if is_alive(kv)
      $('#fld6',dlg).val(kv.getValue())
      $('#fld5',dlg).val(kv.getKey())
  onEditItem: (dlg) ->
    a=@getMultiDDList('fld3')
    nm=if a.length > 0 then a[0] else ''
    kv=if g_ute.vstr(nm) then @kvs[nm] else null
    if nm is g_ute.trim($('#fld5',dlg).val()) then kv.setValue($('#fld6',dlg).val())
    $('#fld3',dlg).val([])
    $('#fld6',dlg).val('')
    $('#fld5',dlg).val('')
  onAddItem: (dlg) ->
    v=g_ute.trim($('#fld6',dlg).val())
    n=g_ute.trim($('#fld5',dlg).val())
    $('#fld3',dlg).append('<option value="'+n+'">'+n+'</option>')
    $('#fld3',dlg).val([])
    $('#fld6',dlg).val('')
    $('#fld5',dlg).val('')
    @kvs[n]= new gc.CloudAPI.Platform.KeyValuePair(n,v)
  onDelItem: (dlg) ->
    a=@getMultiDDList('fld3')
    me=this
    fc=(k)->
      me.orig[k]= me.kvs[k]
      delete me.kvs[k]
    _.each(a, fc)
    $('#fld3 option:selected',dlg).remove()
    $('#fld3',dlg).val([])
    $('#fld6',dlg).val('')
    $('#fld5',dlg).val('')
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getPlatformServices().getKeyValueDatabaseSupport()
    item=g_ute.trim($('#fld2',ctx).val())
    me=this
    del=_.reject(_.keys(@orig), (k) -> _.has(me.kvs,k) )
    add=_.reject(_.keys(@kvs), (k) -> _.has(me.orig,k) )
    cur=_.filter(_.keys(@kvs), (k) -> _.has(me.orig,k) )
    c2=()->
      a=_.map(cur, (k)-> me.kvs[k] )
      if a.length > 0
        svc.replaceKeyValuePairs(me.dbname,item,a,gcc.PivotItem.CBS(ok,nok))
      else
        ok(item)
    c1=()->
      a=_.map(add, (k)-> me.kvs[k] )
      if a.length > 0
        svc.addKeyValuePairs(me.dbname,item,a,gcc.PivotItem.CBS(c2,nok))
      else
        c2()
    a=_.map(del, (k)-> me.orig[k])
    if a.length > 0
      svc.removeKeyValuePairs(me.dbname,item,a,gcc.PivotItem.CBS(c1,nok))
    else
      c1()
#}
class AddSQLItemDlg extends gcc.ModalDlg #{
  constructor: (@dbname,@name) -> 
    @edit= g_ute.vstr(@name)
    super({ title: gcc.L10N( if @edit then '%edit.item' else '%add.item') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddSQLItemFm(@dbname,@name)
    @callerCB=cb
    nm=if @edit then @name else ''
    flag= if @edit then 1 else 0
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%db.name'),width:'dlg-s8s',value: @dbname, off:1 }
    args.flds.fld2= { reqd:1,focus:1,lbl: @l10n('%item.name'),width:'dlg-s8s', value: nm, off: flag }
    args.flds.fld3= { kind:'list',lbl: @l10n('%db.cols'),multi:1,choices: []}
    html="""
      <div id="link-toolbar" class="control-group">
        <a id="btnadditem" class="pull-left" href="#">{{add}}</a>
        <a id="btndelitem" class="pull-left" href="#">{{del}}</a>
        <a id="btnedtitem" class="pull-left" href="#">{{edit}}</a>
      </div>
        <div style="clear:both;"></div>
    """
    html=Mustache.render(html,{add: @l10n('%add'), del: @l10n('%remove'), edit: @l10n('%edit') })
    args.flds.fld4= { kind:'html', html: html}
    args.flds.fld5= { lbl: @l10n('%name'), width:'dlg-s8s' }
    args.flds.fld6= { lbl: @l10n('%value'), width:'dlg-s8s' }
    args.yesLabel= @l10n('%savebtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelSQLItemFm extends gcc.HtmlForm #{
  constructor: (@dbname,@item) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getPlatformServices().getKeyValueDatabaseSupport()
    svc.removeItem(@dbname, @item.getName(),gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelSQLItemDlg extends gcc.ModalDlg #{
  constructor: (@dbname,@item) -> super({ title: gcc.L10N('%del.item') })
  onOK: (ctx,rc) -> @callerCB?(@item)
  show: (cb) ->
    f=new DelSQLItemFm(@dbname,@item)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%db.name'),width:'dlg-s8s',value: @dbname, off:1 }
    args.flds.fld2= { lbl: @l10n('%name'),width:'dlg-s8s',value: @item.getName(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}



`

gcc.AddNoSQLDlg=AddNoSQLDlg;
gcc.DelNoSQLDlg=DelNoSQLDlg;

gcc.DelSQLItemDlg=DelSQLItemDlg;
gcc.AddSQLItemDlg=AddSQLItemDlg;

})(window, window.document, jQuery);


`
