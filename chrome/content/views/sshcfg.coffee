###
# file: sshcfg.coffee
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
g_prefs= new gcx.Prefs(),
g_ute=new gcc.Ute();


`

class CfgForm extends gcc.HtmlForm #{
  constructor: (@dlg) -> super()
  postShow: (ctx) ->
    @upSyncDAO(ctx)
    me=this
    $('#fld6',ctx).on('click', () -> me.dlg.onResetSave(ctx,me) )
  doSave: (ctx,ok,nok) ->
    cmd= g_ute.trim($('#fld1', ctx).val())
    args= g_ute.trim( $('#fld2', ctx).val())
    cpy= g_ute.trim( $('#fld3', ctx).val())
    key= g_ute.trim( $('#fld4', ctx).val())
    uid= g_ute.trim($('#fld5', ctx).val())
    g_prefs.setSSHCmd(cmd)
    g_prefs.setSSHCmdArgs(args)
    g_prefs.setSCPCmd(cpy)
    g_prefs.setSSHKey(key)
    g_prefs.setSSHUser(uid)
    fc=()-> ok()
    genv.setTimeout(fc,1000)
  upSyncDAO:(ctx) ->
    $('#fld1', ctx).val( g_prefs.getSSHCmd() )
    $('#fld2', ctx).val( g_prefs.getSSHCmdArgs() )
    $('#fld3', ctx).val( g_prefs.getSCPCmd() )
    $('#fld4', ctx).val( g_prefs.getSSHKey() )
    $('#fld5', ctx).val( g_prefs.getSSHUser() )
    $('#fld1', ctx).focus()
#}
class SSHConfig extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.sshcfg')
    orig= _.extend( {}, this)
    _.extend(this, new gcc.FormContainer(), orig)

  moniker: 'sshcfg'
  id: 'sshcfg-tpl'

  onRefresh: () -> @form.upSyncDAO( $('#' + @id))
  getTpl: () ->
    icons= @basicIcons()
    g_ute.trim [ @markup, @footerMenu(icons)  ].join('')

  postDraw: () -> @renderForm( $('#' + @id), @fmForm())
  renderFormEnd: (ctx,form) ->
    form.preShow(ctx)
    form.postShow(ctx)

  onOK: (ctx) -> @renderFormFooter(ctx, @form)
  onNOK: (ctx) -> @form.upSyncDAO(ctx)

  onResetSave: (ctx,form) ->
    g_prefs.resetSSHCfg()
    @showSaveWait(ctx)
    me=this
    fc=()->
      form.upSyncDAO(ctx)
      me.hideSaveWait(ctx,form)
    genv.setTimeout(fc,1000)

  fmForm: () ->
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%ssh.cmd.app'), width:'dlg-s8s' }
    args.flds.fld2= { lbl: @l10n('%ssh.cmd.args'), width:'dlg-s8s' }
    args.flds.fld3= { lbl: @l10n('%ssh.cpy.app'), width:'dlg-s8s' }
    args.flds.fld4= { lbl: @l10n('%ssh.key'), width:'dlg-s8s' }
    args.flds.fld5= { lbl: @l10n('%ssh.user'), width:'dlg-s8s' }
    args.flds.fld6= { kind: 'link', anchor: @l10n('%reset.dft'), czs: 'form-anchor' }
    @form= new CfgForm(this)
    @form.iniz(args)
    @form

  markup: """
      <div id="sshcfg-form">
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

gcc.SSHConfig=SSHConfig;

})(window, window.document, jQuery);


`
