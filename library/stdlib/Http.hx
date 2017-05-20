package stdlib;

#if sys
import sys.net.Host;
import sys.net.Socket;
#end

private typedef FileInfo =
{
	var param : String;
	var filename : String;
	var io : haxe.io.Input;
	var size : Int;
	var mimeType : String;
}

/**
 * Extension of standard `haxe.Http` class.
 * Can post many files.
 */
class Http extends haxe.Http
{
#if sys
	public static var PROXY(get, set) : { host : String, port : Int, auth : { user : String, pass : String } };
	static inline function get_PROXY() return haxe.Http.PROXY;
	static inline function set_PROXY(v) return haxe.Http.PROXY = v;
#end

#if (!flash && !nodejs)
	public static inline function requestUrl( url : String ) : String return haxe.Http.requestUrl(url);
#end
	
#if sys
	var files = new Array<FileInfo>();
	
	public function addFile(argname:String, filename:String, file:haxe.io.Input, size:Int, mimeType="application/octet-stream" )
	{
		files.push({ param:argname, filename:filename, io:file, size:size, mimeType:mimeType });
	}
	
	override public function customRequest(post:Bool, api:haxe.io.Output, ?sock:sys.net.Socket, ?method:String)
	{
		this.responseData = null;
		
		var url_regexp = ~/^(https?:\/\/)?([a-zA-Z\.0-9_-]+)(:[0-9]+)?(.*)$/;
		if (!url_regexp.match(url)) { onError("Invalid URL"); return; }
		
		var secure = url_regexp.matched(1) == "https://";
		
		if (sock == null)
		{
			if (secure)
			{
				#if php
				sock = new php.net.SslSocket();
				#elseif java
				sock = new java.net.SslSocket();
				#elseif (!no_ssl && (hxssl || hl || cpp || (neko && !(macro || interp))))
				sock = new sys.ssl.Socket();
				#else
				throw "Https is only supported with -lib hxssl";
				#end
			}
			else
			{
				sock = new Socket();
			}
		}
		
		var host = url_regexp.matched(2);
		var portString = url_regexp.matched(3);
		var request = url_regexp.matched(4);
		if (request == "") request = "/";
		var port = portString == null || portString == "" ? (secure ? 443 : 80) : Std.parseInt(portString.substr(1, portString.length - 1));
		
		if (file == null && files.length == 0) customRequestSimple(post, api, sock, method, host, port, request);
		else                                   customRequestMultipart(api, sock, method, host, port, request);
	}
	
	function customRequestSimple(post:Bool, api:haxe.io.Output, sock:sys.net.Socket, method:String, host:String, port:Int, request:String)
	{
		var boundary = null;
		var uri = null;
		for (p in params)
		{
			if (uri == null) uri = "";
			else             uri += "&";
			uri += StringTools.urlEncode(p.param) + "=" + StringTools.urlEncode(p.value);
		}
		
		var b = new StringBuf();
		b.add(method != null ? method + " " : (post ? "POST " : "GET "));
		
		writeProxyToStringBuf(host, port, b);
		
		b.add(request);
		
		if (!post && uri != null)
		{
			if (request.indexOf("?",0) >= 0) b.add("&");
			else                             b.add("?");
			b.add(uri);
		}
		b.add(" HTTP/1.1\r\nHost: " + host + "\r\n");
		
		if (postData != null)
		{
			b.add("Content-Length: " + postData.length + "\r\n");
		}
		else
		if (post && uri != null)
		{
			if (!Lambda.exists(headers, function(h) return h.header == "Content-Type"))
			{
				b.add("Content-Type: application/x-www-form-urlencoded");
				b.add("\r\n");
			}
			b.add("Content-Length: "+uri.length+"\r\n");
		}
		b.add("Connection: close\r\n");
		
		writeHeadersToStringBuf(b);
		
		b.add("\r\n");
		
		if (postData != null)
		{
			b.add(postData);
		}
		else
		if (post && uri != null)
		{
			b.add(uri);
		}
		
		try
		{
			if (Http.PROXY != null) sock.connect(new Host(Http.PROXY.host), Http.PROXY.port);
			else                    sock.connect(new Host(host), port);
			
			sock.write(b.toString());
			
			readHttpResponse(api,sock);
			
			sock.close();
		}
		catch (e:Dynamic)
		{
			try sock.close() catch (_:Dynamic) {}
			onError(Std.string(e));
		}
	}
	
	function customRequestMultipart(api:haxe.io.Output, sock:sys.net.Socket, method:String, host:String, port:Int, request:String)
	{
		var b = new StringBuf();
		b.add(method != null ? method + " " : "POST ");
		writeProxyToStringBuf(host, port, b);
		b.add(request);
		b.add(" HTTP/1.1\r\nHost: " + host + "\r\n");
		
		if (postData != null)
		{
			b.add("Content-Length: " + postData.length + "\r\n");
			b.add("Connection: close\r\n");
			writeHeadersToStringBuf(b);
			b.add("\r\n");
			b.add(postData);
			
			wrapSending(api, sock, host, port, function()
			{
				sock.write(b.toString());
			});
		}
		else
		{
			var boundary = generateBoundary();
			
			var paramsData = new StringBuf();
			for (p in params)
			{
				paramsData.add("--");
				paramsData.add(boundary);
				paramsData.add("\r\n");
				
				paramsData.add('Content-Disposition: form-data; name="');
				paramsData.add(p.param);
				paramsData.add('"');
				paramsData.add("\r\n");
				paramsData.add("\r\n");
				paramsData.add(p.value);
				paramsData.add("\r\n");
			}
			
			var files = (file != null ? [file] : []).concat(this.files);
			var totalFileSize = 0;
			var filePrefixes = [];
			for (file in files)
			{
				var prefix = getFilePrefix(file, boundary);
				filePrefixes.push(prefix);
				totalFileSize += prefix.length + file.size;
			}
			
			b.add("Content-Type: multipart/form-data; boundary=");
			b.add(boundary);
			b.add("\r\n");
			b.add("Content-Length: ");
			b.add(paramsData.length + totalFileSize + boundary.length + "\r\n----".length);
			b.add("\r\n");
			b.add("Connection: close\r\n");
			writeHeadersToStringBuf(b);
			b.add("\r\n");
			b.add(paramsData);
			
			wrapSending(api, sock, host, port, function()
			{
				sock.write(b.toString());
				
				for (i in 0...files.length)
				{
					sock.write(filePrefixes[i]);
					writeFileToSocket(files[i], sock);
				}
				
				sock.write("\r\n");
				sock.write("--");
				sock.write(boundary);
				sock.write("--");
			});
		}
	}
	
	function wrapSending(api:haxe.io.Output, sock:sys.net.Socket, host:String, port:Int, send:Void->Void)
	{
		try
		{
			if (Http.PROXY != null) sock.connect(new Host(Http.PROXY.host), Http.PROXY.port);
			else                    sock.connect(new Host(host), port);
			
			send();
			
			readHttpResponse(api, sock);
			
			sock.close();
		}
		catch (e:Dynamic)
		{
			try sock.close() catch (_:Dynamic) {}
			onError(Std.string(e));
		}
	}
	
	function writeProxyToStringBuf(host:String, port:Int, b:StringBuf)
	{
		if (Http.PROXY != null)
		{
			b.add("http://");
			b.add(host);
			if (port != 80)
			{
				b.add(":");
				b.add(port);
			}
		}		
	}
	
	function writeHeadersToStringBuf(b:StringBuf)
	{
		for (h in headers)
		{
			b.add(h.header);
			b.add(": ");
			b.add(h.value);
			b.add("\r\n");
		}
	}
	
	function generateBoundary() : String
	{
		var boundary = Std.string(Std.random(1000))+Std.string(Std.random(1000))+Std.string(Std.random(1000))+Std.string(Std.random(1000));
		while (boundary.length < 38) boundary = "-" + boundary;
		return boundary;
	}
	
	function getFilePrefix(file:FileInfo, boundary:String) : String
	{
		var b = new StringBuf();
		
		b.add("--");
		b.add(boundary);
		b.add("\r\n");
		
		b.add('Content-Disposition: form-data; name="');
		b.add(file.param);
		b.add('"; filename="');
		b.add(file.filename);
		b.add('"');
		b.add("\r\n");
		b.add("Content-Type: " + file.mimeType + "\r\n\r\n");
		
		return b.toString();
	}
	
	function writeFileToSocket(file:FileInfo, sock:sys.net.Socket)
	{
		var bufsize = 4096;
		var buf = haxe.io.Bytes.alloc(bufsize);
		while (file.size > 0)
		{
			var size = file.size > bufsize ? bufsize : file.size;
			var len = 0;
			try len = file.io.readBytes(buf, 0, size)
			catch (e:haxe.io.Eof) break;
			sock.output.writeFullBytes(buf,0,len);
			file.size -= len;
		}
	}
#end
}
