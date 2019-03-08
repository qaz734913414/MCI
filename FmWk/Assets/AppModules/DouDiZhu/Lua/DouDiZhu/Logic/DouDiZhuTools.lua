module("DouDiZhu", package.seeall)

local IsLog = true;

function ModelLog(Title,Msg)
    if IsLog then
        print("[DouDiZhu:"..Title.."]"..TableToStr(Msg))
    end
end

function TableToStr(t)
    local Str = ""
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            Str = Str..indent.."*"..tostring(t)
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        Str = Str..indent.."["..pos.."] = \n{"
                        sub_print_r(val,indent..string.rep(" ",2))
                        Str = Str..indent.." }\n"
                    elseif (type(val)=="string") then
                        Str = Str..indent.."["..pos..'] = "'..val..'"'
                    else
                        Str = Str..indent.."["..pos.."] => "..tostring(val)
                    end
                end
            else
                Str = Str ..indent..tostring(t)
            end
        end
    end
    if (type(t)=="table") then
        Str = Str..tostring(t).."\n{"
        sub_print_r(t," ")
        Str = Str .."}\n"
    else
        sub_print_r(t,"")
    end
    return Str
end

function TableCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[TableCopy(orig_key)] = TableCopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

