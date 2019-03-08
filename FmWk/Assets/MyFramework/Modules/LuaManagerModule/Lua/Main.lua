require "LuaManagerModel.Tools.LuaMath"
require "LuaManagerModel.Tools.LuaString"

require "LuaManagerModel.Config.AppConifg"

require "LuaManagerModel.LuaFaamework.Class"
require "LuaManagerModel.LuaFaamework.BaseModel"
require "LuaManagerModel.LuaFaamework.BaseModelComp"
require "LuaManagerModel.LuaFaamework.BaseModelViewComp"
require "LuaManagerModel.LuaFaamework.LuaGameObject"


--------------------------------启动--------------------------------
function Main()
	print("Lua App启动")
	ManagerModel:StartLuaModel("LuaViewManagerModel",nil,{Vector2.New(1136,640),1});
	ManagerModel:StartLuaModel("LuaSwitchSceneModel",nil,nil);
	ManagerModel:StartModelForName("MyFramework","LuaServiceModel",nil,{"127.0.0.1",1024});
	ManagerModel:StartLuaModel("LuaHomeModel",nil,nil);
end
Main();