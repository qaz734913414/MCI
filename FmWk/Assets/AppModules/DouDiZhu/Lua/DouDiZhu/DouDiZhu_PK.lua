function DouDiZhuMainView:NewPk(_Obj,_Value)
    local PK = {Obj =_Obj, Value = _Value, HuaSe = 0, PValue = 0,Select = false,IsPress = false}

    PK.LoadPk = function()
        PK.PKObj = PK.Obj:GetTransform():Find("PKObj")
        PK.FaceObj = PK.PKObj:Find("PkFace")
        PK.HuaSign = PK.FaceObj:Find("HuaSign"):GetComponent("Image")
        PK.Suits1 = PK.FaceObj:Find("Suits1"):GetComponent("Image")
        PK.ValueObj = PK.FaceObj:Find("Value"):GetComponent("Image")
        PK.BackObj = PK.PKObj:Find("Back")
        PK.MaskObj = PK.PKObj:Find("Mask").gameObject
        PK.DiZhuObj = PK.PKObj:Find("DiZhu").gameObject
        PK.SetValue(PK.Value)
    end

    PK.SetValue =  function(Value)
        PK.Value = Value
        local t,v
        if Value and Value ~= 0 then
            t,v = math.modf(Value/16)
            v = v*16
            PK.BackObj.gameObject:SetActive(false)
            if t == 1 then  --梅花
                PK.HuaSign.sprite = self.DouDiZhuRes["puke_04"]
                PK.ValueObj.sprite = self.DouDiZhuRes["black_"..v]
                PK.Suits1.sprite = self.DouDiZhuRes["bigtag_1"]
                PK.HuaSign.gameObject:SetActive(true)
                PK.ValueObj:SetNativeSize()
                PK.Suits1:SetNativeSize()
            elseif t == 2 then  --方块
                PK.HuaSign.sprite = self.DouDiZhuRes["puke_02"]
                PK.ValueObj.sprite = self.DouDiZhuRes["red_"..v]
                PK.Suits1.sprite = self.DouDiZhuRes["bigtag_0"]
                PK.HuaSign.gameObject:SetActive(true)
                PK.ValueObj:SetNativeSize()
                PK.Suits1:SetNativeSize()
            elseif t == 3 then  --红星
                PK.HuaSign.sprite = self.DouDiZhuRes["puke_01"]
                PK.ValueObj.sprite = self.DouDiZhuRes["red_"..v]
                PK.Suits1.sprite = self.DouDiZhuRes["bigtag_2"]
                PK.HuaSign.gameObject:SetActive(true)
                PK.ValueObj:SetNativeSize()
                PK.Suits1:SetNativeSize()
            elseif t == 4 then  --黑桃
                PK.HuaSign.sprite = self.DouDiZhuRes["puke_03"]
                PK.ValueObj.sprite = self.DouDiZhuRes["black_"..v]
                PK.Suits1.sprite = self.DouDiZhuRes["bigtag_3"]
                PK.HuaSign.gameObject:SetActive(true)
                PK.ValueObj:SetNativeSize()
                PK.Suits1:SetNativeSize()
            elseif t == 5 then  --大小王
                v = v + 15
                PK.HuaSign.gameObject:SetActive(false)
                PK.ValueObj.sprite = self.DouDiZhuRes["pkvalue_"..v]
                PK.ValueObj:SetNativeSize()
                PK.Suits1.sprite = self.DouDiZhuRes["pk_"..v]
                PK.Suits1:SetNativeSize()
            end
        else
            t = 0
            v = 0
            PK.BackObj.gameObject:SetActive(true)
        end
        PK.HuaSe = t
        PK.PValue = v
    end

    PK.Show = function ()
        PK.Obj:SetActive(true)
    end

    PK.Hide = function () 
        PK.Obj:SetActive(false)
        PK.DiZhuObj:SetActive(false)
    end

    PK.IsShow = function()
        return PK.Obj.activeSelf
    end

    PK.SetSelect = function(IsSelect)
        PK.IsSelect = IsSelect
        if PK.IsSelect then
            PK.PKObj:DOLocalMoveY(25, 0.1)
        else
            PK.PKObj:DOLocalMoveY(0, 0.1)
        end
    end
    PK.GetSelect = function()
        return PK.IsSelect
    end
    PK.SetPress = function(IsPress)
        PK.IsPress = IsPress
        if PK.IsPress then
            PK.MaskObj:SetActive(true)
        else
            PK.MaskObj:SetActive(false)
        end
    end

    PK.GetPress = function()
        return PK.IsPress
    end

    PK.SetDiZhu = function()
        PK.DiZhuObj:SetActive(true)
    end

    PK.PlayDiPai = function()
        PK.Obj:GetTransform():DOLocalMoveY(100,0)
        PK.Obj:GetTransform():DOLocalMoveY(0, 1)
    end

    PK.LoadPk()
    return PK
end
