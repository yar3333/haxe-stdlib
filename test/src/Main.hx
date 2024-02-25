import utest.Assert;
import stdlib.Regex;
//import stdlib.Utf8;
using stdlib.Lambda;
using js.lib.HaxeIterator;

class Main
{
    static function main()
    {
		var runner = new utest.Runner();
		runner.addCase(new MainTest());
		        
        utest.ui.Report.create(runner);
        runner.run();
    }
}

class MainTest extends utest.Test
{
	/*function test_utf8()
	{
		Assert.equals("a&amp;b", Utf8.htmlEscape("a&b"));
		Assert.equals("abc", Utf8.htmlEscape("abc"));
		Assert.equals("ab&quot;c", Utf8.htmlEscape("ab\"c", "\""));
		Assert.equals("a\nb", Utf8.htmlEscape("a\nb"));
		Assert.equals("a&#xA;b", Utf8.htmlEscape("a\nb", "\n"));
	}*/
	
	function test_regex()
	{
		var re = new Regex("/a/b/");
		Assert.equals("b", re.replace("a"));
		
		var re = new Regex("/(a.*)b/$1c/");
		Assert.equals("a123cz", re.replace("a123bz"));
		
		var re = new Regex("/(a.*)b/$1c/");
		Assert.equals("a123bcz", re.replace("a123bbz"));
		
		var re = new Regex("/(a.*)b/$1c/r");
		Assert.equals("a123ccz", re.replace("a123bbz"));
	}

    function test_lambda()
    {
        var arr = [
            { key:"k0", value:{ a:"a0", b:"b0" } },
            { key:"k1", value:{ a:"a11", b:"b11" } },
            { key:"k1", value:{ a:"a12", b:"b12" } },
            { key:"k2", value:{ a:"a2", b:"b2" } },
        ];

        var map = arr.toMapMany(item -> item.key, item -> item.value);
        Assert.equals(3, HaxeIterator.iterator(map.keys()).count());
        Assert.isTrue(map.has("k0"));
        Assert.isTrue(map.has("k1"));
        Assert.isTrue(map.has("k2"));
        Assert.isTrue(map.get("k1").length == 2);
        Assert.isTrue(map.get("k1")[0].b == "b11");
        Assert.isTrue(map.get("k1")[1].b == "b12");
    }
}