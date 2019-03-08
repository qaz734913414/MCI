--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
if jit then		
	if jit.opt then		
		jit.opt.start(3)				
	end		
	
	print("ver"..jit.version_num.." jit: ", jit.status())
	print(string.format("os: %s, arch: %s", jit.os, jit.arch))
end

if DebugServerIp then  
  require("mobdebug").start(DebugServerIp)
end

require "LuaManagerModel.ToLua.misc.functions"
Mathf		= require "LuaManagerModel.ToLua.UnityEngine.Mathf"
Vector3 	= require "LuaManagerModel.ToLua.UnityEngine.Vector3"
Quaternion	= require "LuaManagerModel.ToLua.UnityEngine.Quaternion"
Vector2		= require "LuaManagerModel.ToLua.UnityEngine.Vector2"
Vector4		= require "LuaManagerModel.ToLua.UnityEngine.Vector4"
Color		= require "LuaManagerModel.ToLua.UnityEngine.Color"
Ray			= require "LuaManagerModel.ToLua.UnityEngine.Ray"
Bounds		= require "LuaManagerModel.ToLua.UnityEngine.Bounds"
RaycastHit	= require "LuaManagerModel.ToLua.UnityEngine.RaycastHit"
Touch		= require "LuaManagerModel.ToLua.UnityEngine.Touch"
LayerMask	= require "LuaManagerModel.ToLua.UnityEngine.LayerMask"
Plane		= require "LuaManagerModel.ToLua.UnityEngine.Plane"
Time		= reimport "LuaManagerModel.ToLua.UnityEngine.Time"

list		= require "LuaManagerModel.ToLua.list"
utf8		= require "LuaManagerModel.ToLua.misc.utf8"

require "LuaManagerModel.ToLua.event"
require "LuaManagerModel.ToLua.typeof"
require "LuaManagerModel.ToLua.slot"
require "LuaManagerModel.ToLua.System.Timer"
require "LuaManagerModel.ToLua.System.coroutine"
require "LuaManagerModel.ToLua.System.ValueType"
require "LuaManagerModel.ToLua.System.Reflection.BindingFlags"

require "LuaManagerModel.ToLua.protobuf.wire_format"
require "LuaManagerModel.ToLua.protobuf.type_checkers"
require "LuaManagerModel.ToLua.protobuf.encoder"
require "LuaManagerModel.ToLua.protobuf.decoder"
require "LuaManagerModel.ToLua.protobuf.listener"
require "LuaManagerModel.ToLua.protobuf.containers"
require "LuaManagerModel.ToLua.protobuf.descriptor"
require "LuaManagerModel.ToLua.protobuf.text_format"
require "LuaManagerModel.ToLua.protobuf.protobuf"