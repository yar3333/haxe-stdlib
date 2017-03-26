package stdlib;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.PositionTools;
import haxe.macro.Type;
using haxe.macro.Tools;
using Lambda;
using StringTools;

class Macro
{
	/**
	 * Load text file as string at compile time. Path to file is related to the source file where macro is called.
	 * Example: `var s = stdlib.Macro.embedFile("test.html");`
	 */
	public static macro function embedFile(filePath:Expr)
	{
		var path = haxe.io.Path.directory(PositionTools.getInfos(Context.currentPos()).file) + "/" + ExprTools.getValue(filePath);
		Context.registerModuleDependency(Context.getLocalModule(), path);
		return sys.FileSystem.exists(path) ? macro $v{sys.io.File.getContent(path)} : macro "";
	}
	
#if macro

	/**
	 * Build macro to inherit static methods from specified class.
	 */
	public static function forwardStaticMethods(classPath:ExprOf<Class<Dynamic>>) : Array<Field>
	{
		var className = classPath.toString();
		var classType = Context.getType(className);
		if (classType != null)
		{
			switch (classType)
			{
				case TInst(t, params):
					return forwardStaticMethodsInner(t.get());
				case _:
					Context.error(className + " must be a class", Context.getLocalClass().get().pos);
			}
		}
		else
		{
			Context.error("Can't find class " + className, Context.getLocalClass().get().pos);
		}
		return null;
	}
	
	/**
	 * Compiler macro to expose all types from package recursively.
	 */
	public static function expose(pack:String, mapToPack:String=null)
	{
		Context.onGenerate(function(types)
		{
			for (type in types)
			{
				switch (type)
				{
					case Type.TInst(t, _): exposeType(pack, mapToPack, t.get());
					case Type.TEnum(t, _): exposeType(pack, mapToPack, t.get());
					case _:
				}
			}
		});
	}
	
	static function forwardStaticMethodsInner(superKlass:ClassType) : Array<Field>
	{
		var fields = Context.getBuildFields();
		
		var superKlassFullName = getClassPath(superKlass.pack, superKlass.name);
		for (superField in superKlass.statics.get())
		{
			if (superField.isPublic && !fields.exists(function(f) return f.name == superField.name))
			{
				switch (superField.kind)
				{
					case FieldKind.FMethod(k):
						//trace("Forward " + superField.name);
						var forward : Field =
						{
							name: superField.name,
							doc: superField.doc,
							access: getAccess(superField),
							kind: FieldType.FFun(getFunction(superKlassFullName, superField)),
							pos: superField.pos,
							meta: []
							
						};
						
						fields.push(forward);
						
					case _:
				}
			}
		}
		
		return fields;
	}
	
	static function getAccess(field:ClassField) : Array<Access>
	{
		var r = [];
		if (field.isPublic) r.push(Access.APublic);
		r.push(Access.AStatic);
		r.push(Access.AInline);
		return r;
	}
	
	static function getFunction(superClassPath:Array<String>, field:ClassField) : Function
	{
		var args = getFunctionArgs(field.type);
		var ret = getFunctionRet(field.type);
		var superCall =
		{
			expr: ECall(macro $p{superClassPath.concat([field.name])}, args.map(function(p) return macro $i{p.name})),
			pos: field.pos
		};
		return
		{
			args: args,
			ret : ret,
			expr : ret != null ? { expr:EReturn(superCall), pos:field.pos } : superCall,
			params: field.params.map(getTypeParamDecl.bind(_, field.pos))
		};
	}
	
	static function getFunctionArgs(type:Type) : Array<FunctionArg>
	{
		switch (type)
		{
			case Type.TFun(args, ret): return args.map(toFunctionArg);
			case Type.TLazy(f): return getFunctionArgs(f());
			case _:
		}
		return null;
	}
	
	static function getFunctionRet(type:Type) : Null<ComplexType>
	{
		switch (type)
		{
			case Type.TFun(args, ret): return TTypeTools.toComplexType(ret);
			case Type.TLazy(f): return getFunctionRet(f());
			case _:
		}
		return null;
	}
	
	static function toFunctionArg(a:{ name:String, opt:Bool, t:Type }) : FunctionArg
	{
		return { name: a.name, opt: a.opt, type: TTypeTools.toComplexType(a.t), value: null };
	}
	
	static function getClassPath(pack:Array<String>, name:String) : Array<String>
	{
		return (pack.length == 0 ? ["std"] : pack).concat([ name ]);
	}
	
	static function getTypeParamDecl(param:TypeParameter, pos:Position) : TypeParamDecl
	{
		return
		{
			name: param.name,
			constraints: typeToConstrains(param.t, pos),
			params: [] //@:optional var params : Array<TypeParamDecl>;
		};
	}
	
	static function typeToConstrains(t:Type, pos:Position) : Array<ComplexType>
	{
		switch (t)
		{
			case Type.TInst(t, params):
				switch (t.get().kind)
				{
					case KTypeParameter(constrains):
						return constrains.map(function(constrain) return constrain.toComplexType());
					case _:
						Context.warning("Unsupported constraint kind: " + t.get().kind, pos);
				}
			case _:
				Context.warning("Unsupported constraint type: " + t, pos);
		}
		return [];
	}
	
	static function exposeType(pack:String, mapToPack:String, type:BaseType)
	{
		var fullName = type.pack.concat([type.name]).join(".");
		if ((fullName + ".").startsWith(pack + "."))
		{
			type.meta.remove(":expose");
			
			if (mapToPack == null)
			{
				type.meta.add(":expose", [], type.pos);
			}
			else
			{
				var newFullName = (mapToPack != "" ? mapToPack + "." : "") + fullName.substring(pack.length + 1);
				type.meta.add(":expose", [ macro $v{newFullName} ], type.pos);
			}
		}
	}
	
#end

}