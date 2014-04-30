/////////////////////////////////////////////////
//
// Basic JavaScript File and Directory IO module
// By: MonkeeSage, v0.1
//
/////////////////////////////////////////////////

if (typeof(JSIO) != 'boolean') 
{
	var JSIO = true;
  var Ci= Components.interfaces;
  var Cc= Components.classes;

	// Basic file IO object based on Mozilla source
	// code post at forums.mozillazine.org

	// Example use:
	// var fileIn = FileIO.open('/test.txt');
	// if (fileIn.exists()) {
	// 	var fileOut = FileIO.open('/copy of test.txt');
	// 	var str = FileIO.read(fileIn);
	// 	var rv = FileIO.write(fileOut, str);
	// 	alert('File write: ' + rv);
	// 	rv = FileIO.write(fileOut, str, 'a');
	// 	alert('File append: ' + rv);
	// 	rv = FileIO.unlink(fileOut);
	// 	alert('File unlink: ' + rv);
	// }

	var FileIO = 
	{
		localfileCID  : '@mozilla.org/file/local;1',
		localfileIID  : Ci.nsILocalFile,

		finstreamCID  : '@mozilla.org/network/file-input-stream;1',
		finstreamIID  : Ci.nsIFileInputStream,

		foutstreamCID : '@mozilla.org/network/file-output-stream;1',
		foutstreamIID : Ci.nsIFileOutputStream,

		sinstreamCID  : '@mozilla.org/scriptableinputstream;1',
		sinstreamIID  : Ci.nsIScriptableInputStream,

		suniconvCID   : '@mozilla.org/intl/scriptableunicodeconverter',
		suniconvIID   : Ci.nsIScriptableUnicodeConverter,

    newInputStream: function(file) {
      try {
        var inStream = Cc["@mozilla.org/network/file-input-stream;1"].createInstance(Ci.nsIFileInputStream);
        inStream.init(file, 1, 1, inStream.CLOSE_ON_EOF);
        var bufInStream = Cc["@mozilla.org/network/buffered-input-stream;1"].createInstance(Ci.nsIBufferedInputStream);
        bufInStream.init(inStream, 4096);
        return bufInStream;
      }
      catch (e) {
        }
    },

		openPath : function(path) 
		{ 
                var file = Components.classes[this.localfileCID]
                                .createInstance(this.localfileIID);
                file.initWithPath(path);
                return file;
		},

        open : function(path) 
        { 
            try 
            {
				return this.openPath(path) ;
            }
            catch(e) {
                return false;
            }
        },
		
		read  : function(file, charset) 
		{
            var siStream;
            var fiStream;
            var data="";
            try {
                fiStream = Components.classes[this.finstreamCID]
                                    .createInstance(this.finstreamIID);
                siStream = Components.classes[this.sinstreamCID]
                                    .createInstance(this.sinstreamIID);
                fiStream.init(file, 1, 0, false);
                siStream.init(fiStream);
                data += siStream.read(-1);
                if (charset) {
                    data = this.toUnicode(charset, data);
                }
                return data;
            }
            catch(e) {
                return false;
            }
            finally {
                if (siStream) { siStream.close(); }
                if (fiStream) { fiStream.close(); }                
            }
		},

    readBytes: function(file) {
        var ios = Components.classes["@mozilla.org/network/io-service;1"].getService(Components.interfaces.nsIIOService);
        var url = ios.newURI(FileIO.path(file), null, null);
        if (!url || !url.schemeIs("file")) { throw "Expected a file URL."; }
        var fp= url.QueryInterface(Components.interfaces.nsIFileURL).file;
        var istream = Components.classes["@mozilla.org/network/file-input-stream;1"].createInstance(Components.interfaces.nsIFileInputStream);
        istream.init(fp, -1, -1, false);
        var bstream = Components.classes["@mozilla.org/binaryinputstream;1"].createInstance(Components.interfaces.nsIBinaryInputStream);
        bstream.setInputStream(istream);
        //var bytes = bstream.readByteArray(bstream.available());
        var bytes = bstream.readBytes(bstream.available());
        return bytes;
    },

    writeBytes: function(fileOut, bytes) {
        var stream = Components.classes["@mozilla.org/network/safe-file-output-stream;1"].createInstance(Components.interfaces.nsIFileOutputStream);
        stream.init(fileOut, 0x04 | 0x08 | 0x20, 0600, 0);
        stream.write(bytes, bytes.length);
        if (stream instanceof Components.interfaces.nsISafeOutputStream) {
            stream.finish();
        } else {
            stream.close();
        }
    },

		write  : function(file, data, mode, charset) 
		{
			var foStream=null;
			var flags;
			try 
			{
				foStream = Components.classes[this.foutstreamCID]
									.createInstance(this.foutstreamIID);
				if (charset && charset.length > 0) {
					data = this.fromUnicode(charset, data);
				}
				flags = 0x02 | 0x08 | 0x20; // wronly | create | truncate
				if (mode == 'a') {
					flags = 0x02 | 0x10; // wronly | append
				}
				foStream.init(file, flags, 0664, 0);
				foStream.write(data, data.length);
				return true;
			}
			catch(e) {
				return false;
			}
			finally {
				if (foStream) foStream.close();
			}
		},

		create : function(file) 
		{
			try 
			{
				file.create(0x00, 0664);
				return true;
			}
			catch(e) {
				return false;
			}
		},

		unlink : function(file) 
		{
			try 
			{
				file.remove(false);
				return true;
			}
			catch(e) {
				return false;
			}
		},

		path   : function(file) {
			try {
				var p=file.path.replace(/\\/g, '\/').replace(/^\s*\/?/, '').replace(/\ /g, '%20');
                return 'file:///'+p;
			}
			catch(e) {
				return false;
			}
		},

		toUnicode   : function(charset, data) 
		{
			try
			{
				var uniConv = Components.classes[this.suniconvCID]
									.createInstance(this.suniconvIID);
				uniConv.charset = charset;
				data = uniConv.ConvertToUnicode(data);
			}
			catch(e) 
			{}
			
			return data;
		},

		fromUnicode : function(charset, data) 
		{
			try 
			{
				var uniConv = Components.classes[this.suniconvCID]
									.createInstance(this.suniconvIID);
				uniConv.charset = charset;
				data = uniConv.ConvertFromUnicode(data);
				// data += uniConv.Finish();
			}
			catch(e) 
			{}

			return data;
		}

	}

	// Basic Directory IO object based on JSLib
	// source code found at jslib.mozdev.org

	// Example use:
	// var dir = DirIO.open('/test');
	// if (dir.exists()) {
	// 	alert(DirIO.path(dir));
	// 	var arr = DirIO.read(dir, true), i;
	// 	if (arr) {
	// 		for (i = 0; i < arr.length; ++i) {
	// 			alert(arr[i].path);
	// 		}
	// 	}
	// }
	// else {
	// 	var rv = DirIO.create(dir);
	// 	alert('Directory create: ' + rv);
	// }

	// ---------------------------------------------
	// ----------------- Nota Bene -----------------
	// ---------------------------------------------
	// Some possible types for get are:
	// 	'ProfD'				= profile
	// 	'DefProfRt'			= user (e.g., /root/.mozilla)
	// 	'UChrm'				= %profile%/chrome
	// 	'DefRt'				= installation
	// 	'PrfDef'				= %installation%/defaults/pref
	// 	'ProfDefNoLoc'		= %installation%/defaults/profile
	// 	'APlugns'			= %installation%/plugins
	// 	'AChrom'				= %installation%/chrome
	// 	'ComsD'				= %installation%/components
	// 	'CurProcD'			= installation (usually)
	// 	'Home'				= OS root (e.g., /root)
	// 	'TmpD'				= OS tmp (e.g., /tmp)

	var DirIO = 
	{
		dirservCID : '@mozilla.org/file/directory_service;1',
		propsIID   : Components.interfaces.nsIProperties,
		fileIID    : Components.interfaces.nsIFile,
		sep        : '/',

        dbgShowTypes : function() {
			var ss= ['ProfD' , 'DefProfRt' , 'UChrm' , 'DefRt', 'PrfDef' , 'ProfLD',
			     'ProfDefNoLoc', 'APlugns', 'AChrom', 'ComsD', 'CurProcD', 
				 'Home', 'TmpD', 'resource:app' ,
				 'cachePDir', 'AppData', 'LocalAppData'
			];
      var out=[]
			for (var i=0; i < ss.length; ++i) {
				var x= DirIO.get(ss[i]);
				if (x) { x = x.path;} else { x="???"; }
				out.push( "" + ss[i] + " = "  + x);
			}
      return out.join('\n');
		},
		
        $ScanDirGetFiles : function ( top)
        {
            var fs, arr= [];
            var dir;
            try
            {
                dir = this.open(top);
                
                if (dir.isDirectory()) {
                    fs= this.read(dir, false);
                }
                if (fs) {
                    for (var i=0; i < fs.length; ++i) {
                        arr.push( fs[i].path);
                    }
                }
            }
            catch (e)
            {
            }

            return arr;
        },
                 
		get    : function(type) 
		{
			try 
			{
				var dir = Components.classes[this.dirservCID]
								.createInstance(this.propsIID)
								.get(type, this.fileIID);
				return dir;
			}
			catch(e) {
				return false;
			}
		},

		open   : function(path) 
		{
			return FileIO.open(path);
		},

		create : function(dir) 
		{
			try 
			{
				dir.create(0x01, 0664);
				return true;
			}
			catch(e) {
				return false;
			}
		},

		read   : function(dir, recursive) 
		{
			var list = new Array();
			var files;

			try 
			{
				if (dir.isDirectory()) {
					if (recursive == null) {
						recursive = false;
					}
					files = dir.directoryEntries;
					list = this._read(files, recursive);
				}
			}
			catch(e)
			{}
			
			return list;
		},

		_read  : function(dirEntry, recursive) 
		{
			var list = new Array();
			var list2;
            var files;
            
			try 
			{
				while (dirEntry.hasMoreElements()) {
					list.push(dirEntry.getNext()
									.QueryInterface(FileIO.localfileIID));
				}
				if (recursive) {
					list2 = new Array();
					for (var i = 0; i < list.length; ++i) {
						if (list[i].isDirectory()) {
							files = list[i].directoryEntries;
							list2 = this._read(files, recursive);
						}
					}
					for (i = 0; i < list2.length; ++i) {
						list.push(list2[i]);
					}
				}
			}
			catch(e) 
			{}

			return list;
		},

		unlink : function(dir, recursive) 
		{
			try 
			{
				if (recursive == null) {
					recursive = false;
				}
				dir.remove(recursive);
				return true;
			}
			catch(e) {
				return false;
			}
		},

		path   : function (dir) 
		{
			return FileIO.path(dir);
		},

		split  : function(str, join) 
		{
			var arr = str.split(/\/|\\/), i;
			str = new String();
			for (i = 0; i < arr.length; ++i) {
				str += arr[i] + ((i != arr.length - 1) ?
										join : '');
			}
			return str;
		},

		join   : function(str, split) 
		{
			var arr = str.split(split), i;
			str = new String();
			for (i = 0; i < arr.length; ++i) {
				str += arr[i] + ((i != arr.length - 1) ?
										this.sep : '');
			}
			return str;
		},

        normalizePath : function (path) 
        {
            var pfx="";

            path= (path || '');

            if (path.indexOf("file:///") == 0) {
                pfx="file:///";
                path=path.slice(8);
            }
            else
            if (path.indexOf("file://") == 0) {
                pfx="file://";
                path=path.slice(7);
            }
            else
            if (path.indexOf("\\\\") == 0) {
                pfx="\\\\";
                path=path.slice(2);
            }

            var a= path.split(/[\\\/]/);
            var s='';
            if (a) {
                for (var i=0; i < a.length; ++i) {
                    if (s.length > 0) {
                        s += DirIO.sep;
                    }
                    s += a[i];
                }
            }
            if (s.length > 0) {
                path = pfx + s;
            }

            return path;
        }

	}

	if (navigator.platform.toLowerCase().indexOf('win') > -1) {
		DirIO.sep = '\\';
	}

}


