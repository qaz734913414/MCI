--加载桌子上对象管理
function ZhengZhouMJMainView:LoadDeskObjs()
    self.Camera3D = self.Desk:Find("MainCamera")
    self.Camera2D = self.Desk:Find("CameraUI"):GetComponent("Camera")
    self.Camera3DPos = self.Camera3D.position
    self.Camera3DRota = self.Camera3D.rotation
    self.GameId = self.Desk:Find("GameRoot/3DUI/GameId"):GetComponent("Text")
    self.DiFen = self.Desk:Find("GameRoot/3DUI/DiFen"):GetComponent("Text")
    self.DaoJiShiLabel = self.Desk:Find("GameRoot/3DUI/DaoJiShi"):GetComponent("Text")
    self.RoomRule1 = self.Desk:Find("GameRoot/3DUI/RoomRule1"):GetComponent("Text")
    self.RoomRule2 = self.Desk:Find("GameRoot/3DUI/RoomRule2"):GetComponent("Text")
    self.DeskDirection = self.Desk:Find("GameRoot/DeskDirection")
    self.ShaiZiObj = self.Desk:Find("GameRoot/ShaiZi")
    self.ShaiZi_1 = self.ShaiZiObj:Find("saizi1")
    self.ShaiZi_2 = self.ShaiZiObj:Find("saizi2")
end

function ZhengZhouMJMainView:InitDeskObjs()
    self.DaoJiShiLabel.gameObject:SetActive(false);
    self.ShaiZiObj.gameObject:SetActive(false);
    self.Camera3D.position = self.Camera3DPos
    self.Camera3D.rotation = self.Camera3DRota
    self:HideDeskDirectionAnim()
end

--恢复桌子上的信息
function ZhengZhouMJMainView:RestoreGameDeskObj(GameData)
    self.GameId.text = "房间号：" .. tostring(GameData.RoomId)
    self.DiFen.text = "底分：" .. tostring(GameData.RoomRule.EndPointType)
    self.RoomRule2.text = "报听,"..(GameData.RoomRule.GapType == 1 and "断门," or "不断门,")..(GameData.RoomRule.OneDrawType == 1 and "自摸胡" or "点炮胡")
    local RoomRule1Str = (GameData.RoomRule.FankinSevenSub == 1 and "七对," or "")..(GameData.RoomRule.FankinBarRun == 1 and "杠跑," or "")..(GameData.RoomRule.FankinDanker == 1 and "庄家加底," or "")..(GameData.RoomRule.FankinBloomBar == 1 and "杠上开花" or "")
    if RoomRule1Str ~= "" then
        self.RoomRule1.text = "加倍规则("..RoomRule1Str..")"
    end
    self.Camera3D.position = self.Camera3DPos
    self.Camera3D.rotation = self.Camera3DRota   
    self:SetDeskDirection(GameData)
    if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPDRIFTING then --大票中
        self:PlayDaoJiShi(GameData.Table.OperationLeftTime)
    elseif GameData.Table.GameStatus >= ZhengZhouMJ.GameState.STEPNOMAROUT then --行牌中
        self:PlayDaoJiShi(GameData.Table.OperationLeftTime)
        self:PlayDeskDirectionAnim(GameData.Table.CurRunChairId)
    end
end

---------------------------------------------------------------------------------------------------------------------------
--根据自己在服务器上的椅子号来确定桌子上的方位
function ZhengZhouMJMainView:SetDeskDirection(GameData)
    local SChairId = GameData.Table.Players[1].SChairId
    if GameData.GamePlayerNum == 4 then
        if SChairId == 0 then
            self.DeskDirection.rotation = Quaternion.Euler(0,0,0)
            self.PlayerInfos[1].DirectionObj = self.DeskDirection:Find("d")
            self.PlayerInfos[2].DirectionObj = self.DeskDirection:Find("n")
            self.PlayerInfos[3].DirectionObj = self.DeskDirection:Find("x")
            self.PlayerInfos[4].DirectionObj = self.DeskDirection:Find("b")
        elseif SChairId == 1 then
            self.DeskDirection.rotation = Quaternion.Euler(0,90,0)
            self.PlayerInfos[1].DirectionObj = self.DeskDirection:Find("n")
            self.PlayerInfos[2].DirectionObj = self.DeskDirection:Find("x")
            self.PlayerInfos[3].DirectionObj = self.DeskDirection:Find("b")
            self.PlayerInfos[4].DirectionObj = self.DeskDirection:Find("d")
        elseif SChairId == 2 then
            self.DeskDirection.rotation = Quaternion.Euler(0,180,0)
            self.PlayerInfos[1].DirectionObj = self.DeskDirection:Find("x")
            self.PlayerInfos[2].DirectionObj = self.DeskDirection:Find("b")
            self.PlayerInfos[3].DirectionObj = self.DeskDirection:Find("d")
            self.PlayerInfos[4].DirectionObj = self.DeskDirection:Find("n")
        else
            self.DeskDirection.rotation = Quaternion.Euler(0,270,0)
            self.PlayerInfos[1].DirectionObj = self.DeskDirection:Find("b")
            self.PlayerInfos[2].DirectionObj = self.DeskDirection:Find("d")
            self.PlayerInfos[3].DirectionObj = self.DeskDirection:Find("n")
            self.PlayerInfos[4].DirectionObj = self.DeskDirection:Find("x")
        end
    elseif GameData.GamePlayerNum == 3 then
        if SChairId == 0 then
            self.DeskDirection.rotation = Quaternion.Euler(0,0,0)
            self.PlayerInfos[1].DirectionObj = self.DeskDirection:Find("d")
            self.PlayerInfos[2].DirectionObj = self.DeskDirection:Find("n")
            self.PlayerInfos[3].DirectionObj = self.DeskDirection:Find("x")
            self.PlayerInfos[4].DirectionObj = self.DeskDirection:Find("b")

        elseif SChairId == 1 then
            self.DeskDirection.rotation = Quaternion.Euler(0,90,0)
            self.PlayerInfos[1].DirectionObj = self.DeskDirection:Find("n")
            self.PlayerInfos[2].DirectionObj = self.DeskDirection:Find("x")
            self.PlayerInfos[3].DirectionObj = self.DeskDirection:Find("b")
            self.PlayerInfos[4].DirectionObj = self.DeskDirection:Find("d")
        elseif SChairId == 2 then
            self.DeskDirection.rotation = Quaternion.Euler(0,270,0)
            self.PlayerInfos[1].DirectionObj = self.DeskDirection:Find("b")
            self.PlayerInfos[2].DirectionObj = self.DeskDirection:Find("d")
            self.PlayerInfos[3].DirectionObj = self.DeskDirection:Find("n")
            self.PlayerInfos[4].DirectionObj = self.DeskDirection:Find("x")
        end
    elseif GameData.GamePlayerNum == 2 then
        if SChairId == 0 then
            self.DeskDirection.rotation = Quaternion.Euler(0,0,0)
            self.PlayerInfos[1].DirectionObj = self.DeskDirection:Find("d")
            self.PlayerInfos[2].DirectionObj = self.DeskDirection:Find("n")
            self.PlayerInfos[3].DirectionObj = self.DeskDirection:Find("x")
            self.PlayerInfos[4].DirectionObj = self.DeskDirection:Find("b")
        elseif SChairId == 1 then
            self.DeskDirection.rotation = Quaternion.Euler(0,180,0)
            self.PlayerInfos[1].DirectionObj = self.DeskDirection:Find("x")
            self.PlayerInfos[2].DirectionObj = self.DeskDirection:Find("b")
            self.PlayerInfos[3].DirectionObj = self.DeskDirection:Find("d")
            self.PlayerInfos[4].DirectionObj = self.DeskDirection:Find("n")
        end
    end
    self.PlayerInfos[1].DirectionAnim = self.PlayerInfos[1].DirectionObj:GetComponent("Animator")
    self.PlayerInfos[2].DirectionAnim = self.PlayerInfos[2].DirectionObj:GetComponent("Animator")
    self.PlayerInfos[3].DirectionAnim = self.PlayerInfos[3].DirectionObj:GetComponent("Animator")
    self.PlayerInfos[4].DirectionAnim = self.PlayerInfos[4].DirectionObj:GetComponent("Animator")
    self.PlayerInfos[1].DirectionRender = self.PlayerInfos[1].DirectionObj:GetComponent("MeshRenderer")
    self.PlayerInfos[2].DirectionRender = self.PlayerInfos[2].DirectionObj:GetComponent("MeshRenderer")
    self.PlayerInfos[3].DirectionRender = self.PlayerInfos[3].DirectionObj:GetComponent("MeshRenderer")
    self.PlayerInfos[4].DirectionRender = self.PlayerInfos[4].DirectionObj:GetComponent("MeshRenderer")
    self.PlayerInfos[1].DirectionTexture = self.PlayerInfos[1].DirectionTexture and  self.PlayerInfos[1].DirectionTexture or self.PlayerInfos[1].DirectionRender.material.mainTexture
    self.PlayerInfos[2].DirectionTexture = self.PlayerInfos[2].DirectionTexture and  self.PlayerInfos[2].DirectionTexture or self.PlayerInfos[2].DirectionRender.material.mainTexture
    self.PlayerInfos[3].DirectionTexture = self.PlayerInfos[3].DirectionTexture and  self.PlayerInfos[3].DirectionTexture or self.PlayerInfos[3].DirectionRender.material.mainTexture
    self.PlayerInfos[4].DirectionTexture = self.PlayerInfos[4].DirectionTexture and  self.PlayerInfos[4].DirectionTexture or self.PlayerInfos[4].DirectionRender.material.mainTexture
end

--播放操作方向显示动画
function ZhengZhouMJMainView:PlayDeskDirectionAnim(ChairId)
    local PlayerDirectionAnim = function(Id)
        self.PlayerInfos[Id].DirectionAnim:Play("mj_fangxiang_out",-1,0)
        self.PlayerInfos[Id].DirectionAnim.enabled = true
        if self.PlayerInfos[Id].DirectionObj.gameObject.name == "d" then
            self.PlayerInfos[Id].DirectionRender.material.mainTexture =  self.DeskDirectionTextures[1]
        elseif self.PlayerInfos[Id].DirectionObj.gameObject.name == "n" then
            self.PlayerInfos[Id].DirectionRender.material.mainTexture =  self.DeskDirectionTextures[2]
        elseif self.PlayerInfos[Id].DirectionObj.gameObject.name == "x" then
            self.PlayerInfos[Id].DirectionRender.material.mainTexture =  self.DeskDirectionTextures[3]
        else
            self.PlayerInfos[Id].DirectionRender.material.mainTexture =  self.DeskDirectionTextures[4]
        end
    end
    if not self.IsLoadDeskObjs then
        self.DeskDirectionTextures = {}
        self:LoadPrefabObject("fangxiang_C_02_dd", function (sprite1)
            self.DeskDirectionTextures[1] = sprite1
            self:LoadPrefabObject("fangxiang_C_02_nn", function (sprite2)
                self.DeskDirectionTextures[2] = sprite2
                self:LoadPrefabObject("fangxiang_C_02_xx", function (sprite3)
                    self.DeskDirectionTextures[3] = sprite3
                    self:LoadPrefabObject("fangxiang_C_02_bb", function (sprite4)
                        self.DeskDirectionTextures[4] = sprite4
                        self.IsLoadDeskObjs = true
                        PlayerDirectionAnim(ChairId)
                    end)
                end)
            end)
        end)
    else
        PlayerDirectionAnim(ChairId)
    end
end

--隐藏方向动画
function ZhengZhouMJMainView:HideDeskDirectionAnim()
    for i=1,4 do
        if self.PlayerInfos[i].DirectionRender then
            self.PlayerInfos[i].DirectionRender.material.mainTexture =  self.PlayerInfos[i].DirectionTexture 
            self.PlayerInfos[i].DirectionAnim:Play("mj_fangxiang_out",-1,0)
            self.PlayerInfos[i].DirectionAnim:Update(0)
            self.PlayerInfos[i].DirectionAnim.enabled = false
        end
    end
end


--播放色子动画
function ZhengZhouMJMainView:PlayShaiZiAnim(shaizi1,shaizi2)
    self.ShaiZiObj.gameObject:SetActive(true);
    self:PlaySound("mj_effect_SaiZi")
    self.ShaiZiObj:DORotate(Vector3(0, 360*5, 0),2,DG.Tweening.RotateMode.FastBeyond360)
    self.ShaiZi_1:DOLocalRotateQuaternion(self:GetSaiZiQuaternion(shaizi1), 1.5)
    self.ShaiZi_2:DOLocalRotateQuaternion(self:GetSaiZiQuaternion(shaizi2), 1.5)
end

--根据筛子值返回筛子的旋转度
function ZhengZhouMJMainView:GetSaiZiQuaternion(shaziValue)
    if shaziValue == 1 then
        return Quaternion.Euler(270,0,0);
    elseif shaziValue == 2 then
        return Quaternion.Euler(0,0,90);
    elseif shaziValue == 3 then
        return Quaternion.Euler(180,0,0);
    elseif shaziValue == 4 then
        return Quaternion.Euler(0,0,0);
    elseif shaziValue == 5 then
        return Quaternion.Euler(0,0,270);
    else
        return Quaternion.Euler(90,0,0);
    end
end

--影藏塞子
function ZhengZhouMJMainView:HideShaiZi()
    self.ShaiZiObj.gameObject:SetActive(false);
end

--播放倒计时
function ZhengZhouMJMainView:PlayDaoJiShi(_LeftTime)
    self.LeftTime = _LeftTime
    self.DaoJiShiLabel.text = string.format("%02d", self.LeftTime)
    self.DaoJiShiLabel.gameObject:SetActive(true)
    StopCoroutine(self.DaoJiShiCoroutine)
    self.DaoJiShiCoroutine =  StartCoroutine(function()
        while self.LeftTime > 0 do
            WaitForSeconds(1)
            self.LeftTime = self.LeftTime - 1
            self.DaoJiShiLabel.text = string.format("%02d", self.LeftTime)
            -- if self.tempCount <= 2 then
            --      self.iCtrl:PlayEffectSound(10)
            -- end
        end
    end)
end

--隐藏倒计时
function ZhengZhouMJMainView:HideDaoJiShi()
    StopCoroutine(self.DaoJiShiCoroutine)
    self.DaoJiShiLabel.gameObject:SetActive(false)
end

--播放相机特写
function ZhengZhouMJMainView:PlayCameraLaiZiAnim(GameData)
    local Target = self:GetDeskLastMJ():GetObj():GetTransform().position
    local CameraTarget = Target  +  (self.Camera3D.position - Target ).normalized * 3
    self.Camera3D:DOLookAt(Target, 0.5)
    self.Camera3D:DOMove(CameraTarget, 0.5)
    WaitForSeconds(1)
    self:FanLaiZi(GameData)
    WaitForSeconds(0.7)
    self.Camera3D:DORotateQuaternion(self.Camera3DRota,0.5)
    self.Camera3D:DOMove(self.Camera3DPos, 0.5)
end
