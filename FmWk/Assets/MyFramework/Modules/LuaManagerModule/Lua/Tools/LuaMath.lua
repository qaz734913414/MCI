module ("LuaMath", package.seeall);


function Clamp(Min,Max,Value)
	if Value < Min then
		return Min
	elseif Value > Max then
		return Max
	else
		return Value
	end
end

function Lerp(Value1,Value2,Value)
	if Value <= 0 then
		return Value1
	end
	if Value >= 1 then
		return Value2
	end
	return Value1 + (Value2-Value1)*Value
end
