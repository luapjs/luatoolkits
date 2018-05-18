--- 数与随机数
-- Anthor : canyon / 龚阳辉
-- Date : 2016-05-25 09:25
-- Desc : base : 随机数值最大值 , isSeek 是否重置随机种子
--        需要先引起(属于底层基础)
-- math.random([n [, m]]) 无参调用,产生(0,1)之间的浮点随机数,只有参数n,产生1-n之间的整数.
local math = math;
local math_random = math.random;
local math_randomseed = math.randomseed;
local math_round = math.round;
local os = os;
local string_format = string.format;

function tonum(val,base,def)
	base = base or 10;
	def = def or 0;
    return tonumber(val, base) or def;
end

function tonum16(val,def)
	return tonum(val,16,def);
end

function tonum10(val,def)
	return tonum(val,10,def);
end

function toint(val,def)
    return math_round(tonum10(val,def))
end

local M = {};

function M:onSeek()
	local _time = os.time();
	local _seed = tostring(_time):reverse():sub(1, 6);
	math_randomseed(_seed);
end

-- 保留小数
function M:retainDecimal(v,fnum)
	fnum = tonum10(fnum,2);
	if fnum > 0 then
		local fmt = "%.".. fnum .. "f"
		v = string_format(fmt, v);
		v = tonum10(v);
	end
	return v;
end

-- 产生 : 小于base的小数
function M:nextFloat(base,isSeek)
	if isSeek == true then
		self:onSeek();
	end
	base = tonum10(base,10000);
	return math_random() * base;
end

-- 产生 : 小于base的两位小数
function M:nextFloatPos2(base,isSeek)
	local _f = self:nextFloat(base,isSeek);
	return self:retainDecimal(_f);
end

-- 产生 : 整数 [1~base]
function M:nextInt(base,isSeek)
	if isSeek == true then
		self:onSeek();
	end
	base = tonum10(base,10000);
	if base <= 1 then
		return self:nextInt(2);
	end

	return math_random(base);
end

-- 产生 : 整数 [0~base)
function M:nextIntZero(base,isSeek)
	local _r = self:nextInt(base,isSeek);
	return _r - 1;
end

-- 产生 : 整数 [min~max]
function M:nextNum( min,max,isSeek )
	if isSeek == true then
		self:onSeek();
	end
	return math_random(min,max);
end

function M:nextBool()
	local _r = self:nextIntZero(2);
	return _r == 1;
end

return M;