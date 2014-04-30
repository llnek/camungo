###
# file: ute.coffee
###
`
(function(genv,document,$,undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (! is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (! is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }

var C_CHARS= (function() {
  function rs(a,b) { var t= parseInt( Math.random()*10 );
    return (t%2) * (t>5 ? 1 : -1)
  }
  var arr=[ '_-','0123456789','abcdefghijklmnopqrstuvwxyz',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'].join('').split('');
  //return arr.sort(rs).join('');
  return _.shuffle(arr).join('');
})(),
C_PUNC="~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/? ",
g_nfc=function() {},
gcc=genv.ComZotoh.Camungo;

function rand(lf, rt) {
  return lf + Math.floor(Math.random() * (rt - lf));
}

/* With due thanks to http://whytheluckystiff.net */
/* other support functions -- thanks, ecmanaut! */
var zeropad= function( n ){ return n>9 ? n : '0'+n; };
var strftime_funks = {
  'a' : function(t) { return ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][t.getDay()]; },
  'A' : function(t) { return ['Sunday','Monday','Tuedsay','Wednesday','Thursday','Friday','Saturday'][t.getDay()]; },
  'b' : function(t) { return ['Jan','Feb','Mar','Apr','May','Jun', 'Jul','Aug','Sep','Oct','Nov','Dec'][t.getMonth()]; },
  'B' : function(t) { return ['January','February','March','April','May','June', 'July','August',
      'September','October','November','December'][t.getMonth()]; },
  'c' : function(t) { return t.toString(); },
  'd' : function(t) { return zeropad(t.getDate()); },
  'H' : function(t) { return zeropad(t.getHours()); },
  'I' : function(t) { return zeropad((t.getHours() + 12) % 12); },
  'm' : function(t) { return zeropad(t.getMonth()+1); }, // month-1
  'M' : function(t) { return zeropad(t.getMinutes()); },
  'p' : function(t) { return zeropad(t.getHours()) < 12 ? 'AM' : 'PM'; },
  'S' : function(t) { return zeropad(t.getSeconds()); },
  'w' : function(t) { return t.getDay(); }, // 0..6 == sun..sat
  'y' : function(t) { return zeropad( zeropad(t.getFullYear()) % 100); },
  'Y' : function(t) { return t.getFullYear(); },
  '%': function(t) { return '%'; }
};





`

class Ute #{

  constructor: () ->
  to_s:(obj)-> if is_alive(obj) then obj.toString() else ''

  strftime: (dt, fmt) ->
    for own k,v of strftime_funks
      if k.length is 1 then fmt = fmt.replace('%' + k, v(dt))
    fmt

  utctime: (dt) ->
    rc=if is_alive(dt) then dt.toUTCString() else ''
    pos= rc.indexOf(',')
    if pos > 0 then rc= rc.slice(pos+1).trim()
    rc

  #Array Remove - By John Resig (MIT Licensed)
  delArrayElem: (arr,from,to)->
    rest = arr.slice((to || from) + 1 || arr.length)
    arr.length = if from < 0 then (arr.length + from) else from
    arr.push.apply(arr, rest)
  tokenize: (s) ->
    len=s?.length || 0
    tokens = []
    sep = ' '
    tok = ''
    for i in [0...len]
      ch = s[i]
      if ch is sep
        if sep is ' '
          if tok.length > 0 then tokens.push(tok)
          tok = ''
        else
          sep = ' '
      else if sep is ' ' and (ch is '"' || ch is "'")
        sep = ch
      else
        tok += ch

    if tok.length > 0 then tokens.push(tok)
    tokens

  mid: (src, head, tail) ->
    src=src || ''
    try
      rp= src?.lastIndexOf(tail)
      lp= src?.indexOf(head)
      if rp >= 0 and lp >= 0
        s= src.slice(lp+head.length, rp)
    catch e
    s || ''

  escXML: (s) ->
    (s || '').replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/'/g, "&apos;")

  urlEncode: (s) ->
    encodeURIComponent(s||'').replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/'/g, '%27').replace(/\*/g, '%2A')

  isLinux : () ->
    if @isWIN() then false else if @isOSX() then false else true

  isOSX : () ->
    s= navigator.platform.toLowerCase()
    if s.indexOf('osx') >= 0 or s.indexOf('mac') >= 0 then true else false

  isWIN : () ->
    if navigator.platform.toLowerCase().indexOf('win') >= 0 then true else false

  setHideFlag : (doc, id, b) -> doc.getElementById(id)?.hidden=b

  gt: (o,n)-> o?.getElementsByTagName(n)

  fcn:(node) ->
    if node? and node.firstChild? then node.firstChild.nodeValue else null

  vstr: (s) -> is_alive(s) and s.constructor is String and s.length > 0

  isVisible: (v) -> if is_alive(v) and v.hidden is false then true else false

  getText : (doc, id) -> @trim( doc.getElementById(id)?.value )

  setText: (doc, id, v) -> doc.getElementById(id)?.value= v || ''

  l10n : (key, pms) -> gcc.L10N(key,pms)

  niceAcctID :  (s) ->
    if is_alive(s) and s.length is 12
      s= [ s.slice(0,4), s.slice(4,8), s.slice(8,12) ].join('-')
    s

  niceTS : (dt) -> if is_alive(dt) then @strftime(dt,'%Y-%m-%d %H:%M:%S') else ''

  trim : (s) -> if is_alive(s) and s.constructor is String then s.trim() else ''

  randomText: (len) ->
    X=C_CHARS.length
    len=len || 16
    rc=[]
    for n in [0...len]
      rc.push  C_CHARS.charAt( rand(0, X))
    rc.join('')

  undoOverlay : () -> $('#busy-wait').modal('hide')
  maskOverlay : () -> $('#busy-wait').modal('show')

  _undoOverlay : () -> $.colorbox.close()
  _maskOverlay : () ->
    args=
      innerWidth : "160px"
      innerHeight : "20px"
      title : ''
      close : ''
      transition : 'none'
      overlayClose: false
      escKey: false
      opacity : 0.8
      html : '<div style="background-color:none;"><img style="margin: 0 auto; display:block;" src="chrome://camungo/skin/images/red-loading.gif"></div>'
    $.colorbox(args)

  # I could not get colorbox to work
  cbox : ( titleline, htm, onload, width, height ) ->
    args=
      showClose : false
      overlayClose : false
      escKey : false
      opacity : 0.3
      title : titleline || ''
      html : htm || ''
      onComplete : onload || g_nfc
    if height? then args['innerHeight']= height
    if width? then args['innerWidth']= width
    $.colorbox(args)

#}

class Bits #{

Bits.strToBytes= (st) ->
  len=st?.length || 0
  bA= if len > 0 then [] else null
  bA[i]=st.charCodeAt(i) for i in [0...len]
  bA

Bits.bytesToStr= (bA) ->
  len= bA?.length || 0
  R= if len > 0 then '' else null
  for i in [0...len]
    if bA[i] isnt 0 then R += String.fromCharCode(bA[i])
  R

Bits.bytesToHex= (bA) ->
  len= bA?.length || 0
  R= if len > 0 then '' else null
  for i in [0...len]
    R+= ( if bA[i] < 16 then '0' else '' ) + bA[i].toString(16)
  R

Bits.hexToBytes= (hS) ->
  bA=null
  if is_alive(hS) and (hS.length % 2) is 0
    bA=[]
    if hS.match(/^(0x|0X)/) isnt null then hS= hS.slice(2)
    i=0
    while i < hS.length
      bA[Math.floor(i/2)]=parseInt(hS.slice(i,i+2),16)
      i += 2
  bA

#}



`
gcc.Ute=Ute;

})(window,window.document,jQuery);

`
