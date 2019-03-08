local SceneChedulerComp = Class.define("SceneChedulerComp",BaseModelComp)

function SceneChedulerComp:Load(...)
    self.LoadSceneProgress = 0
    self.CurrSceneLoadComp = nil
    self:super(SceneChedulerComp,"Load",...);
    self:LoadEnd()
end

function SceneChedulerComp:ChangeScene(SceneLoadComp)
    self.LoadSceneProgress = 0;
    StartCoroutine(self.ChangeSceneCoroutine,self,SceneLoadComp);
end

function SceneChedulerComp:ChangeSceneCoroutine(SceneLoadComp)
    self.MyModel:StartLoadChanage();
    Yield(self:UnCurrScene(0,0.3))
    Yield(self:LoadScene(SceneLoadComp:GetSceneName(), 0.3,0.7));
    Yield(self:LoadSceneControl(SceneLoadComp, 0.7,1));
    self.MyModel:EndLoadChanage();
end

--卸载前一个场景
function SceneChedulerComp:UnCurrScene(Start ,Target)
    local currProcess = 0;
    local toProcess = 0;
    if self.CurrSceneLoadComp then
        StartCoroutine(self.CurrSceneLoadComp.UnloadScene,self.CurrSceneLoadComp);
        while (self.LoadSceneProgress < Target)
        do
            toProcess = math.ceil(self.CurrSceneLoadComp:GetProcess() * 100);
            while (currProcess < toProcess)
            do
                currProcess = currProcess + 1
                self.LoadSceneProgress = LuaMath.Lerp(Start, Target, currProcess / 100);
                self.MyModel:UpdataProgress(self.LoadSceneProgress,"正在卸载当前场景...");
                WaitForEndOfFrame();
            end
            WaitForEndOfFrame();
        end
    else
        toProcess = 100;
        while (self.LoadSceneProgress < Target)
        do
            while (currProcess < toProcess)
            do
                currProcess = currProcess+1;
                self.LoadSceneProgress = LuaMath.Lerp(Start, Target, currProcess / 100);
                self.MyModel:UpdataProgress(self.LoadSceneProgress,"正在卸载当前场景...");
                WaitForEndOfFrame();
            end
            WaitForEndOfFrame();
        end
    end
end

--跳转前一个场景
function SceneChedulerComp:LoadScene(sceneName, Start, Target)
    local currProcess = 0;
    local toProcess = 0;
    local op = SceneManager.LoadSceneAsync(sceneName);
    op.allowSceneActivation = false;
    while (op.progress < 0.89)
    do
        toProcess = math.ceil(op.progress * 100);
        while (currProcess < toProcess)
        do
            currProcess = currProcess + 1;
            self.LoadSceneProgress = LuaMath.Lerp(Start, Target, currProcess / 100);
            self.MyModel:UpdataProgress(self.LoadSceneProgress,"正在跳转下一个场景...");
            WaitForEndOfFrame();
        end
        WaitForEndOfFrame();
    end
    toProcess = 100;
    while (currProcess < toProcess)
    do
        currProcess = currProcess +1;
        self.LoadSceneProgress = LuaMath.Lerp(Start, Target, currProcess / 100);
        self.MyModel:UpdataProgress(self.LoadSceneProgress,"准备进入下一个场景...");
        WaitForEndOfFrame();
    end
    op.allowSceneActivation = true;
    Yield(op);
end
--加载当前场景
function SceneChedulerComp:LoadSceneControl(SceneLoadComp, Start, Target)
    self.CurrSceneLoadComp = SceneLoadComp;
    local currProcess = 0;
    local toProcess = 0;
    if self.CurrSceneLoadComp then
        StartCoroutine(self.CurrSceneLoadComp.LoadScene,self.CurrSceneLoadComp);
        while (self.LoadSceneProgress < Target)
        do
            toProcess = math.ceil(self.CurrSceneLoadComp:GetProcess() * 100);
            while (currProcess < toProcess)
            do
                currProcess = currProcess + 1;
                self.LoadSceneProgress = LuaMath.Lerp(Start, Target, currProcess / 100);
                self.MyModel:UpdataProgress(self.LoadSceneProgress,"场景准备中...");
                WaitForEndOfFrame();
            end
            WaitForEndOfFrame();
        end
    else
        toProcess = 100;
        while (self.LoadSceneProgress < Target)
        do
            while (currProcess < toProcess)
            do
                currProcess = currProcess + 1;
                self.LoadSceneProgress = LuaMath.Lerp(Start, Target, currProcess / 100);
                self.MyModel:UpdataProgress(self.LoadSceneProgress,"场景加载完毕");
                WaitForEndOfFrame();
            end
            WaitForEndOfFrame();
        end
    end
end

return SceneChedulerComp;