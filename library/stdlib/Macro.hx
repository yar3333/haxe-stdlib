package stdlib;

import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
using haxe.macro.Tools;
using Lambda;

class Macro
{
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
	
	/**
	 * Compiler macro to expose all types from package recursively.
	 */
	public static function expose(?pack:String)
	{
		Context.onGenerate(function(types)
		{
			for (t in types)
			{
				var name;
				var b : BaseType;
				
				switch (t)
				{
					case TInst(c, _):
						name = c.toString();
						b = c.get();
						
					case TEnum(e, _):
						name = e.toString();
						b = e.get();
						
					default:
						continue;
				}
				
				var p = b.pack.join(".");
				if (pack == null || pack == "" || p == pack || name == pack || StringTools.startsWith(p, pack + "."))
				{
					b.meta.add(":expose", [], Context.currentPos());
				}
			}
		});
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
}