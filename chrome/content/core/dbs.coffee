###
# file: dbs.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var CK_ACCTPROPS='db.acctprops',
CK_ACCTS='db.accts',
CK_USERS='db.users',
gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_prefs=new gcx.Prefs(),
g_ute=new gcc.Ute();


`


class XULDB #{
  constructor: (@dbid) -> @iniz()
  writeDB: (db) -> g_prefs.saveStr( @dbid, JSON.stringify(db))
  getDB: () -> JSON.parse( g_prefs.getStr( @dbid) )
  exists: (x) -> _.has( @getDB(),x)
  find: (x) -> @getDB()[x]
  delBatch: (pks) ->
    db=@getDB()
    t=false
    fc=(x)->
      if _.has(db,x)
        t=true
        delete db[x]
    _.each(pks, fc)
    if t then @writeDB(db)
  del: (pk) ->
    db=@getDB()
    if _.has(db,pk)
      delete db[pk]
      @writeDB(db)
  iniz: () ->
    s= g_prefs.getStr(@dbid)
    if not g_ute.vstr(s) then g_prefs.saveStr(@dbid, '{}')
#}


class AcctPropsDB extends XULDB #{
  # pk based on accts-db:key
  constructor: () -> super(CK_ACCTPROPS)
  edit: (pk,props) ->
    db=@getDB()
    if _.has(db,pk)
      db[pk]=props || {}
      @writeDB(db)
  onNewAcct: (vendor,pk) ->
    db=@getDB()
    r=null
    if not _.has(db,pk)
      r= gcc.CloudVendor.newProps(vendor)
      db[pk] =r
      @writeDB(db)
    r
#}


class AcctsDB extends XULDB #{
  # pk based on user-db:key
  constructor: () -> super(CK_ACCTS)
  getAccts: (pk) ->
    obj= @find(pk)
    if is_alive(obj) then [ obj.cur, obj.cc ] else ['', {} ]
  setCurAcct: (pk, acctpk) ->
    db= @getDB()
    v= db[pk]
    if is_alive(v) and _.has(v.cc,acctpk)
      v.cur=acctpk
      @writeDB(db)
  getCurAcct: (pk) ->
    db= @getDB()
    v= db[pk]
    rec=null
    if is_alive(v) and g_ute.vstr(v.cur)
      rec= v.cc[v.cur]
    rec
  countAccts: (pk) ->
    v= @getDB()[pk]
    if is_alive(v) then _.keys(v.cc).length else 0
  edit: (pk,acctpk, changes) ->
    changes=changes || {}
    db=@getDB()
    v=db[pk]
    obj=if is_alive(v) then v.cc[acctpk] else null
    ed=false
    if is_alive(obj)
      if _.has(changes,'id')
        obj.id=g_ute.trim( changes.id)
        ed=true
      if _.has(changes,'pwd')
        obj.pwd= g_xul.obfuscate(g_ute.trim( changes.pwd))
        ed=true
      if _.has(changes,'email')
        obj.email=g_ute.trim( changes.email)
        ed=true
    if ed then @writeDB(db)
  del: (pk,acctpk) ->
    db=@getDB()
    v=db[pk]
    if _.has(v.cc,acctpk)
      if v.cur is acctpk then v.cur=''
      delete v.cc[acctpk]
      if _.keys(v.cc).length is 1
        v.cur = _.values(v.cc)[0].key
      @writeDB(db)
      g_xul.info('Deleted account: {{key}}', {key: acctpk })
  add: (pk,vendor,acctno,email,id,pwd) ->
    vendor= g_ute.trim(vendor)
    id= g_ute.trim(id)
    acctno= gcc.CloudVendor.normalize(vendor,acctno)
    db=@getDB()
    v=db[pk]
    fc=(obj)-> obj.acctno is acctno and obj.id is id and obj.vendor is vendor
    arr=_.values(v.cc)
    r= if arr.length > 0 then _.find(arr, fc) else null
    error=''
    if is_alive(r)
      error= gcc.L10N('%err.acct.exists', { vendor: vendor, acctno: acctno})
    else
      s=g_xul.obfuscate( g_ute.trim(pwd))
      t=null
      while not is_alive(t)
        r=
          'email': g_ute.trim(email)
          'pwd': s
          'vendor': vendor
          'id': id
          'acctno': acctno
          'key': g_ute.randomText()
        t=new AcctPropsDB().onNewAcct(vendor, r.key)
        if is_alive(t)
          if arr.length is 0 then v.cur= r.key
          v.cc[r.key]=r
          @writeDB(db)
          g_xul.info('Added new account: {{acctno}}@{{vendor}}', r)
    [r,error]
  onNewUser: (pk) ->
    db=@getDB()
    r=null
    if not _.has(db,pk)
      r={ cur: '', cc: {} }
      db[pk]=r
      @writeDB(db)
    r
#}

class UsersDB extends XULDB #{
  constructor: () ->
    super(CK_USERS)
    if not @exists('admin') then @add('admin','')
  setUserPwd: (user, pwd) ->
    db=@getDB()
    if _.has(db,user)
      db[user].pwd= g_xul.obfuscate(pwd)
      @writeDB(db)
  del:(x) ->
    rec= @get(x)
    if is_alive(rec)
      db2=new AcctPropsDB()
      db1=new AcctsDB()
      [cur, cc] = db1.getAccts(rec.key)
      if is_alive(cc) then db2.delBatch(_.keys(cc))
      db1.del(rec.key)
    super(x)
  add: (user,pwd) ->
    user=g_ute.trim(user)
    pwd=g_ute.trim(pwd)
    db=@getDB()
    r=null
    error=''
    if _.has(db,user)
      error= gcc.L10N('%err.user.exists', { user: user})
    else
      t=null
      while not is_alive(t)
        r={}
        r.pwd= g_xul.obfuscate(pwd)
        r.key= g_ute.randomText()
        t=new AcctsDB().onNewUser(r.key)
        if is_alive(t)
          db[user]=r
          @writeDB(db)
    [r,error]
#}


`


gcc.AcctPropsDB=AcctPropsDB;
gcc.UsersDB=UsersDB;
gcc.AcctsDB=AcctsDB;

})(window, window.document, jQuery);


`
