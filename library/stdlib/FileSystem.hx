package stdlib;

#if sys

#if !macro

@:build(stdlib.Macro.forwardStaticMethods(sys.FileSystem))
class FileSystem 
{
	/**
		Delete a given file if it is exists.
	*/
	public static function deleteFile(path:String) : Void
	{
		if (exists(path))
		{
			sys.FileSystem.deleteFile(path);
		}
	}
	
	/**
		Delete a given directory recursively.
	*/
	public static function deleteDirectory(path:String) : Void
	{
		if (exists(path))
		{
			for (file in readDirectory(path))
			{
				var s = path + "/" + file;
				if (isDirectory(s))
				{
					deleteDirectory(s);
				}
				else
				{
					deleteFile(s);
				}
			}
			sys.FileSystem.deleteDirectory(path);
		}
	}
}

#else

typedef FileSystem = sys.FileSystem;

#end

#end