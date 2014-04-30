###
# file: modal.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class ModalDlg extends gcc.FormContainer #{

  constructor: (args) ->
    super()
    @args={ id: 'modal-popup', title: '', esc: true }
    _.extend( @args, args || {} )
  renderFormHeader: (ctx,form) ->
    $('.modal-header h4',ctx).empty().text( @args.title)
    $('.modal-header',ctx).css('display','block')
  inizAsForm: (form) ->
    dlg=$('#'+ @args.id)
    # get rid of old binds
    dlg.off('shown')
    dlg.off('show')
    @renderForm( dlg, form)
    dlg.on('shown', () -> form.postShow(dlg))
    dlg.on('show', () -> form.preShow(dlg))
    #dlg.on('hidden', () -> $('.modal-body',dlg).empty() )
    dlg.modal( { keyboard: @args.esc, backdrop: 'static' } )
  onNOK: (ctx) -> ctx.modal('hide')
  onOK: (ctx, robj) ->
  getId:() -> @args.id
  onSaveOK: (ctx,robj) ->
    super(ctx,robj)
    ctx.modal('hide')
#}

class ErrorFm extends gcc.HtmlForm #{
  constructor: () -> super()
#}
class ErrorDlg extends ModalDlg #{
  constructor: () -> super({ title: '', esc:true })
  renderFormHeader: (ctx,form) ->
    $('.modal-header',ctx).css('display','none')
  renderFormBody: (ctx,form) ->
    super(ctx,form)
    $('.modal-body',ctx).css('background-color','#f2dede')
  renderFormFooter: (ctx,form) ->
    em=$('.modal-footer', ctx).empty()
    h=Mustache.render(@mboxfooter, { okbtn: @l10n('%dismissbtn') })
    s=Mustache.render( @formfooter, { footerbtns: h } )
    em.html( g_ute.trim(s))
    me=this
    $('#okbtn', ctx).click( () -> me.onSaveOK(ctx) )
  onOK: (ctx,rc) ->
  show: (errmsg) ->
    htm=Mustache.render(@errortxt, { msg: errmsg , ohsnap: @l10n('%ohsnap')})
    f=new ErrorFm()
    args={ flds: {}}
    args.flds.fld1= { kind:'html', html: htm }
    args.yesLabel= @l10n('%ok')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.ModalDlg=ModalDlg;
gcc.ErrorDlg=ErrorDlg;

})(window, window.document, jQuery);


`
