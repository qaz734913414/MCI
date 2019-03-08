PksDetailsData = class()

function PksDetailsData:ctor(Pks)
    self.DetailsData = {}
    self.DetailsData_SortValue = {}     --牌值排序
    self.ValueNum = 0
    self.MaxSamePkNum = 0
    for i1,v1 in ipairs(Pks) do
        local IsKeep = false
        for i2,v2 in ipairs(self.DetailsData) do
            if v2.Value == v1.PValue then
                IsKeep = true
                table.insert(v2.Pks,v1)
                self.MaxSamePkNum = self.MaxSamePkNum > #v2.Pks and self.MaxSamePkNum or #v2.Pks
            end
        end
        if not IsKeep then
            local PkData = {}
            PkData.Value = v1.PValue
            PkData.Pks = {}
            table.insert(PkData.Pks,v1)
            table.insert(self.DetailsData,PkData)
            self.ValueNum = self.ValueNum + 1
            self.MaxSamePkNum = self.MaxSamePkNum > #PkData.Pks and self.MaxSamePkNum or #PkData.Pks
        end
    end
    self.DetailsData_SortValue = DouDiZhu.TableCopy(self.DetailsData)
    table.sort(self.DetailsData, function(a,b)
        if #a.Pks == #b.Pks then
            return a.Value < b.Value
        else
            return #a.Pks > #b.Pks
        end
    end)
    table.sort(self.DetailsData_SortValue, function(a,b)
        return a.Value < b.Value
    end)
end

--牌型解析
BrandType = class()

function BrandType:ctor(Pks)
    print("牌型解析 1")
    self.Pks = Pks
    self.MinValue = 0
    self.FeiJiNum = 0
    self.PksLength = #Pks
    self.ArrangePks = {}
    self.DetailsData = PksDetailsData.new(Pks)
    self.type = POKETYPE.POKE_INVALID
    self:GetType()
    print("牌型解析 "..self.type)
end

--获取牌型
function BrandType:GetType()
    if self:Is_POKE_SINGLECARD()  then                  --单张
        self.type = POKETYPE.POKE_SINGLECARD;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_SUB() then                      --对子
        self.type = POKETYPE.POKE_SUB;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_THREECARDS() then               --三张
        self.type = POKETYPE.POKE_THREECARDS;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_BOMB() then                     --四张 炸弹
        self.type = POKETYPE.POKE_BOMB;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_THREEBELTONE() then             --三张带一
        self.type = POKETYPE.POKE_THREEBELTONE;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_THREEBELTSUB()  then            --三张带一对
        self.type = POKETYPE.POKE_THREEBELTSUB;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_SHUNZI() then                   --顺子
        self.type = POKETYPE.POKE_SHUNZI;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_SUBSHUNZI() then                --双顺
        self.type = POKETYPE.POKE_SUBSHUNZI;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_THREESHUNZI() then             --三顺
        self.type = POKETYPE.POKE_THREESHUNZI;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_PLANEADDSIN() then              --飞机带翅膀
        self.type = POKETYPE.POKE_PLANEADDSIN;
    elseif self:Is_POKE_PLANEADDSUM() then              --飞机带双翅
        self.type = POKETYPE.POKE_PLANEADDSUM;
    elseif self:Is_POKE_BOMBADDSIN() then               --四代二
        self.type = POKETYPE.POKE_BOMBADDSIN;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_BOMBADDSUM() then               --四代两对
        self.type = POKETYPE.POKE_BOMBADDSUM;
        self.MinValue = self.DetailsData.DetailsData[1].Value
    elseif self:Is_POKE_ROCKET() then                   --火箭
        self.type = POKETYPE.POKE_ROCKET;   
        self.MinValue = self.DetailsData.DetailsData[2].Value   
    end
end

-- 是否是单张
function BrandType:Is_POKE_SINGLECARD()
    if self.PksLength == 1 then
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[1])     
        return true
    else
        return false
    end
end

--是否是对子
function BrandType:Is_POKE_SUB()
    if self.PksLength == 2 and self.DetailsData.ValueNum == 1 then
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[1])
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[2])  
        return true
    else
        return false
    end
end

--是否是三张
function BrandType:Is_POKE_THREECARDS()
    if self.PksLength == 3 and self.DetailsData.ValueNum == 1 then
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[1])
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[2])  
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[3]) 
        return true
    else
        return false
    end
end

--是否是四张
function BrandType:Is_POKE_BOMB()
    if self.PksLength == 4 and self.DetailsData.ValueNum == 1 then
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[1])
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[2])  
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[3])
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[4])     
        return true
    else
        return false
    end
end

--是否是三代一
function BrandType:Is_POKE_THREEBELTONE()
    if self.PksLength == 4 and self.DetailsData.MaxSamePkNum == 3 then
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[1])
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[2])  
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[3])
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[2].Pks[1]) 
        return true
    else
        return false
    end
end

--是否是三带一对
function BrandType:Is_POKE_THREEBELTSUB()
    if self.PksLength == 5 and self.DetailsData.MaxSamePkNum == 3 and self.DetailsData.ValueNum == 2 then
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[1])
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[2])  
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[1].Pks[3])
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[2].Pks[1])
        table.insert(self.ArrangePks,self.DetailsData.DetailsData[2].Pks[2])    
        return true
    else
        return false
    end
end

--是否是顺子
function BrandType:Is_POKE_SHUNZI()
    if self.PksLength >= 5 and self.DetailsData.ValueNum == self.PksLength and self:IsShunZi() then
        for i,v in ipairs(self.DetailsData.DetailsData) do
            table.insert(self.ArrangePks,v.Pks[1])
        end
        return true
    else
        return false
    end
end

--是否是双顺
function BrandType:Is_POKE_SUBSHUNZI()
    if self.PksLength >= 6 and self.DetailsData.MaxSamePkNum == 2 and self.DetailsData.ValueNum * 2 == self.PksLength and self:IsShunZi() then
        for i,v in ipairs(self.DetailsData.DetailsData) do
            table.insert(self.ArrangePks,v.Pks[1])
            table.insert(self.ArrangePks,v.Pks[2])
        end    
        return true
    else
        return false
    end
end

--是否是三顺
function BrandType:Is_POKE_THREESHUNZI()
    if self.PksLength >= 6 and self.DetailsData.MaxSamePkNum == 3 and  self.DetailsData.ValueNum * 3 == self.PksLength and self:IsShunZi() then
        for i,v in ipairs(self.DetailsData.DetailsData) do
            table.insert(self.ArrangePks,v.Pks[1])
            table.insert(self.ArrangePks,v.Pks[2])
            table.insert(self.ArrangePks,v.Pks[3])
        end     
        return true
    else
        return false
    end
end

--是否是飞机带翅膀
function BrandType:Is_POKE_PLANEADDSIN()
    if self.PksLength >= 8 and self.DetailsData.MaxSamePkNum >= 3 then 
        local feojinum = 0
        local FeiJi = {}
        local chibangnum = 0
        local ChiBang = {}
        local LastValue = 0
        for i,v in ipairs(self.DetailsData.DetailsData_SortValue) do
            if #v.Pks >= 3 then
                if LastValue ~= 0 then
                    if LastValue == v.Value - 1 and LastValue < 15 then
                        for i1,v1 in ipairs(v.Pks) do
                            if i1 <= 3 then
                                table.insert(FeiJi,v1)
                            else
                                table.insert(ChiBang,v1)
                            end
                        end
                        feojinum = feojinum + 1
                        chibangnum = #ChiBang
                    else
                        if feojinum < 2 then
                            for i,v in ipairs(FeiJi) do
                                table.insert(ChiBang,v)
                            end
                            FeiJi = {}
                            for i1,v1 in ipairs(v.Pks) do
                                if i1 <= 3 then
                                    table.insert(FeiJi,v1)
                                else
                                    table.insert(ChiBang,v1)
                                end
                            end
                            feojinum = 1
                            chibangnum = #ChiBang
                            self.MinValue = v.Value
                        else
                            for i1,v1 in ipairs(v.Pks) do
                                table.insert(ChiBang,v1)
                            end
                            chibangnum = #ChiBang
                        end
                    end
                else
                    for i1,v1 in ipairs(v.Pks) do
                        if i1 <= 3 then
                            table.insert(FeiJi,v1)
                        else
                            table.insert(ChiBang,v1)
                        end
                    end
                    feojinum = 1
                    chibangnum = #ChiBang
                    self.MinValue = v.Value
                end
                LastValue =  v.Value
            else
                for i1,v1 in ipairs(v.Pks) do
                    table.insert(ChiBang,v1)
                end
                chibangnum = #ChiBang
            end
        end
        if feojinum >= 2 and feojinum == chibangnum then
            self.FeiJiNum = feojinum
            for i,v in ipairs(FeiJi) do
                table.insert(self.ArrangePks,v)
            end   
            for i,v in ipairs(ChiBang) do
                table.insert(self.ArrangePks,v)
            end   
            return true
        else
            self.ArrangePks = {}
            return false
        end
    else
        self.ArrangePks = {}
        return false
    end
end

--飞机带双翅
function BrandType:Is_POKE_PLANEADDSUM()
    if self.PksLength >= 10 and self.DetailsData.MaxSamePkNum == 3 then 
        local feojinum = 0
        local FeiJi = {}
        local chibangnum = 0
        local ChiBang = {}
        local LastValue = 0
        for i,v in ipairs(self.DetailsData.DetailsData) do
            if #v.Pks == 3 then
                if LastValue ~= 0 then
                    if LastValue ~= v.Value - 1 or LastValue >= 15 then
                        self.ArrangePks = {}
                        return false
                    end
                else
                    self.MinValue = v.Value
                end
                for i1,v1 in ipairs(v.Pks) do
                    table.insert(FeiJi,v1)
                end
                LastValue = v.Value
                feojinum = feojinum + 1
            elseif #v.Pks == 4 then
                chibangnum  =  chibangnum  + 2
                for i1,v1 in ipairs(v.Pks) do
                    table.insert(ChiBang,v1)
                end
            elseif #v.Pks == 2 then
                chibangnum  =  chibangnum  + 1
                for i1,v1 in ipairs(v.Pks) do
                    table.insert(ChiBang,v1)
                end
            else
                self.ArrangePks = {}
                return false
            end
        end
        if feojinum >= 2 and feojinum == chibangnum then
            self.FeiJiNum = feojinum
            for i,v in ipairs(FeiJi) do
                table.insert(self.ArrangePks,v)
            end   
            for i,v in ipairs(ChiBang) do
                table.insert(self.ArrangePks,v)
            end  
            return true
        else
            self.ArrangePks = {}
            return false
        end
    else
        self.ArrangePks = {}
        return false
    end
end

--是否是四代二
function BrandType:Is_POKE_BOMBADDSIN()
    if self.PksLength == 6 and self.DetailsData.MaxSamePkNum == 4 then     
        for i,v in ipairs(self.DetailsData.DetailsData) do
            for i1,v1 in ipairs(v.Pks) do
                table.insert(self.ArrangePks,v1)
            end
        end  
        return true
    else
        return false
    end
end

--是否是四代两对
function BrandType:Is_POKE_BOMBADDSUM()
    if self.PksLength == 8 and self.DetailsData.MaxSamePkNum == 4 and self.DetailsData.ValueNum == 3 and #self.DetailsData.DetailsData[2].Pks == 2 then     
        for i,v in ipairs(self.DetailsData.DetailsData) do
            for i1,v1 in ipairs(v.Pks) do
                table.insert(self.ArrangePks,v1)
            end
        end 
        return true
    else
        return false
    end
end

--是否是火箭
function BrandType:Is_POKE_ROCKET()
    if self.PksLength == 2 and self.Pks[1].HuaSe == POKEHuaSe.King and self.Pks[2].HuaSe == POKEHuaSe.King then 
        for i,v in ipairs(self.DetailsData.DetailsData) do
            for i1,v1 in ipairs(v.Pks) do
                table.insert(self.ArrangePks,v1)
            end
        end 
        return true
    else
        return false
    end
end

--是否是顺子
function BrandType:IsShunZi()
    local LastValue = self.DetailsData.DetailsData[1].Value
    if LastValue >= 15 then
        return false
    end
    for i=2,#self.DetailsData.DetailsData_SortValue do
        if LastValue == self.DetailsData.DetailsData[i].Value - 1 and self.DetailsData.DetailsData[i].Value < 15 then
            LastValue = self.DetailsData.DetailsData[i].Value
            if LastValue >= 15 then
                return false
            end
        else
            return false
        end
    end
    return true
end

--获取出牌数组
function BrandType:GetServerValueList()
    local SendData = {}
    local Str = ""
    for i1,v1 in ipairs(self.ArrangePks) do
        Str = Str..v1.PValue..","
        table.insert(SendData,v1.Value)
    end
    print("獲取出牌的牌 = "..Str)
    return SendData
end

HandPknalysis = class()

function HandPknalysis:ctor(Pks)
    print("自己的手牌类型  Num = "..#Pks)
    self.Pks = Pks
    self.PksLength = #Pks
    self.DetailsData = PksDetailsData.new(Pks)
    self.BrandTypeData = {}
    self.BrandTypeData[POKETYPE.POKE_ROCKET] = {}           --火箭
    self.BrandTypeData[POKETYPE.POKE_BOMB] = {}             --四张   
    self.BrandTypeData[POKETYPE.POKE_THREECARDS] = {}       --三张
    self.BrandTypeData[POKETYPE.POKE_SUB] = {}              --两张
    self.BrandTypeData[POKETYPE.POKE_SINGLECARD] = {}       --一张
    self.BrandTypeData[POKETYPE.POKE_SHUNZI] = {}           --顺子
    self.BrandTypeData[POKETYPE.POKE_SUBSHUNZI] = {}        --双顺
    self.BrandTypeData[POKETYPE.POKE_THREESHUNZI] = {}      --三顺
    local LastPkValue = 0
    local HuoJIan = {}
    local SunZiNum1 = {}
    local SunZiNum2 = {}
    local SunZiNum3 = {}
    print("自己的手牌分析 1 ")
    for i,v in ipairs(self.DetailsData.DetailsData_SortValue) do
        if #v.Pks == 4 then
            table.insert(self.BrandTypeData[POKETYPE.POKE_BOMB],v)
        elseif #v.Pks == 3 then
            table.insert(self.BrandTypeData[POKETYPE.POKE_THREECARDS],v)
        elseif #v.Pks == 2 then
            table.insert(self.BrandTypeData[POKETYPE.POKE_SUB],v)
        elseif #v.Pks == 1 then
            if v.Value > 15 then
                table.insert(HuoJIan,v)
            else
                table.insert(self.BrandTypeData[POKETYPE.POKE_SINGLECARD],v)
            end
        end
        if LastPkValue ~= 0 then
            if LastPkValue == v.Value - 1 and v.Value < 15 then
                if #v.Pks < 3 then
                    if #SunZiNum3 >= 2 then
                        table.insert(self.BrandTypeData[POKETYPE.POKE_THREESHUNZI],SunZiNum3) --三顺
                    end
                    SunZiNum3 = {}
                    if #v.Pks < 2 then
                        if #SunZiNum2 >= 3 then
                            table.insert(self.BrandTypeData[POKETYPE.POKE_SUBSHUNZI],SunZiNum2)   --双顺
                        end
                        SunZiNum2 = {}
                    end
                end
            else
                if #SunZiNum1 >= 5 then
                    table.insert(self.BrandTypeData[POKETYPE.POKE_SHUNZI],SunZiNum1) --顺子
                end
                if #SunZiNum2 >= 3 then
                    table.insert(self.BrandTypeData[POKETYPE.POKE_SUBSHUNZI],SunZiNum2)   --双顺
                end
                if #SunZiNum3 >= 2 then
                    table.insert(self.BrandTypeData[POKETYPE.POKE_THREESHUNZI],SunZiNum3) --三顺
                end
                SunZiNum1 = {}
                SunZiNum2 = {}
                SunZiNum3 = {}
            end
        end
        if #v.Pks >= 1 then
            table.insert(SunZiNum1,v)
            if #v.Pks >= 2 then
                table.insert(SunZiNum2,v)
                if #v.Pks >= 3 then
                    table.insert(SunZiNum3,v)
                end
            end
        end
        if v.Value < 15 then
            LastPkValue = v.Value
        end
    end
    if #HuoJIan == 2 then
        table.insert(self.BrandTypeData[POKETYPE.POKE_ROCKET],HuoJIan[1])
        table.insert(self.BrandTypeData[POKETYPE.POKE_ROCKET],HuoJIan[2])
    else
        for i,v in ipairs(HuoJIan) do
            table.insert(self.BrandTypeData[POKETYPE.POKE_SINGLECARD],v)
        end
    end
    print("自己的手牌类型  一张 ="..#self.BrandTypeData[POKETYPE.POKE_SINGLECARD])
    print("自己的手牌类型  两张 ="..#self.BrandTypeData[POKETYPE.POKE_SUB])
    print("自己的手牌类型  三张 ="..#self.BrandTypeData[POKETYPE.POKE_THREECARDS])
    print("自己的手牌类型  四张 ="..#self.BrandTypeData[POKETYPE.POKE_BOMB])
    print("自己的手牌类型  顺子 ="..#self.BrandTypeData[POKETYPE.POKE_SHUNZI])
    print("自己的手牌类型  双顺 ="..#self.BrandTypeData[POKETYPE.POKE_SUBSHUNZI])
    print("自己的手牌类型  三顺 ="..#self.BrandTypeData[POKETYPE.POKE_THREESHUNZI])
    print("自己的手牌类型  2")
end

--获取可压牌数据
function HandPknalysis:GetTakeOverList(Brand)
    print("提示 牌型 1 ")
    local OverList = {}
    if not Brand then
        print("提示 牌型 2 ")
        OverList = self:GetRecommendList()
        return OverList
    end
    print("提示 牌型 3 ")
    local BrandType = Brand.type;
    print("目标 牌型 = "..BrandType.."|MinValue = "..Brand.MinValue)
    if BrandType == POKETYPE.POKE_SINGLECARD then                   --单牌
        OverList = self:GetOver_POKE_SINGLECARD(Brand.MinValue)
    elseif BrandType == POKETYPE.POKE_SUB then                      --对子
        OverList = self:GetOver_POKE_SUB(Brand.MinValue)
    elseif BrandType == POKETYPE.POKE_THREECARDS then               --三张
        OverList = self:GetOver_POKE_THREECARDS(Brand.MinValue)
    elseif BrandType == POKETYPE.POKE_BOMB then                     --四张
        OverList = self:GetOver_POKE_BOMB(Brand.MinValue)
    elseif BrandType == POKETYPE.POKE_THREEBELTONE then             --三代一
        OverList = self:GetOver_POKE_THREEBELTONE(Brand.MinValue)
    elseif BrandType == POKETYPE.POKE_THREEBELTSUB then             --三带一对
        OverList = self:GetOver_POKE_THREEBELTSUB(Brand.MinValue)
    elseif BrandType == POKETYPE.POKE_SHUNZI then                   --顺子
        OverList = self:GetOver_POKE_SHUNZI(Brand.MinValue,Brand.DetailsData.ValueNum)
    elseif BrandType == POKETYPE.POKE_SUBSHUNZI then                --双顺
        OverList = self:GetOver_POKE_SUBSHUNZI(Brand.MinValue,Brand.DetailsData.ValueNum)
    elseif BrandType == POKETYPE.POKE_THREESHUNZI then              --三顺
        OverList = self:GetOver_POKE_THREESHUNZI(Brand.MinValue,Brand.DetailsData.ValueNum)
    elseif BrandType == POKETYPE.POKE_PLANEADDSIN then              --飞机带翅膀
        OverList = self:GetOver_POKE_PLANEADDSIN(Brand.MinValue,Brand.FeiJiNum)
    elseif BrandType == POKETYPE.POKE_PLANEADDSUM then              --飞机带双翅膀
        OverList = self:GetOver_POKE_PLANEADDSUM(Brand.MinValue,Brand.FeiJiNum)
    elseif BrandType == POKETYPE.POKE_BOMBADDSIN then               --四代二
        OverList = self:GetOver_POKE_BOMBADDSIN(Brand.MinValue)
    elseif BrandType == POKETYPE.POKE_BOMBADDSUM then               --四代两对
        OverList = self:GetOver_POKE_BOMBADDSUM(Brand.MinValue)
    end
    print("可压 牌型 = "..#OverList)
    return OverList
end

--获取可压过的单牌
function HandPknalysis:GetOver_POKE_SINGLECARD(_MinValue)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SINGLECARD]) do
        if v.Value > _MinValue then
            table.insert(OverList,v.Pks)
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SUB]) do
        if v.Value > _MinValue then
            table.insert(OverList,{v.Pks[1]})
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        if v.Value > _MinValue then
            table.insert(OverList,{v.Pks[1]})
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
        if v.Value > _MinValue then
            table.insert(OverList,{v.Pks[1]})
        end
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的对子
function HandPknalysis:GetOver_POKE_SUB(_MinValue)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SUB]) do
        if v.Value > _MinValue then
            table.insert(OverList,v.Pks)
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        if v.Value > _MinValue then
            table.insert(OverList,{v.Pks[1],v.Pks[2]})
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
        if v.Value > _MinValue then
            table.insert(OverList,{v.Pks[1],v.Pks[2]})
        end
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的三张
function HandPknalysis:GetOver_POKE_THREECARDS(_MinValue)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        if v.Value > _MinValue then
            table.insert(OverList,v.Pks)
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
        if v.Value > _MinValue then
            table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3]})
        end
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的四张
function HandPknalysis:GetOver_POKE_BOMB(_MinValue)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        if v.Value > _MinValue then
            table.insert(OverList,v.Pks)
        end
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的三代一
function HandPknalysis:GetOver_POKE_THREEBELTONE(_MinValue)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        if v.Value > _MinValue then
            local tmp = self:GetChiBangPk1({v},1)
            if tmp then
                table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],tmp[1]})
            end
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
        if v.Value > _MinValue then
            local tmp = self:GetChiBangPk1({v},1)
            if tmp then
                table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],tmp[1]})
            end
        end
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的三代一对
function HandPknalysis:GetOver_POKE_THREEBELTSUB(_MinValue)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        if v.Value > _MinValue then
            local tmp = self:GetChiBangPk2({v},1)
            if tmp then
                table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],tmp[1],tmp[2]})
            end
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
        if v.Value > _MinValue then
            local tmp = self:GetChiBangPk2({v},1)
            if tmp then
                table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],tmp[1],tmp[2]})
            end
        end
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的顺子
function HandPknalysis:GetOver_POKE_SHUNZI(_MinValue,_Lenght)
    print("判断可压过的顺子 _MinValue =".._MinValue.." _Lenght=".._Lenght)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SHUNZI]) do
        if #v >= _Lenght then
            for i=1,#v - _Lenght + 1 do
                if v[i].Value > _MinValue then
                    local tmpsunzi = {}
                    for i=i, i + _Lenght -1 do
                        table.insert(tmpsunzi,v[i].Pks[1])
                    end
                    table.insert(OverList,tmpsunzi)
                end
            end
        end
    end

    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的双顺
function HandPknalysis:GetOver_POKE_SUBSHUNZI(_MinValue,_Lenght)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SUBSHUNZI]) do
        if #v >= _Lenght then
            for i=1,#v - _Lenght + 1 do
                if v[i].Value > _MinValue then
                    local tmpsunzi = {}
                    for i=i, i + _Lenght -1 do
                        table.insert(tmpsunzi,v[i].Pks[1])
                        table.insert(tmpsunzi,v[i].Pks[2])
                    end
                    table.insert(OverList,tmpsunzi)
                end
            end
        end
    end

    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的三顺
function HandPknalysis:GetOver_POKE_THREESHUNZI(_MinValue,_Lenght)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREESHUNZI]) do
        if #v >= _Lenght then
            for i=1,#v - _Lenght + 1 do
                if v[i].Value > _MinValue then
                    local tmpsunzi = {}
                    for i=i, i + _Lenght -1 do
                        table.insert(tmpsunzi,v[i].Pks[1])
                        table.insert(tmpsunzi,v[i].Pks[2])
                        table.insert(tmpsunzi,v[i].Pks[3])
                    end
                    table.insert(OverList,tmpsunzi)
                end
            end
        end
    end

    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的飞机带翅膀
function HandPknalysis:GetOver_POKE_PLANEADDSIN(_MinValue,_Lenght)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREESHUNZI]) do
        if #v >= _Lenght then
            for i=1,#v - _Lenght + 1 do
                if v[i].Value > _MinValue then
                    local feijis = {}
                    for i=i, i + _Lenght -1 do
                        table.insert(feijis,v[i])
                    end
                    local temp = self:GetChiBangPk1(feijis,#feijis)
                    if temp then
                        local tmpsunzi = {}
                        for i1,v1 in ipairs(feijis) do
                            table.insert(tmpsunzi,v1.Pks[1])
                            table.insert(tmpsunzi,v1.Pks[2])
                            table.insert(tmpsunzi,v1.Pks[3])
                        end
                        for i1,v1 in ipairs(temp) do
                            table.insert(tmpsunzi,v1)
                        end
                        table.insert(OverList,tmpsunzi)
                    end
                end
            end
        end
    end

    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的飞机带对翅
function HandPknalysis:GetOver_POKE_PLANEADDSUM(_MinValue,_Lenght)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREESHUNZI]) do
        if #v >= _Lenght then
            for i=1,#v - _Lenght + 1 do
                if v[i].Value > _MinValue then
                    local feijis = {}
                    for i=i, i + _Lenght -1 do
                        table.insert(feijis,v[i])
                    end
                    local temp = self:GetChiBangPk2(feijis,#feijis)
                    if temp then
                        local tmpsunzi = {}
                        for i1,v1 in ipairs(feijis) do
                            table.insert(tmpsunzi,v1.Pks[1])
                            table.insert(tmpsunzi,v1.Pks[2])
                            table.insert(tmpsunzi,v1.Pks[3])
                        end
                        for i1,v1 in ipairs(temp) do
                            table.insert(tmpsunzi,v1)
                        end
                        table.insert(OverList,tmpsunzi)
                    end
                end
            end
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的四代二
function HandPknalysis:GetOver_POKE_BOMBADDSIN(_MinValue)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
        if v.Value > _MinValue then
            local temp =  self:GetChiBangPk1({v},2)
            if temp then
                table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],v.Pks[4],temp[1],temp[2]})
            end
        end
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取可压过的四代二对
function HandPknalysis:GetOver_POKE_BOMBADDSUM(_MinValue)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
        if v.Value > _MinValue then
            local temp =  self:GetChiBangPk2({v},2)
            if temp then
                table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],v.Pks[4],temp[1],temp[2]})
            end
        end
    end
    if #self.BrandTypeData[POKETYPE.POKE_ROCKET] == 2 then
        table.insert(OverList,{self.BrandTypeData[POKETYPE.POKE_ROCKET][1].Pks[1],self.BrandTypeData[POKETYPE.POKE_ROCKET][2].Pks[1]})
    end
    return OverList
end

--获取单翅
function HandPknalysis:GetChiBangPk1(FeiJis,RetNum)
    local RetPks = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SINGLECARD]) do
        if self:GetNoSamePk(v,FeiJis) then
            for i1,v1 in ipairs(v.Pks) do
                table.insert(RetPks,v1)
                if #RetPks == RetNum then
                    return RetPks
                end
            end
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SUB]) do
        if self:GetNoSamePk(v,FeiJis) then
            for i1,v1 in ipairs(v.Pks) do
                table.insert(RetPks,v1)
                if #RetPks == RetNum then
                    return RetPks
                end
            end
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        if self:GetNoSamePk(v,FeiJis) then
            for i1,v1 in ipairs(v.Pks) do
                table.insert(RetPks,v1)
                if #RetPks == RetNum then
                    return RetPks
                end
            end
        end
    end
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        if self:GetNoSamePk(v,FeiJis) then
            for i1,v1 in ipairs(v.Pks) do
                table.insert(RetPks,v1)
                if #RetPks == RetNum then
                    return RetPks
                end
            end
        end
    end
    return nil
end

function HandPknalysis:GetNoSamePk(PkData,Pks)
    for i,v in ipairs(Pks) do
        if PkData.Value == v.Value then
            return false
        end
    end
    return true
end

--获取对翅 只取对子
function HandPknalysis:GetChiBangPk2(PkData,RetNum)
    print("获取对翅 只取对子 1")
    local RetPks = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SUB]) do
        print("获取对翅 只取对子 2")
        if self:GetNoSamePk(v,PkData) then
            for i1,v1 in ipairs(v.Pks) do
                table.insert(RetPks,v1)
                if #RetPks == RetNum*2 then
                    return RetPks
                end
            end
        end
    end
    print("获取对翅 只取对子 5")
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        if self:GetNoSamePk(v,PkData) then
           for i=1,2 do
                table.insert(RetPks,v.Pks[i])
                if #RetPks == RetNum*2 then
                    return RetPks
                end
            end
        end
    end
    print("获取对翅 只取对子 6 ")
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        if self:GetNoSamePk(v,PkData) then
            for i1,v1 in ipairs(v.Pks) do
                table.insert(RetPks,v1)
                if #RetPks == RetNum*2 then
                    return RetPks
                end
            end
        end
    end
    print("获取对翅 只取对子 10")
    return nil
end

--获取可出牌
function HandPknalysis:GetRecommendList()
    print("显示可出牌 PksLength = "..self.PksLength)
    local OutList = {}
    if self.PksLength >= 10 then
        local Temp = self:GetOut_POKE_PLANEADDSUM()
        for i,v in ipairs(Temp) do
            table.insert(OutList,v)
        end
        print("显示可出牌 1 "..#OutList)
        --if #OutList > 0 then return OutList end
    end

    if self.PksLength >= 8 then
        Temp = self:GetOut_POKE_PLANEADDSIN()
        for i,v in ipairs(Temp) do
            table.insert( OutList,v)
        end
        print("显示可出牌 2 "..#OutList)
        --if #OutList > 0 then return OutList end
    end

    if self.PksLength >= 6 then
        Temp = self:GetOut_POKE_THREESHUNZI()
        for i,v in ipairs(Temp) do
            table.insert( OutList,v)
        end
        print("显示可胡牌 4 "..#OutList)
        --if #OutList > 0 then return OutList end

        Temp = self:GetOut_POKE_SUBSHUNZI()
        for i,v in ipairs(Temp) do
            table.insert( OutList,v)
        end
        print("显示可胡牌 5 "..#OutList)
        --if #OutList > 0 then return OutList end
    end

    if self.PksLength >= 5 then
        Temp = self:GetOut_POKE_SHUNZI()
        for i,v in ipairs(Temp) do
            table.insert( OutList,v)
        end
        print("显示可胡牌 7 "..#OutList)
        --if #OutList > 0 then return OutList end

        Temp = self:GetOut_POKE_THREEBELTSUB()
        for i,v in ipairs(Temp) do
            table.insert( OutList,v)
        end
        print("显示可胡牌 8 "..#OutList)
        --if #OutList > 0 then return OutList end
        
    end

    if self.PksLength >= 4 then
        Temp = self:GetOut_POKE_THREEBELTONE()
        for i,v in ipairs(Temp) do
            table.insert( OutList,v)
        end
        print("显示可胡牌 9 "..#OutList)
        --if #OutList > 0 then return OutList end
    end

    if self.PksLength >= 3 then
        Temp = self:GetOut_POKE_THREECARDS()
        for i,v in ipairs(Temp) do
            table.insert( OutList,v)
        end
        print("显示可胡牌 11 "..#OutList)
        --if #OutList > 0 then return OutList end
    end

    if self.PksLength >= 2 then
        Temp = self:GetOut_POKE_SUB()
        for i,v in ipairs(Temp) do
            table.insert( OutList,v)
        end
        print("显示可胡牌 12 "..#OutList)
        --if #OutList > 0 then return OutList end
    end

    Temp = self:GetOut_POKE_SINGLECARD()
    for i,v in ipairs(Temp) do
        table.insert( OutList,v)
    end
    print("显示可胡牌 13 "..#OutList)

    Temp = self:GetOut_POKE_BOMB()
    for i,v in ipairs(Temp) do
        table.insert( OutList,v)
    end
    print("显示可胡牌 10 "..#OutList)
    --if #OutList > 0 then return OutList end

    Temp = self:GetOut_POKE_BOMBADDSUM()
    for i,v in ipairs(Temp) do
        table.insert( OutList,v)
    end
    print("显示可胡牌 3 "..#OutList)
    --if #OutList > 0 then return OutList end

    Temp = self:GetOut_POKE_BOMBADDSIN()
    for i,v in ipairs(Temp) do
        table.insert( OutList,v)
    end
    print("显示可胡牌 6 "..#OutList)

    --if #OutList > 0 then return OutList end
    return OutList
end


--获取的飞机带对翅
function HandPknalysis:GetOut_POKE_PLANEADDSUM(_Lenght)
    local OutList = {}
    print("获取的飞机带对翅 1")
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREESHUNZI]) do
        print("获取的飞机带对翅 #v"..#v)
        for i=1,#v - 1 do
            local feijis = {}
            for i=i, #v do
                table.insert(feijis,v[i])
            end
            local temp = self:GetChiBangPk2(feijis,#feijis)
            if temp then
                local tmpsunzi = {}
                for i1,v1 in ipairs(feijis) do
                    table.insert(tmpsunzi,v1.Pks[1])
                    table.insert(tmpsunzi,v1.Pks[2])
                    table.insert(tmpsunzi,v1.Pks[3])
                end
                for i1,v1 in ipairs(temp) do
                    table.insert(tmpsunzi,v1)
                end
                table.insert(OutList,tmpsunzi)
            end
        end
    end
    print("获取的飞机带对翅 10")
    return OutList
end


--获取飞机带翅膀
function HandPknalysis:GetOut_POKE_PLANEADDSIN()
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREESHUNZI]) do
        for i=1,#v -1 do
            if v[i].Value > 0 then
                local feijis = {}
                for i=i, #v do
                    table.insert(feijis,v[i])
                end
                local temp = self:GetChiBangPk1(feijis,#feijis)
                if temp then
                    local tmpsunzi = {}
                    for i1,v1 in ipairs(feijis) do
                        table.insert(tmpsunzi,v1.Pks[1])
                        table.insert(tmpsunzi,v1.Pks[2])
                        table.insert(tmpsunzi,v1.Pks[3])
                    end
                    for i1,v1 in ipairs(temp) do
                        table.insert(tmpsunzi,v1)
                    end
                    table.insert(OverList,tmpsunzi)
                end
            end
        end
    end
    return OverList
end


--获取四代二对
function HandPknalysis:GetOut_POKE_BOMBADDSUM()
    print("获取四代二对 1")
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        print("获取四代二对 2")
        local temp =  self:GetChiBangPk2({v},2)
        if temp then
            table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],v.Pks[4],temp[1],temp[2]})
        end
    end
    print("获取四代二对 10")
    return OverList
end

--获取四代二
function HandPknalysis:GetOut_POKE_BOMBADDSIN()
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        local temp =  self:GetChiBangPk1({v},2)
        if temp then
            table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],v.Pks[4],temp[1],temp[2]})
        end
    end
    return OverList
end

--获取三顺
function HandPknalysis:GetOut_POKE_THREESHUNZI()
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREESHUNZI]) do
        local tmpsunzi = {}
        for i=1,#v do
            table.insert(tmpsunzi,v[i].Pks[1])
            table.insert(tmpsunzi,v[i].Pks[2])
            table.insert(tmpsunzi,v[i].Pks[3])
        end
        table.insert(OverList,tmpsunzi)
    end
    return OverList
end

--获取双顺
function HandPknalysis:GetOut_POKE_SUBSHUNZI(_MinValue,_Lenght)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SUBSHUNZI]) do
        local tmpsunzi = {}
        for i=1,#v  do
            table.insert(tmpsunzi,v[i].Pks[1])
            table.insert(tmpsunzi,v[i].Pks[2])
        end
        table.insert(OverList,tmpsunzi)
    end
    return OverList
end

--获取顺子
function HandPknalysis:GetOut_POKE_SHUNZI(_MinValue,_Lenght)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SHUNZI]) do
        local tmpsunzi = {}
        for i=1,#v do
            table.insert(tmpsunzi,v[i].Pks[1])
        end
        table.insert(OverList,tmpsunzi)
    end
    return OverList
end

--获取三代一对
function HandPknalysis:GetOut_POKE_THREEBELTSUB(_MinValue)
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        local tmp = self:GetChiBangPk2({v},1)
        if tmp then
            table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],tmp[1],tmp[2]})
        end
    end
    return OverList
end

--获取三代一
function HandPknalysis:GetOut_POKE_THREEBELTONE()
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        local tmp = self:GetChiBangPk1({v},1)
        if tmp then
            table.insert(OverList,{v.Pks[1],v.Pks[2],v.Pks[3],tmp[1]})
        end
    end
    return OverList
end


--获取四张
function HandPknalysis:GetOut_POKE_BOMB()
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_BOMB]) do
        table.insert(OverList,v.Pks)
    end
    return OverList
end


--获取三张
function HandPknalysis:GetOut_POKE_THREECARDS()
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_THREECARDS]) do
        table.insert(OverList,v.Pks)
    end
    return OverList
end


--获取对子
function HandPknalysis:GetOut_POKE_SUB()
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SUB]) do
        table.insert(OverList,v.Pks)
    end
    return OverList
end

--获取可压过的单牌
function HandPknalysis:GetOut_POKE_SINGLECARD()
    local OverList = {}
    for i,v in ipairs(self.BrandTypeData[POKETYPE.POKE_SINGLECARD]) do
        table.insert(OverList,v.Pks)
    end
    return OverList
end