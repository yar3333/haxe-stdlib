import stdlib.Regex;
import stdlib.Utf8;

class Test extends haxe.unit.TestCase
{
    static function main()
	{
		var r = new haxe.unit.TestRunner();
		r.add(new Test());
		r.run();
	}
	
	function test_utf8()
	{
		assertEquals("a&amp;b", Utf8.htmlEscape("a&b"));
		assertEquals("abc", Utf8.htmlEscape("abc"));
		assertEquals("ab&quot;c", Utf8.htmlEscape("ab\"c", "\""));
		assertEquals("a\nb", Utf8.htmlEscape("a\nb"));
		assertEquals("a&#xA;b", Utf8.htmlEscape("a\nb", "\n"));
	}
	
	function test_regex()
	{
		var re = new Regex("/a/b/");
		assertEquals("b", re.replace("a"));
		
		var re = new Regex("/(a.*)b/$1c/");
		assertEquals("a123cz", re.replace("a123bz"));
		
		var re = new Regex("/(a.*)b/$1c/");
		assertEquals("a123bcz", re.replace("a123bbz"));
		
		var re = new Regex("/(a.*)b/$1c/r");
		assertEquals("a123ccz", re.replace("a123bbz"));
	}
}