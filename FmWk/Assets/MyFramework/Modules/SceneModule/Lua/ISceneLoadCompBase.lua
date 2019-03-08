ISceneLoadCompBase = Class.define("ISceneLoadCompBase",BaseModelComp);

function ISceneLoadCompBase:Load(...)
	self.Process = 0;
	self:super(ISceneLoadCompBase,"Load",...);
end

--场景加载进度
function ISceneLoadCompBase:GetProcess()
   return self.Process
end

--场景名称
function ISceneLoadCompBase:GetSceneName()
   return "" 
end 


function ISceneLoadCompBase:LoadScene()
end


function ISceneLoadCompBase:UnloadScene()
end 
