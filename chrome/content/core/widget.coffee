###
# file: widget.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var
gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_ute=new gcc.Ute();

// make a datatable - grid, using the 'bootstrap' theme
function g_makeDTable(id, model, len, pms) {
  var args={
    aoColumnDefs : [ 
      {"fnRender": function(oObj, sVal) {
            if (is_alive(sVal) && (sVal instanceof Date)) {
              sVal=g_ute.utctime(sVal);
            }
            return sVal;
          }, "aTargets": ['_all']},
      {bSearchable:false,bVisible:false,aTargets:[0]} ],
    aLengthMenu : [[ len, -1], [ len, "All"]],
    aaSorting : [[ 1, "desc" ]],
    sPaginationType : "bootstrap",
    oLanguage: { sLengthMenu : "_MENU_ records per page" },
    aoColumns: model,
    aaData: []
  };
  args=_.extend(args,pms);
  return $('#'+id).dataTable( args);
}

`

class Widget #{
#}
Widget.FormHorzTpl = ()->
  """
      <form class="form-horizontal">
        {{{fflds}}}
      </form>
  """
Widget.FormTpl = ()->
  """
      <form class="form-vertical">
        {{{fflds}}}
      </form>
  """
Widget.AnchorTpl= () ->
  """
    <a id="{{fid}}" href="{{href}}" class="{{czs}}">{{anchor}}</a>
  """
Widget.EditBoxTpl= () ->
  """
      <input id="{{fid}}" type="{{kind}}" {{required}} {{_autofocus}} class="{{width}} {{czs}}" 
        value="{{value}}" placeholder="{{hint}}" {{disabled}} ></input>
  """
Widget.TBoxTpl= () ->
  """
      <textarea  id="{{fid}}" {{cols}} rows="{{rows}}" class="{{width}}" {{disabled}} ></textarea>
  """
Widget.CBoxTpl= () ->
  """
      <input id="{{fid}}" type="checkbox" class="checkbox" {{disabled}} {{checked}}></input>
  """
Widget.DDListTpl= () ->
  """
      <select id="{{fid}}" {{disabled}} {{multi}} >
        {{#choices}}
          <option value="{{value}}">{{disp}}</option>
        {{/choices}}
      </select>
  """
Widget.PickListTpl= () ->
  """
      <div>
        <select id="{{fid}}-src" size="{{rows}}">
          {{#choices}}
            <option value="{{value}}">{{disp}}</option>
          {{/choices}}
        </select>
        <table><tr>
          <td><a id="{{fid}}-add" href="#">{{addbtn}}</a></td>
          <td><a id="{{fid}}-del" href="#">{{delbtn}}</a></td>
        </tr></table>
        <select id="{{fid}}-des" size="{{rows}}">
          <option value="-1">None</option>
        </select>
      </div>
  """
Widget.AccordionTpl= () ->
  """
    <div class="accordion {{width}}" id="{{fid}}">
      {{#groups}}
      <div class="accordion-group">
        <div class="accordion-heading">
          <a class="accordion-toggle" data-toggle="collapse" data-parent="{{:fid}}" href="{{:pid}}">
          {{{ptitle}}}
          </a>
        </div>
        <div id="{{pid}}" class="accordion-body collapse">
          <div class="accordion-inner">{{{phtml}}}</div>
        </div>
      </div>
      {{/groups}}
    </div>
  """.replace(/{{:/g,'#{{')
Widget.InlineCBoxTpl= () ->
  """
        <div id="{{fid}}-cg" class="control-group">
          <label class="checkbox" for="{{fid}}">
            {{{html}}}
            {{lbl}}
          </label>
        </div>
  """
Widget.FormCtlTpl= () ->
  """
        <div id="{{fid}}-cg" class="control-group">
          {{#flabel}}
          <label class="control-label" for="{{fid}}">{{lbl}}</label>
          {{/flabel}}
          <div class="controls">
            {{{html}}}
          <span class="help-inline">{{help}}</span>
          </div>
        </div>
  """
Widget.RadiosTpl= () ->
  """
    {{#rbtns}}
    <label class="radio {{inline}}">
      <input type="radio" name="{{fname}}" id="{{fid}}" 
        value="{{value}}" {{checked}}></input>
      {{disp}}
    </label>
    {{/rbtns}}
  """

class Grid #{
#}
Grid.create= (id,model,len, args) ->
  pms=
    'sDom' : "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>"
  g_makeDTable(id, model, len, _.extend(pms,args || {} ) )

Grid.createSimple= (id,model, len, args) ->
  pms=
    'sDom' : "t<'row-fluid'<'span6'i><'span6'p>>"
  g_makeDTable(id, model, len, _.extend(pms,args || {} ))


class Tabs #{
#}
Tabs.create= (id,ctx,toggler,tabids) ->
  $('#'+id+' a:first').tab('show')
  fc=(e)-> toggler.call( ctx, $(e.relatedTarget).attr('href'), $(e.target).attr('href') )
  $('#'+id+' a[data-toggle="tab"]').on('shown', fc)
  toggler.call(ctx, '', '#'+tabids[0])


# not tested nor used
class PickList extends Widget #{
  constructor: (src,des,add,del) ->
    @src= $('#'+src).get()
    @des= $('#'+des).get()
    @sort=false
    @multi=false
    me=this
    $('#'+des).on('click', () -> me.delFromDes() )
    $('#'+add).on('click', () -> me.addToDes() )

  addToDes: () ->
    idx= @src.selectedIndex
    so= @src.options
    po= @des.options
    pl=po.length
    if idx >= 0
      po[pl] = new Option( @src[idx].text)
      po[pl].value = @src[idx].value
      if not @multi then so[idx] = null

  delFromDes: () ->
    idx=@des.selectedIndex
    so=@src.options
    sl=so.length
    po=@des.options
    pl=po.length
    if idx >= 0
      if not @multi
        so[sl] = new Option( @des[idx].text)
        so[sl].value = @des[idx].value
      po[idx] = null
#}



`

gcc.PickList=PickList;
gcc.Widget=Widget;
gcc.Grid=Grid;

})(window, window.document, jQuery);


`
