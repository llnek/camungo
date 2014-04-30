###
# file: genprefs.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gc=genv.ComZotoh,
g_nfc=function(){},
gcc=gc.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_prefs=new gcx.Prefs(),
g_ute=new gcc.Ute();


`

class PrefsForm extends gcc.HtmlForm #{
  constructor: (@dlg) -> super()
  postShow: (ctx) -> @upSyncDAO(ctx)
  onJSCons: (ctx) ->
    if $('#fld4',ctx).is(':checked')
      g_xul.openJSConsole()
    else
      g_xul.finzJSConsole()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld1'
      if isNaN(value) then @flagError(ctx,flags,id)
  doSave: (ctx,ok,nok) ->
    reqwait= $('#fld1', ctx).val()
    log= $('#fld2', ctx).is(':checked')
    dbg= $('#fld3', ctx).is(':checked')
    jsc= $('#fld4', ctx).is(':checked')
    g_prefs.setREQWait(reqwait)
    g_prefs.setEnableDebug(dbg)
    g_prefs.setEnableLog(log)
    g_prefs.setJSCons(jsc)
    bw=g_xul.getBrowser()
    bw.setUserData('log.flags', { log: log, debug: dbg}, g_nfc)
    fc=()-> ok()
    genv.setTimeout(fc,1000)
  upSyncDAO:(ctx) ->
    $('#fld1', ctx).val( g_prefs.getREQWait())
    $('#fld2', ctx).attr('checked', g_prefs.getEnableLog() )
    $('#fld3', ctx).attr('checked', g_prefs.getEnableDebug())
    $('#fld4', ctx).attr('checked', g_prefs.getJSCons())
    $('#fld1', ctx).focus()
#}

class GeneralPrefs extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.genprefs')
    orig= _.extend( {}, this)
    _.extend(this, new gcc.FormContainer(), orig)

  moniker: 'prefs'
  id: 'prefs-tpl'

  onRefresh: () -> @form.upSyncDAO( $('#' + @id))

  getTpl: () ->
    icons= @basicIcons()
    g_ute.trim [ Mustache.render( @markup, {}), @footerMenu(icons)  ].join('')

  postDraw: () -> @renderForm( $('#' + @id), @fmForm())

  renderFormEnd: (ctx,form) ->
    form.preShow(ctx)
    form.postShow(ctx)

  onOK: (ctx) ->
    @renderFormFooter(ctx, @form)
    if is_alive(gc.LogJS)
      if g_prefs.getEnableDebug()
        gc.LogJS.setDebug()
      else if g_prefs.getEnableLog()
        gc.LogJS.setInfo()
      else
        gc.LogJS.setOFF()
    if g_prefs.getJSCons()
      g_xul.openJSConsole()
    else
      g_xul.finzJSConsole()

  onNOK: (ctx) -> @form.upSyncDAO(ctx)
  fmForm: () ->
    args={ flds: {} }
    args.flds.fld1= { reqd:1,kind:'number', lbl: @l10n('%prefs.req.wait'), width:'dlg-s8s' }
    args.flds.fld2= { kind:'cbox',lbl: @l10n('%prefs.logging') }
    args.flds.fld3= { kind:'cbox',lbl: @l10n('%prefs.debug') }
    args.flds.fld4= { kind:'cbox',lbl: @l10n('%prefs.jsconsole') }
    @form= new PrefsForm(this)
    @form.iniz(args)
    @form

  markup: """
      <div id="genprefs-form">
        <div class="row-fluid">
            <div class="span12">
              <div class="modal-body">&nbsp;</div>
              <div class="modal-footer">&nbsp;</div>
            </div>
        </div>
      </div>
  """


#}

`

gcc.GeneralPrefs=GeneralPrefs;

})(window, window.document, jQuery);


`

