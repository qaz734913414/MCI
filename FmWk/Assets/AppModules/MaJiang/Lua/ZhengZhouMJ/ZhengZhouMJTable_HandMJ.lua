function ZhengZhouMJMainView:LoadHandMJ()
    local deltaX = -0.3
    self.HandMJ = {}
    for i=1,4 do
        self.HandMJ[i] = {}
        self.HandMJ[i].Prent = self.Desk:Find("GameRoot/GameHandMJ/Player" .. tostring(i))
        self.HandMJ[i].MJs = {}
        self.HandMJ[i].Pos = {}
        for j=1,13 do
            local obj = self:InstantionGameObject(self.MJPrefab, self.HandMJ[i].Prent, tostring(j))
            local MJ = MJCard.new(0,obj);
            local Pos = Vector3(deltaX*(j-1), 0, 0)
            obj:SetLocalPosition(Pos.x,Pos.y,Pos.z)
            obj:GetTransform().localEulerAngles = Vector3(0,0,0)
            if i == 1 then
                MJ:SetLayer("2D");
                MJ:SetSeat(Pos,false)
                obj:AddComponent(typeof(UnityEngine.BoxCollider)).size = Vector3(0.3,0.4,0.2)
                
                obj:SetOnDragStart(function (_obj,_evt,_go,_args)
                    self:HandMJStartDrag(MJ)
                end)

                obj:SetOnDarg(function (_obj,_evt, _go ,_data, _args)
                    self:HandMJOnDrag(MJ,_data)
                end)

                obj:SetOnDragEnd(function (_obj,_evt, _go, _args)
                    self:HandMJEndDrag(MJ)
                end)
                
                obj:Set3DOnClick(function (evt, go, args)
                    self:HandMJOnClick(MJ)
                end)
            else
                MJ:SetLayer("3D");
            end
            MJ:AddAnimator(self.MJAnimController)
            table.insert(self.HandMJ[i].MJs,MJ)
            table.insert(self.HandMJ[i].Pos,Pos)
        end
        --摸牌
        local mpobj = self:InstantionGameObject(self.MJPrefab, self.HandMJ[i].Prent , tostring("14"))
        local mpMJ = MJCard.new(0,mpobj);
        local mpPos = self.HandMJ[i].Prent:Find("MoPaiPoint").localPosition;
        mpobj:SetLocalPosition(mpPos.x,mpPos.y,mpPos.z)
        mpobj:GetTransform().localEulerAngles = Vector3(0,0,0)
        if i == 1 then
            mpMJ:SetLayer("2D");
            mpMJ:SetSeat(mpPos,false)
            mpobj:AddComponent(typeof(UnityEngine.BoxCollider)).size = Vector3(0.3,0.4,0.2)
            mpobj:SetOnDragStart(function (_obj,_evt,_go,_args)
                self:HandMJStartDrag(mpMJ)
            end)
            mpobj:SetOnDarg(function (_obj,_evt, _go ,_data, _args)
                self:HandMJOnDrag(mpMJ,_data)
            end)
            mpobj:SetOnDragEnd(function (_obj,_evt, _go, _args)
                self:HandMJEndDrag(mpMJ)
            end)
            mpobj:Set3DOnClick(function (evt, go, args)
                self:HandMJOnClick(mpMJ)
            end)
        else
            mpMJ:SetLayer("3D");
        end
        mpMJ:AddAnimator(self.MJAnimController)
        table.insert(self.HandMJ[i].MJs,mpMJ)
        table.insert(self.HandMJ[i].Pos,mpPos)
    end
    self.IsCanChuPai = true
    self.SelectMJ = nil         --前端先记录准备打出什么牌 确保出牌消息影藏的牌是玩家点的牌
    self.ReadyOutMJ = nil       --前端先记录准备打出什么牌 确保出牌消息影藏的牌是玩家点的牌
    self.DargMJ = nil           --拖拽麻将
    self.IsDargMJCanOut = false --拖拽牌是否可以打出
end

--初始化手牌
function ZhengZhouMJMainView:InitHandMJ()
    for i=1,4 do
        for j,v in ipairs(self.HandMJ[i].MJs) do
            if i == 1 then
                v:SetLayer("2D");
            end
            v:SetTing(false)
            v:Hide()
        end
    end
    self.IsCanChuPai = true
end

--恢复手牌
function ZhengZhouMJMainView:RestoreGameHandMJ(GameData)
    for i=1,4 do
        self:UpDataHandMJ(i,GameData)
    end
    self.IsCanChuPai = true
    self.SelectMJ = nil         --前端先记录准备打出什么牌 确保出牌消息影藏的牌是玩家点的牌
    self.ReadyOutMJ = nil       --前端先记录准备打出什么牌 确保出牌消息影藏的牌是玩家点的牌
    self.DargMJ = nil           --拖拽麻将
    self.IsDargMJCanOut = false --拖拽牌是否可以打出
end


function ZhengZhouMJMainView:UpDataHandMJ(ChairId,GameData)
    for i,v in ipairs(self.HandMJ[ChairId].MJs) do
        if i <= #GameData.Table.Players[ChairId].HandMJ then
            local MJValue = GameData.Table.Players[ChairId].HandMJ[i]
            v:SetValue(MJValue)
            v:SetLaiZi(ZhengZhouMJ.IsLaiZi(MJValue))
            v:SetTing(GameData.Table.Players[ChairId].IsTing)
            v:PlayAnim("Default")
            v:Show()
        else
            v:Hide()
        end
    end
    self:StortHandMJ(ChairId)
    for i,v in ipairs(self.HandMJ[ChairId].MJs) do
        v:SetSeat(self.HandMJ[ChairId].Pos[i],false)
        v:DOLocalMove(self.HandMJ[ChairId].Pos[i], 0)
    end
    if GameData.Table.Players[ChairId].MoPaiMJ then
        self.HandMJ[ChairId].MJs[14]:SetValue(GameData.Table.Players[ChairId].MoPaiMJ)
        self.HandMJ[ChairId].MJs[14]:SetLaiZi(ZhengZhouMJ.IsLaiZi(GameData.Table.Players[ChairId].MoPaiMJ))
        self.HandMJ[ChairId].MJs[14]:SetTing(false)
        self.HandMJ[ChairId].MJs[14]:Show()
        self.HandMJ[ChairId].MJs[14]:PlayAnim("Default")
    end
end

-----------------------------------------------游戏业务逻辑-----------------------------------------

--发牌
function ZhengZhouMJMainView:HandFaPai(ChairId,Index,Value)
    self.HandMJ[ChairId].MJs[Index]:SetValue(Value)
    self.HandMJ[ChairId].MJs[Index]:Show()
    self.HandMJ[ChairId].MJs[Index]:PlayAnim("MJFaPai")
end

--发完牌之后的排序动画
function ZhengZhouMJMainView:HandFaPaiStorAnim(GameData)
    for i,v in ipairs(self.HandMJ[1].MJs) do
        self.HandMJ[1].MJs[i]:PlayAnim("HandStorMJ")
    end
    WaitForSeconds(0.1)
    for i,v in ipairs(GameData.Table.Players) do
        if v.PlayerInfo.UserID ~= 0 then 
            ZhengZhouMJ.SortHandMJ(i)   --排序自己的手牌
            self:UpDataHandMJ(i,GameData)
        end
    end
    self:ClearCanTingHandMJ()
    self:ShowCanTingHandMJ(GameData)
end


--摸牌
function ZhengZhouMJMainView:HandMoPai(ChairId,Value)
    self.IsCanChuPai = true
    self.HandMJ[ChairId].MJs[14]:SetValue(Value)
    self.HandMJ[ChairId].MJs[14]:SetTing(false)
    self.HandMJ[ChairId].MJs[14]:SetSelect(false)
    self.HandMJ[ChairId].MJs[14]:SetLaiZi(ZhengZhouMJ.IsLaiZi(Value))
    self.HandMJ[ChairId].MJs[14]:Show()
    self.HandMJ[ChairId].MJs[14]:PlayAnim("MJFaPai")
    self:ClearCanTingHandMJ()
end



--显示可停牌
function ZhengZhouMJMainView:ShowCanTingHandMJ(GameData)
    if GameData.Table.Players[1].CanHuData and #GameData.Table.Players[1].CanHuData > 0 then   --有可听牌
        for i1,v1 in ipairs(GameData.Table.Players[1].CanHuData) do
            for i2,v2 in ipairs(self.HandMJ[1].MJs) do
                if v2:IsShow() and v1.OutMJ == v2:GetValue() then
                    v2:ShowCanTing(true)
                end
            end
        end
    end
end

--清理可听标签
function ZhengZhouMJMainView:ClearCanTingHandMJ()
    for i2,v2 in ipairs(self.HandMJ[1].MJs) do
        v2:ShowCanTing(false)
    end
end

function ZhengZhouMJMainView:HandMJOnHover(MJ)
    MJ:SetSelect(not MJ:GetSelect())
end

--开始拖动
function ZhengZhouMJMainView:HandMJStartDrag(MJ)
    if not self.OnFaPaiAnim and MJ:IsShow() and not self.IsHaveTing and not MJ:GetTing() then
        self.DargMJ = MJ
    end
end

--拖动中
function ZhengZhouMJMainView:HandMJOnDrag(MJ,Data)
    if self.DargMJ == nil or self.DargMJ ~= MJ then return end
    local mjTrans = MJ:GetObj():GetTransform()
    local currPosition = self.Camera2D:WorldToScreenPoint(mjTrans.position);
    currPosition = currPosition + Vector3(Data.x,Data.y,0)
    local newPosition = self.Camera2D:ScreenToWorldPoint(currPosition);
    MJ:GetObj():GetTransform().position = newPosition
    local localPosition = MJ:GetObj():GetTransform().localPosition
    MJ:GetObj():GetTransform().localPosition = Vector3(localPosition.x,localPosition.y,0)

end

--拖动结束
function ZhengZhouMJMainView:HandMJEndDrag(MJ)
    if self.DargMJ == nil or self.DargMJ ~= MJ then return end
    self.IsDargMJCanOut = MJ:GetObj():GetTransform().localPosition.y < -0.5
    if self.IsDargMJCanOut and not self.OnFaPaiAnim and MJ:IsShow() and not self.IsHaveTing and self.IsCanChuPai and ZhengZhouMJ.IsCanOutMJ() then --可出牌逻辑判断
        self.ReadyOutMJ = MJ
        self.ReadyOutMJ:Hide()
        ZhengZhouMJ.SendChuPai(MJ:GetValue())
        self.IsCanChuPai = false
        if self.SelectMJ then
            self.SelectMJ:SetSelect(false)
            self.SelectMJ = nil
        end
        self:ClearRelationMJ()
        self:ShowPlayerTingDataView(nil,false)
    end
    MJ:ReturnTo()   
    self.DargMJ = nil   
end

--麻将点击
function ZhengZhouMJMainView:HandMJOnClick(MJ)
    if not self.OnFaPaiAnim and MJ:IsShow() and not self.IsHaveTing then   --发牌动画完毕才可出牌  听操作按钮不可点
        self:PlaySound("mj_effect_xuanpai")
        if not MJ:GetSelect() then                                  --选中状态
            if self.SelectMJ then
                self.SelectMJ:SetSelect(false)
                self:ClearRelationMJ()
                self:ShowPlayerTingDataView(nil,false)
            end
            MJ:SetSelect(true)
            self:FindRelationMJ(MJ:GetValue())
            self.SelectMJ = MJ
            local IsTingMJ,HuData = ZhengZhouMJ.IsOutCanHuMJ(MJ:GetValue())
            if IsTingMJ  then
                if not HuData then
                    ZhengZhouMJ.SendCanHuDetailedQuery(MJ:GetValue())
                else
                    self:ShowPlayerTingDataView(HuData,false)
                end
            end
        else
            if self.IsCanChuPai and ZhengZhouMJ.IsCanOutMJ()  then
                if not MJ:GetTing() then
                    self.ReadyOutMJ = MJ
                    self.ReadyOutMJ:Hide()
                    ZhengZhouMJ.SendChuPai(MJ:GetValue())
                    self.IsCanChuPai = false
                    self.SelectMJ:SetSelect(false)
                    self.SelectMJ = nil
                    self:ClearRelationMJ()
                    self:ShowPlayerTingDataView(nil,false)
                else
                    print("听牌不可出")
                end
            else
                MJ:SetSelect(false)
                self.SelectMJ = nil
                self:ClearRelationMJ()
                self:ShowPlayerTingDataView(nil,false)
            end
        end
    end
end

--出牌
function ZhengZhouMJMainView:HandMJChuPai(ChairId,MJ,GameData)
    print("玩家出牌动画开始 ChairId = "..ChairId.."MJ = "..tostring(MJ))
    if ChairId == 1 and self.ReadyOutMJ and self.ReadyOutMJ:GetValue() == MJ then
        self:PlaySound_ChuPai(ChairId,self.ReadyOutMJ:GetCValue(),GameData)
        self.ReadyOutMJ:SetSelect(false)
        self.ReadyOutMJ = nil 
        self:ClearCanTingHandMJ()
        if self.DargMJ then
            self.DargMJ:ReturnTo()  
            self.DargMJ = nil 
        end 
    else
        if ChairId == 1 then         --自己点了牌，但是服务器可能已经帮你出牌了，这个是否需要做恢复处理
            if self.ReadyOutMJ then
                self.ReadyOutMJ:Show()
                self.ReadyOutMJ:SetSelect(false)
                self.ReadyOutMJ = nil
            end
            self:ClearCanTingHandMJ()
            if self.DargMJ then
                self.DargMJ:ReturnTo()    
                self.DargMJ = nil 
            end 
        end
        local MJValua = MJ
        local n = 0;
        for i=14,1,-1 do
            if self.HandMJ[ChairId].MJs[i]:IsShow() and self.HandMJ[ChairId].MJs[i]:GetValue() == MJValua then
                self.HandMJ[ChairId].MJs[i]:Hide()
                n = n + 1
                self:PlaySound_ChuPai(ChairId,self.HandMJ[ChairId].MJs[i]:GetCValue(),GameData)
            end
            if n == 1 then
                break 
            end
        end
    end
    print("玩家出牌动画开始 结束")
    self:MoveSortHandMJ(ChairId,GameData)
end

--碰牌
function ZhengZhouMJMainView:HandMJPengPai(ChairId,MJ,GameData)
    local MJValua = MJ
    local n = 0;
    for i,v in ipairs(self.HandMJ[ChairId].MJs) do
        if v:IsShow() and v:GetValue() == MJValua then
            v:Hide()
            n = n + 1
        end
        if n == 2 then
            break 
        end
    end
    self:MoveSortHandMJ(ChairId,GameData)
    if ChairId == 1 and self.SelectMJ then         --清除选中的麻将
        self.SelectMJ:SetSelect(false)
        self.SelectMJ = nil
        self:ClearRelationMJ()
    end
    self.IsCanChuPai = true
end

--明杠
function ZhengZhouMJMainView:HandMJMGang(ChairId,MJ,GameData)
    local MJValua = MJ
    local n = 0;
    for i,v in ipairs(self.HandMJ[ChairId].MJs) do
        if v:IsShow() and v:GetValue() == MJValua then
            v:Hide()
            n = n + 1
        end
        if n == 3 then
            break 
        end
    end
    self:MoveSortHandMJ(ChairId,GameData)
end

--补杠
function ZhengZhouMJMainView:HandMJBGang(ChairId,MJ,GameData)
    local MJValua = MJ
    local n = 0;
    for i,v in ipairs(self.HandMJ[ChairId].MJs) do
        if v:IsShow() and v:GetValue() == MJValua then
            v:Hide()
            n = n + 1
        end
        if n == 1 then
            break 
        end
    end
    self:MoveSortHandMJ(ChairId,GameData)
end

--暗杠
function ZhengZhouMJMainView:HandMJAGang(ChairId,MJ,GameData)
    local MJValua = MJ
    local n = 0;
    for i,v in ipairs(self.HandMJ[ChairId].MJs) do
        if v:IsShow() and v:GetValue() == MJValua then
            v:Hide()
            n = n + 1
        end
        if n == 4 then
            break 
        end
    end

    self:MoveSortHandMJ(ChairId,GameData)
end

--点炮
function ZhengZhouMJMainView:HandMJDianPao(ChairId,MJ,GameData)
    self.HandMJ[ChairId].MJs[14]:SetValue(MJ)
    self.HandMJ[ChairId].MJs[14]:SetTing(false)
    self.HandMJ[ChairId].MJs[14]:SetSelect(false)
    self.HandMJ[ChairId].MJs[14]:SetLaiZi(ZhengZhouMJ.IsLaiZi(MJ))
    self.HandMJ[ChairId].MJs[14]:Show()
end


function ZhengZhouMJMainView:HandMJTing(ChairId,GameData)
    if GameData.Table.Players[ChairId].IsTing then
        for i,v in ipairs(self.HandMJ[ChairId].MJs) do
            if v:IsShow() then
                v:SetTing(true)
            end
        end
    end
end

--冒泡排序手牌 table.sort会出现不安全排序报错 所以采用冒泡排序法
function ZhengZhouMJMainView:StortHandMJ(ChairId)
    local len = #self.HandMJ[ChairId].MJs
    for i = 1,len do
        for j=1,len-i do
            local IsChange = false
            local MJ_a = self.HandMJ[ChairId].MJs[j]
            local MJ_b = self.HandMJ[ChairId].MJs[j+1]
            if MJ_a:IsShow() and MJ_b:IsShow() then
                if MJ_a:GetLaiZi() and MJ_b:GetLaiZi() then
                    if MJ_a:GetValue() < MJ_b:GetValue() then
                        IsChange = true
                    end
                elseif MJ_a:GetLaiZi() or MJ_b:GetLaiZi() then
                    if MJ_a:GetLaiZi() then
                        IsChange = true
                    end
                else
                    if MJ_a:GetValue() < MJ_b:GetValue() then
                        IsChange = true
                    end
                end
            elseif MJ_a:IsShow() or MJ_b:IsShow() then
                if MJ_b:IsShow() then
                    IsChange = true
                end
            end
            if IsChange then
                self.HandMJ[ChairId].MJs[j] = MJ_b
                self.HandMJ[ChairId].MJs[j+1] = MJ_a
            end
        end
    end
end

--刷新移动手牌
function ZhengZhouMJMainView:MoveSortHandMJ(ChairId,GameData)
    StartCoroutine(function()
        self.HandMJ[ChairId].MJs[14]:PlayAnim("MJHuanWei")
        self:StortHandMJ(ChairId)
        self:HandMJTing(ChairId,GameData)
        WaitForSeconds(0.1)
        for i,v in ipairs(self.HandMJ[ChairId].MJs) do
            v:SetSelect(false)
            v:SetSeat(self.HandMJ[ChairId].Pos[i],false)
            v:DOLocalMove(self.HandMJ[ChairId].Pos[i], 0.3)
        end
        WaitForSeconds(0.3)
        --self:UpDataHandMJ(ChairId,GameData)
    end)
end

--游戏结束到牌
function ZhengZhouMJMainView:HandMJDaoPai()
    for i=1,4 do
        for j,v in ipairs(self.HandMJ[i].MJs) do
            v:SetLayer("3D")
            v:SetTing(false)
            v:PlayAnim("DaoPai")
        end
    end
end

--获取玩家摸牌
function ZhengZhouMJMainView:GetChairIdMoPai(ChairId)
    return self.HandMJ[ChairId].MJs[14]:GetObj():GetTransform()
end