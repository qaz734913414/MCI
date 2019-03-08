--加载玩家UI对象
function ZhengZhouMJMainView:LoadGPSView()
    self.GPS = {}
    self.GPS.Pos = {}
    self.GPS.Lines = {}
    for i= 2,4 do
        self.GPS.Pos[i] = {};
        self.GPS.Pos[i].PosSgin = self:Find("GPSView/"..tostring(i).."/PosSgin")
        self.GPS.Pos[i].NoPosSgin = self:Find("GPSView/"..tostring(i).."/NoPosSgin")
        self.GPS.Pos[i].PosSgin1 = self:Find("GPSView/"..tostring(i).."/PosSgin1")
    end
    for i=2,3 do
        for j=i+1,4 do
            local key = i.."to"..j
            self.GPS.Lines[key] = {}
            self.GPS.Lines[key].Line = self:Find("GPSView/"..key)
            self.GPS.Lines[key].Describe = self:Find("GPSView/"..key.."/Line/Text"):GetComponent("Text")
            self.GPS.Lines[key].Liner = self:Find("GPSView/"..key.."r")
            self.GPS.Lines[key].Describer = self:Find("GPSView/"..key.."r/Line/Text"):GetComponent("Text")
        end
    end
end

function ZhengZhouMJMainView:InitGPS()
    for i= 2,4 do
        self.GPS.Pos[i].PosSgin.gameObject:SetActive(false)
        self.GPS.Pos[i].NoPosSgin.gameObject:SetActive(false)
        self.GPS.Pos[i].PosSgin1.gameObject:SetActive(false)
    end
    for k,v in pairs(self.GPS.Lines) do
        v.Line.gameObject:SetActive(false)
        v.Liner.gameObject:SetActive(false)
    end
end


function ZhengZhouMJMainView:RestoreGPS(GameData)
    self:InitGPS()
    if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPNULL and GameData.IntoGameNum == 0 then        --当前第一局还未开始游戏
        if GameData.GamePlayerNum == 4 then
            for i=2,4 do
                self.GPS.Pos[i].PosSgin.gameObject:SetActive(GameData.Table.Players[i].MapPoint.IsOpenGPS)
                self.GPS.Pos[i].NoPosSgin.gameObject:SetActive(not GameData.Table.Players[i].MapPoint.IsOpenGPS)
            end
            for i=2,3 do
                for j=i+1,4 do
                    local key = i.."to"..j
                    if GameData.Table.Players[i].PlayerInfo.UserID ~= 0 and GameData.Table.Players[j].PlayerInfo.UserID ~= 0 then
                        local Type,Str = self:GPSDistance(GameData.Table.Players[i].MapPoint,GameData.Table.Players[j].MapPoint)
                        if Type == 1 or Type == 3 then
                            self.GPS.Lines[key].Line.gameObject:SetActive(true)
                            self.GPS.Lines[key].Describe.text = Str
                        else
                            self.GPS.Pos[i].PosSgin.gameObject:SetActive(false)
                            self.GPS.Pos[j].PosSgin.gameObject:SetActive(false)
                            self.GPS.Pos[i].PosSgin1.gameObject:SetActive(true)
                            self.GPS.Pos[j].PosSgin1.gameObject:SetActive(true)
                            self.GPS.Lines[key].Liner.gameObject:SetActive(true)
                            self.GPS.Lines[key].Describer.text = Str
                        end
                    else
                        self.GPS.Lines[key].Line.gameObject:SetActive(true)
                        self.GPS.Lines[key].Describe.text = "未知距离"
                    end
                end
            end
        elseif GameData.GamePlayerNum == 3 then
            self.GPS.Pos[2].PosSgin.gameObject:SetActive(GameData.Table.Players[2].MapPoint.IsOpenGPS)
            self.GPS.Pos[2].NoPosSgin.gameObject:SetActive(not GameData.Table.Players[2].MapPoint.IsOpenGPS)
            self.GPS.Pos[4].PosSgin.gameObject:SetActive(GameData.Table.Players[4].MapPoint.IsOpenGPS)
            self.GPS.Pos[4].NoPosSgin.gameObject:SetActive(not GameData.Table.Players[4].MapPoint.IsOpenGPS)
            local key = "2to4"
            if GameData.Table.Players[2].PlayerInfo.UserID ~= 0 and GameData.Table.Players[4].PlayerInfo.UserID ~= 0 then
                local Type,Str = self:GPSDistance(GameData.Table.Players[2].MapPoint,GameData.Table.Players[4].MapPoint)
                if Type == 1 or Type == 3 then
                    self.GPS.Lines[key].Line.gameObject:SetActive(true)
                    self.GPS.Lines[key].Describe.text = Str
                else
                    self.GPS.Pos[2].PosSgin.gameObject:SetActive(false)
                    self.GPS.Pos[4].PosSgin.gameObject:SetActive(false)
                    self.GPS.Pos[2].PosSgin1.gameObject:SetActive(true)
                    self.GPS.Pos[4].PosSgin1.gameObject:SetActive(true)
                    self.GPS.Lines[key].Liner.gameObject:SetActive(true)
                    self.GPS.Lines[key].Describer.text = Str
                end
            else
                self.GPS.Lines[key].Line.gameObject:SetActive(true)
                self.GPS.Lines[key].Describe.text = "未知距离"
            end
        end
    end            
end


function ZhengZhouMJMainView:GPSDistance(MapPoint1, MapPoint2)
    if MapPoint1.IsOpenGPS and MapPoint2.IsOpenGPS then
        local distance = Game.CalGPSDistance(MapPoint1.X,MapPoint1.Y, MapPoint2.X,MapPoint2.Y);
        local text = "";
        if distance >= 1000 then
            text = string.format("%.2f", distance / 1000).."公里"
        else
            text = tostring(math.floor(distance)).."米"
        end
        if distance <= 300 then
            return 2,"玩家距离过近"..text
        end
        return 1,text
    else
        return 3,"未知距离"
    end
end