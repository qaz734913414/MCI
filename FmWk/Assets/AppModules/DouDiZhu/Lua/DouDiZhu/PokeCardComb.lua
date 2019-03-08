--这两张牌是否构成合法连续
function IsCardSequent(valueList)    
    local sequent = true;
    table.sort(valueList);
    local lastValue = 0;
    for k, v in pairs(valueList) do        
        if v == POKEVALUE.VALUE_2 or v == POKEVALUE.VALUE_BW or v == POKEVALUE.VALUE_LW then
            sequent = false;
        end
        
        if lastValue ~= 0 then
            if v == lastValue + 1 then
            else
                sequent = false;
                break;
            end                
        end

        lastValue = v;
    end

    return sequent;
end


CardCountItem = class()

function CardCountItem:ctor(cardList)
    -- 牌的张数
    self.totalCount = table.getn(cardList);
    -- 有多少种点数的牌
    self.cardCount = 0;
    -- 点数列表
    self.valueList = {};
    -- 点数为key，该点的牌的数量为value
    self.countMap = {};
    -- 张数最多的是多少点
    self.maxCount = 0;
    
    local maxKey = 0;    
    local index = 0;    
    for i = 1,table.getn(cardList),1 do        
        if self.countMap[cardList[i].PValue] then
            self.countMap[cardList[i].PValue] = 1 + self.countMap[cardList[i].PValue];
        else
            self.countMap[cardList[i].PValue] = 1;
            self.cardCount = self.cardCount + 1;
            index = index + 1;
            self.valueList[index] = cardList[i].PValue;
        end
        if self.countMap[cardList[i].PValue] > self.maxCount then
            self.maxCount = self.countMap[cardList[i].PValue];
            maxKey = cardList[i];
        end
    end    
end

--张数为n的有几种牌，比如44556666，传入2得到2
function CardCountItem:GetNumWithCardCount(n)
    local num = 0;
    for k,v in pairs(self.countMap) do
        if v == n then
            num = num + 1;
        end
    end
    return num;
end

function CardCountItem:ToString()
    local str = "[Item]total="..self.totalCount..",count="..self.cardCount;
    str = str..",max="..self.maxCount..",value={";
    for i=1,table.getn(self.valueList),1 do
        str = str..tostring(self.valueList[i]);
        if i < table.getn(self.valueList) then
            str = str..",";
        end
    end
    str = str.."},map={";
    for k,v in pairs(self.countMap) do
        str = str.."("..tostring(k)..","..tostring(v).."),";
    end
    str = str.."}";
    return str;
end


PokeCardComb = class()

--牌的组合
function PokeCardComb:ctor(cList)    
    self.mainValue = 100;
    self.cardList = cList; 
    print("牌的组合  "..#self.cardList)      
    self.countItem = CardCountItem.new(cList);
    self.type = self:GetCombineType();
    self.length = table.getn(self.cardList);
end

-- 获取牌组合的类型，排列表按照牌值从大到小排列
function PokeCardComb:GetCombineType() 
    self.type = POKETYPE.POKE_INVALID;
    local len = table.getn(self.cardList);      
    -- 单牌
    if len == 1 then
        self.type = POKETYPE.POKE_SINGLECARD;
        self.mainValue = self.cardList[1].PValue;
    -- 对子 33    火箭
    elseif len == 2 then
        if self.cardList[1].PValue == self.cardList[2].PValue then
            self.type = POKETYPE.POKE_SUB;
            self.mainValue = self.cardList[1].PValue;
        elseif self.cardList[1].HuaSe == POKEHuaSe.King and self.cardList[2].HuaSe == POKEHuaSe.King then
            self.type = POKETYPE.POKE_ROCKET;
        end
    -- 三张 333
    elseif len == 3 then
        if self.cardList[1].PValue == self.cardList[3].PValue and self.cardList[1].PValue == self.cardList[2].PValue then
            self.type = POKETYPE.POKE_THREECARDS;
            self.mainValue = self.cardList[1].PValue;
        end
    -- 炸弹3333 / 三带一333K
    elseif len == 4 then
        if self.countItem.cardCount == 1 then
            self.type = POKETYPE.POKE_BOMB;
            self.mainValue = self.cardList[1].PValue;
        elseif self.countItem.maxCount == 3 then
            self.type = POKETYPE.POKE_THREEBELTONE;
            for k,v in pairs(self.countItem.countMap) do
                if v == 3 then
                    self.mainValue = k;
                end
            end
        end
    -- 三带二 333KK / 单顺子 34567
    elseif len == 5 then            
        if self.countItem.cardCount == 5 and self.countItem.maxCount == 1 then
            if self:IsShunZi(self.cardList) then
                self.type = POKETYPE.POKE_SHUNZI;
                self:GetShunziMainValue();
            end
        elseif self.countItem.maxCount == 3 and self.countItem.cardCount == 2 then
            self.type = POKETYPE.POKE_THREEBELTSUB;
            for k,v in pairs(self.countItem.countMap) do
                if v == 3 then
                    self.mainValue = k;
                end
            end
        end
    -- 四带二 333344 / 顺子345678 / 双顺 334455 / 三顺 444555
    elseif len == 6 then        
        if self.countItem.maxCount == 4 then
            self.type = POKETYPE.POKE_BOMBADDSIN;
            for k,v in pairs(self.countItem.countMap) do
                if v == 4 then
                    self.mainValue = k;
                end
            end
        elseif self.countItem.cardCount == 6 and self:IsShunZi(self.cardList) then
            self.type = POKETYPE.POKE_SHUNZI;
            self.mainValue = self.cardList[1].PValue;
            self:GetShunziMainValue();
        elseif self.countItem.maxCount == 3 and self.countItem.cardCount == 2 then
            self.type = POKETYPE.POKE_THREESHUNZI;            
            self:GetShunziMainValue();
        elseif self.countItem.maxCount == 2 and self.countItem.cardCount == 3 and self:IsDoubleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_SUBSHUNZI;            
            self:GetShunziMainValue();
        end
    -- 只能是顺子 3456789
    elseif len == 7 then            
        if self.countItem.cardCount == 7 and self:IsShunZi(self.cardList) then
            self.type = POKETYPE.POKE_SHUNZI;  
            self:GetShunziMainValue();                  
        end
    -- 四带两对 55556677 /飞机带单翅膀 55566678 /顺子 45678910J / 双顺 44556677
    elseif len == 8 then                
        if self.countItem.cardCount == 8 and self:IsShunZi(self.cardList) then
            self.type = POKETYPE.POKE_SHUNZI;
            self:GetShunziMainValue();
        elseif self.countItem.maxCount == 4 then
            if self:IsFourWithDoubleTwo(self.countItem) then
                self.type = POKETYPE.POKE_BOMBADDSUM;
                for k,v in pairs(self.countItem.countMap) do
                    if v == 4 then
                        self.mainValue = k;
                    end
                end
            elseif self:IsSingleBattlePlaneV2(self.countItem) then
                self.type = POKETYPE.POKE_PLANEADDSIN;
                self.mainValue = 100;
                for k,v in pairs(self.countItem.countMap) do
                    if v >= 3 then
                        if k < self.mainValue then
                            self.mainValue = k;
                        end
                    end
                end
            end
        elseif self.countItem.maxCount == 3 and self:IsSingleBattlePlane(self.countItem) then
            self.type = POKETYPE.POKE_PLANEADDSIN;
            self.mainValue = 100;
            for k,v in pairs(self.countItem.countMap) do
                if v == 3 then
                    if k < self.mainValue then
                        self.mainValue = k;
                    end
                end
            end
        elseif self.countItem.maxCount == 2 and self.countItem.cardCount == 4 and self:IsDoubleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_SUBSHUNZI;
            self:GetShunziMainValue();
        end
    -- 三顺333444555 / 顺子
    elseif len == 9 then        
        if self.countItem.cardCount == 9 and self:IsShunZi(self.cardList) then
            self.type = POKETYPE.POKE_SHUNZI;
            self:GetShunziMainValue();
        elseif self.countItem.maxCount == 3 and self.countItem.cardCount == 3 and self:IsTrippleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_THREESHUNZI;
            self.mainValue = self.cardList[1].PValue;
        end
    -- 双飞机如 333444JJQQ / 单顺子 / 双顺子
    elseif len == 10 then        
        if self.countItem.cardCount == 10 and self:IsShunZi(self.cardList) then
            self.type = POKETYPE.POKE_SHUNZI;
            self:GetShunziMainValue();
        elseif self.countItem.maxCount == 2 and self.countItem.cardCount == 5 and self:IsDoubleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_SUBSHUNZI;
            self:GetShunziMainValue();
        elseif self.countItem.maxCount == 4 and self.countItem.cardCount == 3 and self:IsDoubleBattlePlane(self.countItem) then
            self.type = POKETYPE.POKE_PLANEADDSUM;
            self.mainValue = 100;
            for k,v in pairs(self.countItem.countMap) do
                if v == 3 then
                    if k < self.mainValue then
                        self.mainValue = k;
                    end
                end
            end
        elseif self.countItem.maxCount == 3 and self.countItem.cardCount == 4 and self:IsDoubleBattlePlane(self.countItem) then
            self.type = POKETYPE.POKE_PLANEADDSUM;
            self.mainValue = 100;
            for k,v in pairs(self.countItem.countMap) do
                if v == 3 then
                    if k < self.mainValue then
                        self.mainValue = k;
                    end
                end
            end
        end
    -- 顺子
    elseif len == 11 then        
        if self.countItem.cardCount == 11 and self:IsShunZi(self.cardList) then
            self.type = POKETYPE.POKE_SHUNZI;
            self:GetShunziMainValue();
        end
    -- 顺子 / 三顺 /双顺 / 三飞机带单翅
    elseif len == 12 then        
        if self.countItem.cardCount == 12 and self:IsShunZi(self.cardList) then
            self.type = POKETYPE.POKE_SHUNZI;
            self:GetShunziMainValue();
        elseif self.countItem.cardCount == 6 and self:IsDoubleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_SUBSHUNZI;
            self:GetShunziMainValue();
        elseif self.countItem.cardCount == 4 and self:IsTrippleShunzi(self.countItem) then
            self.type =  POKETYPE.POKE_THREESHUNZI;
            self:GetShunziMainValue();
        elseif self.countItem.maxCount == 3 and self:IsSingleBattlePlane(self.countItem) then
            self.type = POKETYPE.POKE_PLANEADDSIN;
            self.mainValue = 100;
            for k,v in pairs(self.countItem.countMap) do                
                if v == 3 then
                    if k < self.mainValue then
                        self.mainValue = k;
                    end
                end
            end
        end                           
    elseif len == 13 then
        self.type = POKETYPE.POKE_INVALID;
    -- 双顺
    elseif len == 14 then        
        if self.countItem.cardCount == 7 and self:IsDoubleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_SUBSHUNZI;
            self:GetShunziMainValue();
        end
    -- 三顺 / 三飞机带双翅膀
    elseif len == 15 then        
        if self.countItem.cardCount == 5 and self:IsTrippleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_THREESHUNZI;
            self:GetShunziMainValue();
        elseif self:IsDoubleBattlePlane(self.countItem) then
            self.type = POKETYPE.POKE_PLANEADDSUM;
        end
        for k,v in pairs(self.countItem.countMap) do
            if v == 3 then
                if k < self.mainValue then
                    self.mainValue = k;
                end
            end
        end
    -- 双顺 / 三飞机带单翅 
    elseif len == 16 then        
        if self.countItem.cardCount == 8 and self:IsDoubleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_SUBSHUNZI;
            self:GetShunziMainValue();
        elseif self:IsSingleBattlePlane(self.countItem) then
            self.type = POKETYPE.POKE_PLANEADDSIN;
            for k,v in pairs(self.countItem.countMap) do
                if v == 3 then
                    if k < self.mainValue then
                        self.mainValue = k;
                    end
                end
            end
        end
    elseif len == 17 then
        self.type = POKETYPE.POKE_INVALID;
    -- 双顺
    elseif len == 18 then
        if self.countItem.cardCount == 9 and self:IsDoubleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_SUBSHUNZI;
            self:GetShunziMainValue();
        end
    elseif len == 19 then
        self.type = POKE_INVALID;
    -- 双顺 / 飞机带单翅 / 飞机带双翅
    elseif len == 20 then
        if self.countItem.cardCount == 10 and self:IsDoubleShunzi(self.countItem) then
            self.type = POKETYPE.POKE_SUBSHUNZI;
            self:GetShunziMainValue();
        elseif self:IsSingleBattlePlane(self.countItem) then
            self.type = POKETYPE.POKE_PLANEADDSIN;
            for k,v in pairs(self.countItem.countMap) do
                if v == 3 then
                    if k < self.mainValue then
                        self.mainValue = k;
                    end
                end
            end
        elseif self:IsDoubleBattlePlane(self.countItem) then
            self.type = POKETYPE.POKE_PLANEADDSUM;
            for k,v in pairs(self.countItem.countMap) do
                if v == 3 then
                    if k < self.mainValue then
                        self.mainValue = k;
                    end
                end
            end
        end
    end
    return self.type;    
end

function PokeCardComb:GetShunziMainValue()
    self.mainValue = self.cardList[1].PValue;
    for k,v in pairs(self.cardList) do        
        if v.PValue < self.mainValue then
            self.mainValue = v.PValue;
        end
    end
end

-- 双顺
function PokeCardComb:IsDoubleShunzi(countItem)
    local result = false;
    if countItem then
        if countItem.maxCount == 2 and countItem.maxCount * countItem.cardCount == countItem.totalCount then
            result = IsCardSequent(countItem.valueList);
        end
    end
    return result;
end

-- 三顺
function PokeCardComb:IsTrippleShunzi(countItem)    
    local result = false;
    if countItem then
        if countItem.maxCount == 3 and countItem.maxCount * countItem.cardCount == countItem.totalCount then
            result = IsCardSequent(countItem.valueList);            
        end
    end

    return result;
end

-- 双炸弹作为四带二对，如55558888
function PokeCardComb:IsDoubleBomb(countItem)
    local result = false;
    if countItem then
        if countItem.maxCount == 4 and countItem.cardCount == 2 then
            result = true;
        end
    end
    return result;
end

-- 单飞机特例 33344449
function PokeCardComb:IsSingleBattlePlaneV2(countItem)
    logError("[PokeCardComb.IsSingleBattlePlaneV2]"..TableContentStr(countItem));
    local result = false;    
    -- 单牌数量
    local singleNum = 0;
    local planeCardList = {};
    if countItem then
        --33334444 不是飞机
        --[[
        if table.getn(countItem.valueList) * 4 == countItem.totalCount then
            return false;
        end
        ]]
        local i=1;
        for k,v in pairs(countItem.countMap) do
            if v == 3 then
                planeCardList[i] = k;
                i = i + 1;
            elseif v == 4 then
                planeCardList[i] = k;
                i = i + 1;
                singleNum = singleNum + (4-3);
            else
                singleNum = singleNum + v;
            end
        end        
        result = (singleNum == i-1 and IsCardSequent(planeCardList));        
    end
    return result;    
end

-- 单飞机 33344456 333444555678 333444555666789J
function PokeCardComb:IsSingleBattlePlane(countItem)
    local result = false;
    -- 单牌数量
    local singleNum = 0;
    local planeCardList = {};
    if countItem then
        
        local i=1;
        for k,v in pairs(countItem.countMap) do
            if v == 3 then
                planeCardList[i] = k;
                i = i + 1;
            else
                singleNum = singleNum + v;
            end
        end                 
        result = (singleNum == i-1 and IsCardSequent(planeCardList));        
    end
    return result;
end

-- 双飞机 3334445566 333444555667788
function PokeCardComb:IsDoubleBattlePlane(countItem)
    local result = false;
    if countItem then        
        local planeCardList = {};
        local otherPairNum = 0;
        local i = 1;
        for k, v in pairs(countItem.countMap) do
            if v == 3 then
                planeCardList[i] = k;
                i = i + 1;
            elseif v == 2 then
                otherPairNum = otherPairNum + 1;                    
            elseif v == 4 then
                otherPairNum = otherPairNum + 2;
            else
                result = false;
            end
        end
        local seq = IsCardSequent(planeCardList);             
        result = (IsCardSequent(planeCardList) and otherPairNum == i-1);
    end   
    return result; 
end

-- 四带两对
function PokeCardComb:IsFourWithDoubleTwo(countItem)
    local result = false;
    if countItem then        
        if countItem.maxCount == 4 then
            if countItem.cardCount == 3 then
                if countItem:GetNumWithCardCount(4) == 1 and countItem:GetNumWithCardCount(2) == 2 then
                    result = true;
                end
            elseif countItem.cardCount == 2 and countItem:GetNumWithCardCount(4) == 2 then
                result = true;
            end
        end
    end
    return result;
end


function PokeCardComb:IsShunZi(cardList)
    local valueList = {};
    local count = 1;
    for k, v in pairs(cardList) do
        valueList[count] = v.PValue;
        count = count + 1;
    end
    return IsCardSequent(valueList);
end

function PokeCardComb:GetServerValueList()
    local valueList = {};
    local index = 1;
    for k,v in pairs(self.cardList) do
        valueList[index] = v.Value;
        index = index + 1;
    end
    return valueList;
end

function PokeCardComb:GetDescription()
    local str = "";
    for k,v in pairs(self.cardList) do
        str = str..v:GetString().."|";
    end
    return str;
end

function PokeCardComb:SortAsServerRule()

    -- 单牌/双牌/三牌/炸弹/火箭，顺序无所谓
    if self.type == POKETYPE.POKE_SINGLECARD or self.type == POKETYPE.POKE_SUB or self.type == POKETYPE.POKE_THREECARDS or self.type == POKETYPE.POKE_ROCKET or self.type == POKETYPE.POKE_BOMB then

        --return self:GetServerValueList();

    -- 单顺/双顺/三顺 按照升序排列既可
    elseif self.type == POKETYPE.POKE_SHUNZI or self.type == POKETYPE.POKE_SUBSHUNZI or self.type == POKETYPE.POKE_THREESHUNZI then
        table.sort(self.cardList, 
        function(a, b)
            if a.PValue == b.PValue then
                return a.HuaSe > b.HuaSe;
            else
                return a.PValue < b.PValue;
            end
        end);
    -- 三带一/三带二/四带二 同点数数量多的牌排前面
    elseif self.type == POKETYPE.POKE_THREEBELTONE or self.type == POKETYPE.POKE_THREEBELTSUB or self.type == POKETYPE.POKE_BOMBADDSIN then
        table.sort(self.cardList,
            function(a, b)
                return self.countItem.countMap[a.value] > self.countItem.countMap[b.value];
            end);  
    --飞机单翅/飞机双翅 根据点数数量排，点数数量相同，根据value大小升序
    elseif self.type == POKETYPE.POKE_PLANEADDSUM or self.type == POKETYPE.POKE_PLANEADDSIN then
    table.sort(self.cardList,
        function(a, b)
            -- CLUBS               =1,                 --梅花
            -- DIAMONDS            =2,                 --方块
            -- HEARTS              =3,                 --红星
            -- SPADES              =4,                 --黑桃
            if self.countItem.countMap[a.PValue] == 4 and a.HuaSe == POKEHuaSe.CLUBS then
                return false;
            elseif self.countItem.countMap[b.PValue] == 4 and b.HuaSe == POKEHuaSe.CLUBS then
                return true;
            elseif self.countItem.countMap[a.PValue] == 4 and a.HuaSe == POKEHuaSe.DIAMONDS then
                return false;
            elseif self.countItem.countMap[b.PValue] == 4 and b.HuaSe == POKEHuaSe.DIAMONDS then
                return true;
            elseif self.countItem.countMap[a.PValue] == 4 and a.HuaSe == POKEHuaSe.HEARTS then
                return false;
            elseif self.countItem.countMap[b.PValue] == 4 and b.HuaSe == POKEHuaSe.HEARTS then
                return true;
            elseif self.countItem.countMap[a.PValue] == 4 and a.HuaSe == POKEHuaSe.SPADES then
                return false;
            elseif self.countItem.countMap[b.PValue] == 4 and b.HuaSe == POKEHuaSe.SPADES then
                return true;
            else
                if self.countItem.countMap[a.PValue] > 2 and self.countItem.countMap[b.PValue] <= 2 then
                    return true;
                elseif self.countItem.countMap[a.PValue] <=2 and  self.countItem.countMap[b.PValue] > 2 then
                    return false;
                else
                    return a.PValue < b.PValue;
                end
            end
        end);
    -- 4带2对
    elseif self.type == POKETYPE.POKE_BOMBADDSUM then        
    table.sort(self.cardList, 
        function(a, b)
            local ret = true;                                
            if a.PValue == b.PValue then                    
                ret = a.HuaSe < b.HuaSe;
            elseif self.countItem.countMap[a.PValue] == self.countItem.countMap[b.PValue] then                    
                ret = a.PValue > b.PValue;
            else
                ret = self.countItem.countMap[a.PValue] > self.countItem.countMap[b.PValue];
            end            
            return ret;
        end);
    end
end


DDZOverTaker = class()

function DDZOverTaker:ctor(cardList)

	self.rocket = {};	
    self.cardList = cardList;

    -- key 为牌张数，value为张数为key的所有牌列表
    self.countList = {[1] = {},[2] = {}, [3] = {}, [4]={}};

    -- key 为点数，value 为对应点数的所有牌列表
   	self.valueMap = {};
    for k,v in pairs(self.cardList) do        
        if self.valueMap[v.PValue] == nil then    
            self.valueMap[v.PValue] = {};
        end

        table.insert(self.valueMap[v.PValue], v);
    end

    for k, v in pairs(self.valueMap) do        
        table.insert(self.countList[table.getn(v)], v);
    end   

    for k, v in pairs(self.countList) do
        --logError(tostring(k).."="..TableContentStr(v));
        SortCardListListAsc(v);
    end
    
	for k,v in pairs(self.countList[1]) do		
		if v[1].HuaSe == POKEHuaSe.King then			
			table.insert(self.rocket, v[1]);
		end
	end
end

function DDZOverTaker:InnerGetShunZi(mainValue, length)	
	local list = {};

	if table.getn(self.cardList) < length then
		return list;
	end

	for i=mainValue,POKEVALUE.VALUE_A - length + 1,1 do
		local valueList = self.valueMap[i];		
		local tempList = {};
		if valueList and table.getn(valueList) > 0 then
			for j=i,i+length-1,1 do				
				if self.valueMap[j] and table.getn(self.valueMap[j]) > 0 then
					table.insert(tempList, self.valueMap[j][1]);
				else
					break;
				end
			end
		end	
		
		if table.getn(tempList) == length then
			table.insert(list, tempList);
		end	
	end


	return list;
end

function DDZOverTaker:InnerGetDoubleShunzi(mainValue, length)
	--log("[DDZOverTaker.InnerGetDoubleShunzi]mainValue="..tostring(mainValue)..",length="..tostring(length));
	local list = {};
	if table.getn(self.cardList) < length * 2 then
		return list;
	end

	for i=mainValue,POKEVALUE.VALUE_A - length + 1,1 do
		local valueList = self.valueMap[i];		
		local tempList = {};
		if valueList and table.getn(valueList) > 0 then
			for j=i,i+length-1,1 do				
				if self.valueMap[j] and table.getn(self.valueMap[j]) > 1 then
					table.insert(tempList, self.valueMap[j][1]);
					table.insert(tempList, self.valueMap[j][2]);
				else
					break;
				end
			end
		end	
		
		if table.getn(tempList) == length * 2 then
			table.insert(list, tempList);
		end	
	end


	return list;
end

function DDZOverTaker:InnerGetTrippleShunzi(mainValue, length)
	local list = {};
	if table.getn(self.cardList) < length * 3 then
		return list;
	end

	for i=mainValue,POKEVALUE.VALUE_A - length + 1,1 do
		local valueList = self.valueMap[i];		
		local tempList = {};
		if valueList and table.getn(valueList) > 0 then
			for j=i,i+length-1,1 do				
				if self.valueMap[j] and table.getn(self.valueMap[j]) > 2 then
					table.insert(tempList, self.valueMap[j][1]);
					table.insert(tempList, self.valueMap[j][2]);
					table.insert(tempList, self.valueMap[j][3]);
				else
					break;
				end
			end
		end	
		
		if table.getn(tempList) == length * 3 then
			table.insert(list, tempList);
		end	
	end

	return list;
end

function DDZOverTaker:CanTake(myValue, otherValue)
	if myValue == POKEVALUE.VALUE_LW or myValue == POKEVALUE.VALUE_BW then
		myValue = myValue + POKEVALUE.VALUE_2;
	end

	if otherValue == POKEVALUE.VALUE_LW or otherValue == POKEVALUE.VALUE_BW then
		otherValue = otherValue + POKEVALUE.VALUE_2;
	end

	return myValue > otherValue;
end

-- 获取点数大于 mainValue 的所有单牌列表
-- 如果存在满足条件的单牌，把所有单牌取出
-- 如果不存在，取出剩余牌中满足条件的最小点数的一张
function DDZOverTaker:InnerGetTakeOverSingle(mainValue)
	local list = {};
	-- 取出所有单牌
    for k,v in pairs(self.countList[1]) do
    	local myValue = v[1].PValue;
    	if self:CanTake(myValue, mainValue) then
    		table.insert(list, v);
    	end
    end       

    -- 如果没有单牌，在双牌/3个或4个的组合中取最小的一个
    local index = 2;
    while (table.getn(list) == 0 and index <= 4) do    	
    	for k,v in pairs(self.countList[index]) do
    		local myValue = v[1].PValue;        		
    		if self:CanTake(myValue, mainValue) then
    			table.insert(list, {v[1]});
    			break;
    		end        	        		
    	end

		if table.getn(list) > 0 then
			break;
		end
    	index = index + 1;
    end

    return list;
end


-- 获取点数大于 mainValue 的所有双牌列表
-- 如果存在满足条件的双牌，把所有对子取出
-- 如果不存在，取出剩余排中满足条件的最小点数的两张
function DDZOverTaker:InnerGetTakeOverDouble(mainValue)
	local list = {};
	for k,v in pairs(self.countList[2]) do
		local myValue = v[1].PValue;
		if self:CanTake(myValue, mainValue) then
			table.insert(list, v);
		end
	end    

	local index = 3;
	while (table.getn(list) == 0 and index <= 4) do
		for k,v in pairs(self.countList[index]) do
			local myValue = v[1].PValue;
			if self:CanTake(myValue, mainValue) then
				table.insert(list, {v[1], v[2]});
				break;
			end
		end

		if table.getn(list) > 0 then
			break;
		end

		index = index + 1;
	end    

    return list;	
end

function DDZOverTaker:InnerGetTakeOverTripple(mainValue)
	local list = {};
	for k,v in pairs(self.countList[3]) do
    	local myValue = v[1].PValue;
    	if self:CanTake(myValue, mainValue) then
    		table.insert(list, v);
    	end
    end
    
    if table.getn(list) == 0 then
    	for k,v in pairs(self.countList[4]) do
    		local myValue = v[1].PValue;
    		if self:CanTake(myValue, mainValue) then
    			table.insert(list, {v[1], v[2], v[3]});
    			break;
    		end
    	end
    end

    return list;
end

function DDZOverTaker:InnerGetTakeOverTrippleOne(mainValue)
	local list = {};
	local trippleList = self:InnerGetTakeOverTripple(mainValue);
    if table.getn(trippleList) > 0 then
    	local singleList = self:InnerGetTakeOverSingle(0);

    	if table.getn(singleList) > 0 then
    		for k,v in pairs(trippleList) do
    			local tempList = TableCopy(v);
    			for kk, vv in pairs(singleList) do
    				if v[1].PValue ~= vv[1].PValue then
    					table.insert(tempList, vv[1]);
    					break;
    				end
    			end

    			if table.getn(tempList) == 4 then
    				table.insert(list, tempList);
    			end
    		end
    	end
    end

    return list;
end

function DDZOverTaker:InnerGetTakeOverTrippleTwo(mainValue)
	local list = {};
	local trippleList = self:InnerGetTakeOverTripple(mainValue);    	
    if table.getn(trippleList) > 0 then
    	local doubleList = self:InnerGetTakeOverDouble(0);        
    	if table.getn(doubleList) > 0 then
    		for k,v in pairs(trippleList) do
    			local tempList = TableCopy(v);
    			for kk, vv in pairs(doubleList) do
    				if v[1].PValue ~= vv[1].PValue then
    					table.insert(tempList, vv[1]);
    					table.insert(tempList, vv[2]);
    					break;
    				end
    			end

    			if table.getn(tempList) == 5 then
    				table.insert(list, tempList);
    			end
    		end
    	end
    end

    return list;
end

function DDZOverTaker:InnerGetTakeOverBomb(mainValue)
	local list = {};
	for k, v in pairs(self.countList[4]) do
    	local myValue = v[1].PValue;
    	if self:CanTake(myValue, mainValue) then
    		table.insert(list, TableCopy(v));
    	end
    end

    return list;
end

function DDZOverTaker:InnerGetPlaneWithSingle(mainValue, length)

	log("[DDZOverTaker.InnerGetPlaneWithSingle]"..tostring(mainValue)..","..tostring(length));
	local list = {};
	if table.getn(self.cardList) < length then
		return list;
	end

	-- 先取出三顺
	local planeLen = length / 4;
	local headList = self:InnerGetTrippleShunzi(mainValue, planeLen);
	
	if table.getn(headList) <= 0 then		
		return list;
	end

	-- 再取对应数量的单牌
	local index = 1;
	local singleList = self:_GetSingleCards(headList, planeLen);

	log("len="..tostring(table.getn(singleList))..","..tostring(planeLen));
	log("table="..TableContentStr(singleList));
	if table.getn(singleList) < planeLen then
		return list;
	end

	for k,v in pairs(headList) do
		for kk, vv in pairs(singleList) do
			table.insert(v, vv);
		end
	end	

	list = headList;
	return list;
end

-- 获取length对双牌
function DDZOverTaker:_GetDoubleCards(exludeList, length)
	-- 再取对应数量的单牌
	local index = 2;
	local doubleList = {};
	while table.getn(doubleList) < length * 2 and index <= 4 do		
		for k,v in pairs(self.countList[index]) do
			if self:ContainsCard(exludeList, v[1]) == false then		
				table.insert(doubleList, v[1]);
				table.insert(doubleList, v[2]);
			end
			if table.getn(doubleList) == length * 2 then
				break;
			end
		end

		if table.getn(doubleList) >= length * 2 then			
			break;
		end

		index = index + 1;
	end

	return doubleList;
end

-- 获取length张单牌
function DDZOverTaker:_GetSingleCards(exludeList, length)
	local singleList = {};
	local index = 1
	while table.getn(singleList) < length and index <= 4 do
		for k,v in pairs(self.countList[index]) do
			if self:ContainsCard(exludeList, v[1]) == false then
				table.insert(singleList, v[1]);
			end

			if table.getn(singleList) == length then
				break;
			end
		end

		if table.getn(singleList) >= length then

			break;
		end

		index = index + 1;
	end

	return singleList;
end

function DDZOverTaker:InnerGetPlaneWithDouble(mainValue, length)

	--log("[DDZOverTaker.InnerGetPlaneWithDouble]"..tostring(mainValue)..","..tostring(length));
	local list = {};
	if table.getn(self.cardList) < length then
		return list;
	end

	-- 先取出三顺
	local planeLen = length / 5;
	local headList = self:InnerGetTrippleShunzi(mainValue, planeLen);
	
	if table.getn(headList) <= 0 then		
		return list;
	end

	local doubleList = self:_GetDoubleCards(headList, planeLen);
	if table.getn(doubleList) < planeLen * 2 then
		return list;
	end

	for k,v in pairs(headList) do
		for kk, vv in pairs(doubleList) do
			table.insert(v, vv);
		end
	end	

	list = headList;
	return list;
end

function DDZOverTaker:InnerGetBombWithSingle(mainValue, length)
	local list = {};
	if table.getn(self.cardList) < length then
		return list;
	end

	local bombList = self:InnerGetTakeOverBomb(mainValue);
	if table.getn(bombList) <= 0 then
		return list;
	end

	local singleList = self:_GetSingleCards(bombList, 2);
	if table.getn(singleList) < 2 then
		return list;
	end

	for k,v in pairs(bombList) do
		for kk, vv in pairs(singleList) do
			table.insert(v, vv);
		end
	end

	list = bombList;
	return list;

end

function DDZOverTaker:InnerGetBombWithDouble(mainValue, length)
	local list = {};
	if table.getn(self.cardList) < length then
		return list;
	end

	local bombList = self:InnerGetTakeOverBomb(mainValue);
	if table.getn(bombList) <= 0 then
		return list;
	end

	local doubleList = self:_GetDoubleCards(bombList, 2);
	if table.getn(doubleList) < 2 then
		return list;
	end

	for k,v in pairs(bombList) do
		for kk, vv in pairs(doubleList) do
			table.insert(v, vv);
		end
	end

	list = bombList;
	return list;
end

function DDZOverTaker:ContainsCard(list, card)
	for k,v in pairs(list) do
		for kk, vv in pairs(v) do
			if vv.PValue == card.PValue then
				return true;
			end
		end
	end

	return false;
end

-- 取能大过牌型为comb的牌的列表
function DDZOverTaker:GetTakeOverList(comb)        
    local list = {};

    if comb == nil then
    	return {self:GetRecommendList()};
    end          

    local combType = comb.type;
    local mainValue = comb.mainValue;

    --log("[DDZOverTaker.GetTakeOverList]type="..tostring(combType)..",value="..tostring(mainValue));
    if combType == POKETYPE.POKE_ROCKET then
        list = {};    
    elseif combType == POKETYPE.POKE_BOMB then
        list = self:InnerGetTakeOverBomb(mainValue);
       
        if table.getn(self.rocket) == 2 then
        	table.insert(list, self.rocket);
        end
    elseif combType == POKETYPE.POKE_SINGLECARD then
    	list = self:InnerGetTakeOverSingle(mainValue);

    elseif combType == POKETYPE.POKE_SUB then
    	list = self:InnerGetTakeOverDouble(mainValue);

    elseif combType == POKETYPE.POKE_THREECARDS then    	
        list = self:InnerGetTakeOverTripple(mainValue);

    elseif combType == POKETYPE.POKE_THREEBELTONE then
        list = self:InnerGetTakeOverTrippleOne(mainValue);

    elseif combType == POKETYPE.POKE_THREEBELTSUB then    	
    	list = self:InnerGetTakeOverTrippleTwo(mainValue);
    elseif combType == POKETYPE.POKE_SHUNZI then
    	list = self:InnerGetShunZi(mainValue + 1, comb.length);

    elseif combType == POKETYPE.POKE_SUBSHUNZI then
    	list = self:InnerGetDoubleShunzi(mainValue + 1, comb.length / 2)

    elseif combType == POKETYPE.POKE_THREESHUNZI then
    	list = self:InnerGetTrippleShunzi(mainValue + 1, comb.length / 3);

    elseif combType == POKETYPE.POKE_PLANEADDSIN then
    	list = self:InnerGetPlaneWithSingle(mainValue + 1, comb.length);

    elseif combType == POKETYPE.POKE_PLANEADDSUM then
    	list = self:InnerGetPlaneWithDouble(mainValue + 1, comb.length);
    elseif combType == POKETYPE.POKE_BOMBADDSIN then
    	list = self:InnerGetBombWithSingle(mainValue + 1, comb.length);    	
    elseif combType == POKETYPE.POKE_BOMBADDSUM then
    	list = self:InnerGetBombWithDouble(mainValue + 1, comb.length);
    end


    -- 把所有炸弹放到最后
    if combType ~= POKETYPE.POKE_ROCKET and combType ~= POKETYPE.POKE_BOMB then
    	local bombList = self:InnerGetTakeOverBomb(0);
    	for k, v in pairs(bombList) do
    		table.insert(list, v);
    	end

    	if table.getn(self.rocket) == 2 then
        	table.insert(list, self.rocket);
        end
    end

    return list;
end

function DDZOverTaker:GetRecommendList()
	local list = {};
	local len = table.getn(self.cardList);

	local mainValue = 0;
	-- 双飞机
	if len >= 10 then		
		local planeLen = math.floor(len / 5);
		for i=planeLen,2,-1 do
			list = self:InnerGetPlaneWithDouble(mainValue, i * 5);
			if table.getn(list) > 0 then
				return list[1];
			end
		end
	end

	if len >= 8 then
		-- 单飞机
		local planeLen = math.floor(len / 4);
		for i=planeLen,2,-1 do
			list =self:InnerGetPlaneWithSingle(mainValue, i * 4);
			if table.getn(list) > 0 then
				return list[1];
			end
		end

		-- 四带二对		
		list = self:InnerGetBombWithDouble(mainValue, 8);
		if table.getn(list) > 0 then
			return list[1];
		end
	end

	-- 连对
	if len >= 6 then
		local doubleLen = math.floor(len / 2);
		for i=doubleLen,3, -1 do
			list = self:InnerGetDoubleShunzi(POKEVALUE.VALUE_3, i);		
			if table.getn(list) > 0 then
				return list[1];
			end
		end

		-- 四带二		
		list = self:InnerGetBombWithSingle(mainValue, 6);
		if table.getn(list) > 0 then
			return list[1];
		end

		-- 三顺
		local trippleLen = math.floor(len / 3);
		for i = trippleLen,2,-1 do
			list = self:InnerGetTrippleShunzi(POKEVALUE.VALUE_3, i);
			if table.getn(list) > 0 then
				return list[1];
			end
		end

	end

	-- 顺子
	if len >= 5 then

		local mainValue = POKEVALUE.VALUE_3;		
		for i=len,5,-1 do
			list = self:InnerGetShunZi(mainValue, i);
			if table.getn(list) > 0 then
				return list[1];
			end
		end
	end

	-- 炸弹
	list = self:InnerGetTakeOverBomb(mainValue);
	if table.getn(list) > 0 then
		return list[1];
	end

	-- 三带二
	list = self:InnerGetTakeOverTrippleTwo(mainValue);
	if table.getn(list) > 0 then
		return list[1];
	end

	-- 三带一
	list = self:InnerGetTakeOverTrippleOne(mainValue);
	if table.getn(list) > 0 then
		return list[1];
	end
	
	-- 三张
	list = self:InnerGetTakeOverTripple(mainValue);
	if table.getn(list) > 0 then
		return list[1];
	end

	-- 双牌
	list = self:InnerGetTakeOverDouble(mainValue);
	if table.getn(list) > 0 then
		return list[1];
	end

	-- 单牌		
	list = self:InnerGetTakeOverSingle(mainValue);
	if table.getn(list) > 0 then
		return list[1];
	end	
end


-- 传入参数
function SortCardListListAsc(cardListMap)    
    table.sort(cardListMap,
    function(a, b)
        if a[1].HuaSe == POKEHuaSe.King and b[1].HuaSe == POKEHuaSe.King then
            return a[1].PValue < b[1].PValue;
        elseif a[1].HuaSe == POKEHuaSe.King and b[1].HuaSe ~= POKEHuaSe.King then
            return false;
        elseif a[1].HuaSe ~= POKEHuaSe.King and b[1].HuaSe == POKEHuaSe.King then
            return true;
        elseif a[1].PValue == b[1].PValue then
            return a[1].HuaSe < b[1].HuaSe;
        else
            return a[1].PValue < b[1].PValue;
        end
    end)
end