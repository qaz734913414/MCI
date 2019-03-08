
--加载玩家操作按钮
function ZhengZhouMJMainView:LoadOperatGroup()
    self.IsHaveTing = false
    self.OperatGroup = self:Find("OperatView/OperatGroup")
    self.Operat_guo = self.OperatGroup:Find("bt_guo")
    self.Operat_hu = self.OperatGroup:Find("bt_hu")
    self.Operat_chi = self.OperatGroup:Find("bt_chi")
    self.Operat_pen = self.OperatGroup:Find("bt_peng")
    self.Operat_gang = self.OperatGroup:Find("bt_gang")
    self.Operat_ting = self.OperatGroup:Find("bt_ting")
    self.ChanageOperatMJView = self:Find("OperatView/ChanageOperatMJ")
    self.ChanageOperatMJViewBg = self.ChanageOperatMJView:Find("Background"):GetComponent("RectTransform")
    self.ChanageOperatMJViewItme = self.ChanageOperatMJView:Find("Card")
    self.ChanageOperatMJViewMJPrent = self.ChanageOperatMJView:Find("MJs")
    self.Operat_guo:SetOnClick(function(evt, go, args)
        self:GuoButtClick()
    end)
    self.Operat_hu:SetOnClick(function(evt, go, args)
        self:HuButtClick()
    end)
    self.Operat_chi:SetOnClick(function(evt, go, args)
        self:ChiButtClick()
    end)
    self.Operat_pen:SetOnClick(function(evt, go, args)
        self:PenButtClick()
    end)
    self.Operat_gang:SetOnClick(function(evt, go, args)
        self:GangButtClick()
    end)
    self.Operat_ting:SetOnClick(function(evt, go, args)
        self:TingButtClick()
    end)
end

--初始化
function ZhengZhouMJMainView:InitOperatGroup()
    --操作按钮
    self.IsHaveTing = false
    self.PlayerOperatTips.gameObject:SetActive(false)
    self.OperatGroup.gameObject:SetActive(false)
    self.Operat_guo.gameObject:SetActive(false)
    self.Operat_hu.gameObject:SetActive(false)
    self.Operat_chi.gameObject:SetActive(false)
    self.Operat_pen.gameObject:SetActive(false)
    self.Operat_gang.gameObject:SetActive(false)
    self.Operat_ting.gameObject:SetActive(false)
    self:HideChanageOperatMJ();
end


--显示操作按钮
function ZhengZhouMJMainView:ShowOperation(GameData)
    if self.OnFaPaiAnim then return end
    if #GameData.Table.Players[1].Operations > 0 then
        self:InitOperatGroup()
        self.Operat_guo.gameObject:SetActive(true)
        for i,v in ipairs(GameData.Table.Players[1].Operations) do
            if v.Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCH then         --碰
                self.Operat_pen.gameObject:SetActive(true)
            elseif v.Type == ZhengZhouMJ.MJHandleType.Gang then             --杠
                self.Operat_gang.gameObject:SetActive(true)
            elseif v.Type == ZhengZhouMJ.MJHandleType.MAHJSTARLISTEN then   --听
                self.IsHaveTing = true
                self.Operat_ting.gameObject:SetActive(true)
            elseif v.Type == ZhengZhouMJ.MJHandleType.MAHJSTAOWNDRAW or v.Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCHWIN then   --胡
                self.Operat_hu.gameObject:SetActive(true)
            end
        end
        self.OperatGroup.gameObject:SetActive(true)
    else
        for i,v in ipairs(GameData.Table.Players) do
            if i ~= 1 and #GameData.Table.Players[i].Operations > 0 then
                self.PlayerOperatTips.gameObject:SetActive(true)
                self.PlayerOperatTipsLable.text = "等待其他玩家选择:碰,杠,胡"
                break
            end
        end
    end
end

function ZhengZhouMJMainView:GuoButtClick()
    local GameData = ZhengZhouMJ.GetGameData()
    for i,v in ipairs(GameData.Table.Players[1].Operations) do
        if v.Type == ZhengZhouMJ.MJHandleType.MAHJSTARLISTEN then         --听
            ZhengZhouMJ.SendPlayerTing(0)
            break
        elseif v.Type == ZhengZhouMJ.MJHandleType.MAHJSTAABAR or v.Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCH or v.Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCHWIN  then         --听
            ZhengZhouMJ.SendPlayerOperat(false,0)
            break
        else
            ZhengZhouMJ.SendPlayerOperat(true,0,0)
            break
        end
    end
    self:InitOperatGroup()
end

function ZhengZhouMJMainView:ChiButtClick()
    
end

function ZhengZhouMJMainView:PenButtClick()
    local GameData = ZhengZhouMJ.GetGameData()
    for i,v in ipairs(GameData.Table.Players[1].Operations) do
        if v.Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCH then         --碰
            ZhengZhouMJ.SendPlayerOperat(false,v.Type)
            break
        end
    end
    self:InitOperatGroup()
end
 --{Type = MJHandleType.MAHJSTATOUCH ,Operats={{Type,MJ}}}     自己的操作選項數據
function ZhengZhouMJMainView:GangButtClick()
    local GameData = ZhengZhouMJ.GetGameData()
    for i,v in ipairs(GameData.Table.Players[1].Operations) do
        if v.Type == ZhengZhouMJ.MJHandleType.Gang then         --杠
            if #v.Operats == 1 then                                   
                if v.Operats[1].Type == ZhengZhouMJ.MJHandleType.MAHJSTAABAR then  --明杠是操作别人的牌
                    ZhengZhouMJ.SendPlayerOperat(false,v.Operats[1].Type)
                else
                    ZhengZhouMJ.SendPlayerOperat(true,v.Operats[1].Type,v.Operats[1].MJ)
                end
                self:InitOperatGroup()
            else                                                --有多杠 
                self.Operat_gang.gameObject:SetActive(false)
                self:ChanageOperatMJ(v.Operats)
            end
        end
    end
    
end

function ZhengZhouMJMainView:TingButtClick()
    local GameData = ZhengZhouMJ.GetGameData()
    for i,v in ipairs(GameData.Table.Players[1].Operations) do
        if v.Type == ZhengZhouMJ.MJHandleType.MAHJSTARLISTEN then         --听
            ZhengZhouMJ.SendPlayerTing(1)
            break
        end
    end
    self:InitOperatGroup()
end


function ZhengZhouMJMainView:HuButtClick()
    local GameData = ZhengZhouMJ.GetGameData()
    for i,v in ipairs(GameData.Table.Players[1].Operations) do
        if v.Type == ZhengZhouMJ.MJHandleType.MAHJSTAOWNDRAW then         --自摸
            ZhengZhouMJ.SendPlayerOperat(true,v.Type,v.Operats[1].MJ)
            break
        elseif v.Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCHWIN then         --点炮
            ZhengZhouMJ.SendPlayerOperat(false,v.Type)
            break
        end
    end
    self:InitOperatGroup()
end




--显示二级操作选择界面
function ZhengZhouMJMainView:ChanageOperatMJ(Operats)
    local Count = #Operats
    for i,v in ipairs(Operats) do
        local obj = self:InstantionGameObject(self.ChanageOperatMJViewItme,self.ChanageOperatMJViewMJPrent, tostring(i))
        local MJ = self:CreateUIMJ(obj,v.MJ);
        obj.gameObject:SetActive(true)
        obj:SetOnClick(function (evt, go, args)
            print("点击二级操作界面的选项 "..v.Type .." MJ"..v.MJ)
            ZhengZhouMJ.SendPlayerOperat(true,v.Type,v.MJ)
            self:InitOperatGroup()
        end)
    end
    self.ChanageOperatMJViewBg.sizeDelta = Vector2(Count*130,150)
    self.ChanageOperatMJView.gameObject:SetActive(true)
end

function ZhengZhouMJMainView:HideChanageOperatMJ()
    self.ChanageOperatMJView.gameObject:SetActive(false)
    self.ChanageOperatMJViewMJPrent:RemoveAllChild()
end