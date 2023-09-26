--[[
-- lua 的扩展脚本
-- Author : canyon / 龚阳辉
-- Date : 2015-05-25 09:25
-- Desc : table,string,os's TimeEx,number's NumEx
--]] --
local tostring, type, tonumber = tostring, type, tonumber
local error, select = error, select
local package, _require, setmetatable = package, require, setmetatable

local table = table
local tb_insert = table.insert
local tb_remove = table.remove
local tb_sort = table.sort
local tb_join = table.concat
local tb_concat = table.concat

local math = math;
local m_max = math.max;
local m_min = math.min;
local m_random = math.random
local m_randomseed = math.randomseed
local m_floor = math.floor
math.round = math.round or function(val)
    local nVal = m_floor(val)
    local fVal = val;
    if nVal ~= 0 then fVal = val - nVal; end
    if fVal >= 0.5 then nVal = nVal + 1; end
    return nVal;
end
local m_round = math.round
local m_modf = math.modf
math.clamp = math.clamp or function(v, minValue, maxValue)
    if v < minValue then return minValue end
    if (v > maxValue) then return maxValue end
    return v
end

local string = string
local str_format = string.format
local str_upper = string.upper
local str_len = string.len
local str_rep = string.rep
local str_find = string.find
local str_gsub = string.gsub
local str_sub = string.sub
local str_byte = string.byte
local str_char = string.char
local str_gmatch = string.gmatch

--[[
-- table 扩展
-- Author : canyon / 龚阳辉
-- Date : 2015-05-25 09:25
--]]
local _unpack = unpack or table.unpack
function unpack(arg)
    if _unpack and type(arg) == "table" then return _unpack(arg) end
end
local TEmpty = { __newindex = function(t,k,v) end }
function lfc_equal( val,obj )
    return val == obj;
end

function lfc_equalAttrKeyVal( tUnit,key,val )
    return tUnit and key and val and tUnit[key] == val
end

function lfc_equalId( val,obj )
    local _rt = (val == obj)
    if not _rt then
        if type(val) == "table" then
            local _id = nil
            if type(obj) == "table" then
                _id = obj.id
            else
                _id = obj
            end
            _rt = tostring(val.id) == tostring(_id);
        end
    end
    return _rt;
end

function lfc_greater_than( a,b )
    return a > b;
end

function table.getEmpty()
    return TEmpty
end

local function _clear(src,isDeep)
    local cnt,_tp = table.size(src);
	if cnt == 0 then
		return src;
	end
	
	for k,v in pairs(src) do
		if k ~= "__index" then
			_tp = type(v);
			if _tp ~= "function" then
				if _tp == "table" then
					if isDeep == true then
						_clear(v,isDeep);
					else
						src[k] = nil;
					end
				else
					src[k] = nil;
				end
			end
		end
	end
	return src;
end

function clearLT(src,isDeep)
	return _clear(src,isDeep) 
end

function table.clear(src,isDeep)
	return _clear(src,isDeep)
end

-- 取数组长度
function table.lens2(src)
    local cnt = 0
    if type(src) == "table" then
        cnt = #src  -- # 官方解释，取非队列数组的对象的长度不固定的
    end
    return cnt
end

-- srcIsList = true 为 取list 长度
function table.length(src,srcIsList)
    local cnt = 0
    if type(src) == "table" then
        local _func = srcIsList == true and ipairs or pairs
        for _,_ in _func(src) do
            cnt = cnt + 1;
        end
    end
    return cnt
end

-- 取数组长度
function table.lens(src)
    return table.length( src,true )
end

-- 取对象长度
function table.size(src)
    return table.length( src )
end

local function _copyTableValue(tSrc,tDest)
    if type(tSrc) ~= "table" then
        return tSrc
    end
    if table.length( tSrc ) == 0 then
        tDest = tSrc
        return tDest
    end
    tDest = type(tDest) == "table" and tDest or {}
    local _oldVal = nil
    for k, v in pairs( tSrc ) do
        if type(v) == "table" then
            _oldVal = tDest[k]
            tDest[k] = _copyTableValue( v,_oldVal )
        else
            tDest[k] = v
        end
    end
    return tDest
end

function table.copyValue(tSrc,tDest)
    return _copyTableValue( tSrc,tDest )
end

function table.deepCopy(tSrc)
    local lookup_table = {}
    local function _copy(t)
        if type(t) ~= "table" then
            return t
        elseif lookup_table[t] then
            return lookup_table[t]
        end
        local new_table = {}
        lookup_table[t] = new_table
        for index, value in pairs(t) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, _copy(getmetatable(t)))
    end
    return _copy( tSrc );
end

local function _keys_vals(src,sortFunc,isKey)
    local _ret = {};
    if type(src) == "table" then
        isKey = isKey == true;
        for k,v in pairs(src) do
            tb_insert(_ret,isKey and k or v);
        end
        if sortFunc and #_ret > 1 then
            tb_sort( _ret, sortFunc );
        end
    end
    return _ret;
end

function table.keys(src,sortFunc)
    return _keys_vals(src,sortFunc,true);
end

function table.values(src,sortFunc)
    return _keys_vals(src,sortFunc);
end

function table.isContain(src,element,srcIsList)
    if element and type(src) == "table" then
        local _func = srcIsList == true and ipairs or pairs
        for k,v in _func(src) do
            if v == element then
				return true,k,v;
            end
        end
    end
    return false
end

function table.isContainByFunc2(srcIsList,src,funcEqual,...)
    if type(funcEqual) == "function" and type(src) == "table" then
        local _func = srcIsList == true and ipairs or pairs
        for k,v in _func(src) do
            if funcEqual( v,... ) then
				return true,k,v;
            end
        end
    end
    return false
end

function table.isContainByFunc(tOrg,func,...)
    return table.isContainByFunc2( false,tOrg,func,...  )
end

function table.isContainByEquip(tOrg,obj)
    return table.isContainByFunc( tOrg,lfc_equal,obj )
end

function table.isContainByEqualById(tOrg,obj)
    return  table.isContainByFunc( tOrg,lfc_equalId,obj )
end

function table.getVKByAttribute(src,itKey,itVal,srcIsList)
    local isHas,val,key = table.isContainByFunc2( srcIsList,src,lfc_equalAttrKeyVal,itKey,itVal  )
    if isHas then
        return val,key
    end
end

function table.removeByFunc( src,func,times,... )
    local cnt = 0;
    times = tonum10(times,-1);
    if 0 ~= times and func and type(src) == "table" then
        for k,v in pairs(src) do
            if times == 0 then
                break;
            end
            if func( v,... ) then
                times = times - 1;
                cnt = cnt + 1
                src[k] = nil
            end
        end
    end
    return src,cnt;
end

function table.rmvByFunc( src,func,... )
    return table.removeByFunc( src,func,-1,... )
end

function table.removeListByFunc( src,func,times,... )
    local cnt = 0;
    times = tonum10(times,-1);
    if 0 ~= times and func and type(src) == "table" then
        for i = #src,1,-1 do
            if times == 0 then
                break;
            end

            if func( src[i],... ) then
                times = times - 1;
                cnt = cnt + 1
                tb_remove(src,i)
            end
        end
    end
    return src,cnt;
end

function table.rmvListByFunc(tList,func,...)
    return table.removeListByFunc( tList,func,-1,... )
end

function table.removeEqual(tOrg,obj,times)
    return table.removeByFunc( tOrg,lfc_equal,times,obj )
end

function table.removeEqualById(tOrg,obj,times)
    return table.removeByFunc( tOrg,lfc_equalId,times,obj )
end

function table.removeListEqual(tList,obj,times)
    return table.removeListByFunc( tList,lfc_equal,times,obj )
end

function table.removeListEqualById(tList,obj,times)
    return table.removeListByFunc( tList,lfc_equalId,times,obj )
end

function table.insertOnly(tList,obj,hasFunc)
    if obj and type(tList) == "table" then
        local _isHas = false
        if hasFunc then
            for i = #tList,1,-1 do
                if hasFunc( tList[i],obj ) then
                    _isHas = true
                    break;
                end
            end
        end
        if not _isHas then
            tb_insert( tList,obj )
        end
    end
    return tList
end

function table.insertOnlyEqual(tList,obj)
    return table.insertOnly( tList,obj,lfc_equal )
end

function table.insertOnlyEqualById(tList,obj)
    return table.insertOnly( tList,obj,lfc_equalId )
end

function table.sub(src,nBegin,nEnd)
    local _ret = {};
    for i,v in ipairs(src) do
        if i >= nBegin and i <= nEnd then
            tb_insert(_ret,v);
        end
    end
    return _ret;
end

function table.sub_page(src,page,pageCount)
    page = math_max(page,1);
    pageCount = math_max(pageCount,1);
    local nBegin = (page - 1) * pageCount + 1;
    local nEnd = nBegin + pageCount - 1;
    return table.sub(src,nBegin,nEnd);
end

function table.append(tSrc,tDest,srcIsList,funcCondition,beg)
    tDest = tDest or {}
    if type(tSrc) == "table" then
        local cnt = #tDest
        if not beg or beg > cnt then
            beg = cnt
        end
        local _func = srcIsList == true and ipairs or pairs
        for _, val in _func(tSrc) do
            if not funcCondition or funcCondition(val) then
                beg = beg + 1
                tDest[beg] = val
            end
        end
    end
    return tDest
end

function table.merge(src,dest)
    dest = dest or {}
    for k, v in pairs(src) do
        dest[k] = v
    end
    return dest;
end

function table.foreach(src,fnvk,srcIsList)
    local _func = srcIsList == true and ipairs or pairs
    for k, v in _func(src) do
        fnvk(v,k);
    end
end

function table.foreach_new(src,fnvk,srcIsList)
    local _func = srcIsList == true and ipairs or pairs
    local _ret = {}
    for k, v in _func(src) do
        _ret[k] = fnvk(v,k);
    end
    return _ret;
end

function table.filter(src,fnvk,srcIsList)
    local _func = srcIsList == true and ipairs or pairs
    local n = {}
    for k, v in _func(src) do
        if fnvk(v, k) then
            n[k] = v
        end
    end
    return n
end

function table.unique(src, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(src) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

function table.shuffle(arrTab)
    if arrTab == nil then
        return
    end
    local cnt = #arrTab;
    if cnt <= 1 then
        return arrTab;
    end
    
    local _tmp,_ret = {},{}
    for i = 1,cnt do
        tb_insert(_tmp,i);
    end

    local _nVal,_nInd;
    while cnt > 0 do
        _nInd = math_random(cnt);
        _nVal = _tmp[_nInd];
        if _nVal and arrTab[_nVal] then
            tb_insert(_ret,arrTab[_nVal]);
            tb_remove(_tmp,_nInd);
            cnt = #_tmp;
        end
    end
    return _ret;
end

-- 交集
function table.intersection(t1,t2)
    local dest = t1 or t2
    local src = (dest == t1) and t2 or t1
	if src then
        dest = dest or {}
        local _ret = {}
		for _, v1 in pairs( src ) do
            for _, v2 in pairs( dest ) do
                if v2 == v1 then
                    tb_insert( _ret,v2 )
                end
			end
		end
        return _ret
    end
    return dest
end


--[[
-- 字符串 string 扩展
-- Author : canyon / 龚阳辉
-- Date : 2015-05-25 09:25
--]]
local _htmlSpecialChars = {
    {"&", "&amp;"}, {" ", "&nbsp;"}, {"\t", "    "}, {"\"", "&quot;"},
    {"'", "&#039;"}, {"<", "&lt;"}, {">", "&gt;"}, {"\n", "<br />"}
}

local function checkstring(str)
    if type(str) ~= "string" then str = tostring(str) end
    return str
end

function string.sort(a, b)
    a = tostring(a);
    b = tostring(b);
    return str_byte(a) < str_byte(b);
end

function string.toHtml(str, isRestroe)
    for _, v in ipairs(_htmlSpecialChars) do
        if isRestroe == true then
            str = str_gsub(str, v[2], v[1]);
        else
            str = str_gsub(str, v[1], v[2]);
        end
    end
    return str;
end

function string.split(inStr, sep, sepType, useType)
    local _lt = {};
    inStr = tostring(inStr);
    if inStr == nil or inStr == "" then return _lt; end

    if sep == nil or sep == "" then
        sep = "%s";
    else
        sep = tostring(sep);
    end

    if (not sepType) then
        sep = "([^" .. sep .. "]+)";
    elseif sepType == 1 then
        sep = "[^" .. sep .. "]+";
    elseif sepType == 2 then
        sep = "(.*)" .. sep .. "(.*)"; -- 固定分隔k,v模式
    end

    if useType == 1 then
        local pos = 1;
        for nBen, nEnd in function()
            return str_find(inStr, sep, pos, true)
        end do
            tb_insert(_lt, str_sub(inStr, pos, nBen - 1))
            pos = nEnd + 1
        end
        tb_insert(_lt, str_sub(inStr, pos))
    elseif useType == 2 then
        str_gsub(inStr, sep, function(w) tb_insert(_lt, w) end)
    else
        for str, str2 in str_gmatch(inStr, sep) do
            tb_insert(_lt, str);
            if (sepType == 2) and str2 then tb_insert(_lt, str2); end
        end
    end

    return _lt;
end

function string.contains(src, val)
    local begIndex, endIndex = str_find(src, val);
    local isRet = not (not begIndex);
    return isRet, begIndex, endIndex;
end

function string.starts(src, sbeg) return str_sub(src, 1, str_len(sbeg)) == sbeg end

function string.ends(src, send)
    return send == '' or str_sub(src, -str_len(send)) == send
end

function string.replace(inStr, pat, val) return str_gsub(inStr, pat, val); end
function string.ltrim(inStr) return str_gsub(inStr, "^[ \t\n\r]+", "") end
function string.rtrim(inStr) return str_gsub(inStr, "[ \t\n\r]+$", "") end

function string.trim(inStr)
    if not inStr then return "" end
    inStr = tostring(inStr)
    inStr = str_gsub(inStr, "^%s*(.-)%s*$", "%1")
    return inStr
end

function string.upfirst(inStr)
    return str_upper(str_sub(inStr, 1, 1)) .. str_sub(inStr, 2)
end

function string.lastIndexOf(inStr, sep)
    if not sep or "" == sep or not inStr or "" == inStr then return -1; end
    local _posLast = str_find(inStr, str_format("%s[^%s]*$", sep, sep));
    return _posLast or -1;
end

function string.leftStr(inStr, sep)
    local _posLast = string.lastIndexOf(inStr, sep)
    if not _posLast or _posLast == -1 then return inStr; end
    return str_sub(inStr, 1, _posLast);
end

function string.rightStr(inStr, sep)
    local _posLast = string.lastIndexOf(inStr, sep)
    if not _posLast or _posLast == -1 then return inStr; end
    local _len = str_len( sep );
    return str_sub(inStr,_posLast + _len);
end

function string.lastStr(inStr, sep)
    local _posLast = string.lastIndexOf(inStr, sep)
    if not _posLast or _posLast == -1 then return inStr; end
    return str_gsub(inStr, str_sub(inStr, 1, _posLast), "");
end

-- 中文也是一个字符
function string.utf8len(src)
    local len = str_len(src)
    local left, cnt = len, 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local tmp, i;
    while left ~= 0 do
        tmp = str_byte(src, -left)
        i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.toStrByNum(num, lens)
    lens = tonum10(lens, 3);
    local fmt = "%0" .. lens .. "d";
    return str_format(fmt, num);
end

function string.toStr16(num, isBig)
    local fmt = isBig == true and "%X" or "%x";
    return str_format(fmt, num);
end

function string.toNum16(str) return tonum16(str) end

function string.toColRGB(str)
    str = str_gsub(str, "#", "");
    local cnt = #str;
    if cnt ~= 6 and cnt ~= 8 then return 0, 0, 0; end

    local _lb = {}
    for i = 1, cnt, 2 do
        tb_insert(_lb, string.toNum16(str_sub(str, i, i + 1)));
    end
    return unpack(_lb);
end

function string.isHasSpace(inStr)
    local _isHas = string.contains(inStr, "[ \t\n\r　]");
    return _isHas;
end

function string.csFmt2Luafmt(inStr)
    if not inStr then return "" end
    local _sbeg = string.starts
    local _send = string.ends
    local _ss = string.split(inStr, "{%d}") -- {%d([^:[D]?[%d]*])?}
    _ss = tb_join(_ss, "%s")
    if _sbeg(inStr, "{0}") then _ss = "%s" .. _ss end
    local _end = str_sub(inStr, -3)
    if _sbeg(_end, "{") and _send(_end, "}") then _ss = _ss .. "%s" end
    return _ss;
end

function string.insert(s1, pos, s2)
    s1 = checkstring(s1)
    if not s2 then return s1 end
    s2 = checkstring(s2)
    pos = pos or 1
    local len = str_len(s1)
    if pos <= 1 then
        return s2 .. s1
    elseif pos >= len + 1 then
        return s1 .. s2
    end
    local pre, suf = str_sub(s1, 1, pos - 1), str_sub(s1, pos, len)
    return pre .. s2 .. suf
end

function string.utf8insert(s1, pos, s2)
    s1 = checkstring(s1)
    if not s2 then return s1 end
    s2 = checkstring(s2)
    pos = pos or 1
    local utf8 = utf8
    local utf8len = utf8.len(s1)
    local len = str_len(s1)
    if pos <= 1 then
        return s2 .. s1
    elseif pos >= utf8len + 1 then
        return s1 .. s2
    end
    local m = utf8.offset(s1, pos)
    local pre, suf = str_sub(s1, 1, m - 1), str_sub(s1, m, len)
    return pre .. s2 .. suf
end

function string.remove(s1, pos, num)
    if not s1 then error("the argument#1 is nil!") end
    local len = str_len(s1)
    pos = pos or 1
    num = num or len
    if pos <= 1 then
        pos = 1
    elseif pos >= len + 1 then
        return s1
    end
    if num <= 0 then return s1 end
    if pos == 1 and num >= len then return "" end
    local m = math.min(pos + num, len)
    local pre, suf = str_sub(s1, 1, pos - 1), str_sub(s1, m, len)
    return pre .. suf
end

function string.utf8remove(s1, pos, num)
    if not s1 then error("the argument#1 is nil!") end
    local utf8 = utf8
    local utf8len = utf8.len(s1)
    local len = str_len(s1)
    pos = pos or 1
    num = num or utf8len
    if pos <= 1 then
        pos = 1
    elseif pos >= utf8len + 1 then
        return s1
    end
    if num <= 0 then return s1 end
    if pos == 1 and num >= utf8len then return "" end
    local m1 = utf8.offset(s1, pos)
    local m2 = utf8.offset(s1, math.min(pos + num, utf8len + 1))
    local pre, suf = str_sub(s1, 1, m1 - 1), str_sub(s1, m2, len)
    return pre .. suf
end

function string.utf8reverse(str)
    if not str then error("the argument#1 is nil!") end
    if str == "" then return str end
    local utf8 = utf8
    local array = {
        utf8.codepoint(str, utf8.offset(str, 1), utf8.offset(str, -1))
    }
    local rArray = {}
    local len = #array
    for i = len, 1, -1 do rArray[len - i + 1] = array[i] end
    return utf8.char(unpack(rArray))
end

--[[
-- 时间Ex
-- Author : canyon / 龚阳辉
-- Date : 2015-05-25 09:25
--]]
local os = os
local os_time = os.time
local os_date = os.date
local os_difftime = os.difftime
local _lbDTime = {year = 0, month = 0, day = 0, hour = 0, min = 0, sec = 0};
TimeEx = {
    MS = 1,
    TO_SECOND = 0.001,
    SECOND = 1000,
    MINUTE = 60000,
    HOUR = 3600000,
    DAY = 86400000,
    WEEK = 604800000,
    DIFF_SEC = 0 -- 相差时间(秒)
};
local tTEx = TimeEx;

local function _ReDTime(year, month, day, hour, minute, second)
    _lbDTime.year = year or 2019;
    _lbDTime.month = month or 1;
    _lbDTime.day = day or 1;
    _lbDTime.hour = hour or 0;
    _lbDTime.min = minute or 0;
    _lbDTime.sec = second or 0;
    return _lbDTime;
end

function TimeEx.getTime(year, month, day, hour, minute, second)
    if (year and month) and (day or hour or minute or second) then
        return os_time(_ReDTime(year, month, day, hour, minute, second));
    end
    return os_time();
end

-- 取得当前时间(单位:second)
function TimeEx.getCurrentTime()
    local _val = tTEx.getTime() + tTEx.DIFF_SEC;
    return m_round(_val);
end

-- 相差时间秒 = (t2-t1)
function TimeEx.diffSec(t1Sec, t2Sec)
    t2Sec = t2Sec or tTEx.getCurrentTime();
    t1Sec = t1Sec or tTEx.getZeroTime(t2Sec);
    return os_difftime(t2Sec, t1Sec);
end

function TimeEx.format(sec, fmtStr)
    sec = sec or tTEx.getCurrentTime();
    fmtStr = fmtStr or "%Y%m%d";
    return os_date(fmtStr, sec);
end

function TimeEx.getDate(sec)
    sec = sec or tTEx.getCurrentTime();
    return tTEx.format(sec, "*t");
end

-- 零点时间
function TimeEx.getZeroTime(sec)
    local _dt = tTEx.getDate(sec);
    return tTEx.getTime(_dt.year, _dt.month, _dt.day);
end

-- 当周周一0点时间
function TimeEx.getZeroTimeOfWeek(sec)
    sec = sec or tTEx.getCurrentTime()
    local t = os_date("*t", sec)
    t.sec = 0
    t.hour = 0
    t.min = 0
    if t.wday == 1 then
        t.day = t.day - 6
    else
        t.day = t.day + 2 - t.wday
    end
    return os_time(t)
end

-- 取得当前时间的yyyyMMdd
function TimeEx.getYyyyMMdd() return tTEx.format(); end

-- 服务器差值时间
function TimeEx.setDiffSec(diffSec) tTEx.DIFF_SEC = diffSec or 0; end

-- 时分秒
function TimeEx.getHMS(ms)
    local hh, mm, ss = 0, 0, 0;
    hh = m_floor(ms / tTEx.HOUR);

    ms = ms % tTEx.HOUR;
    mm = m_floor(ms / tTEx.MINUTE);

    ms = ms % tTEx.MINUTE;
    ss = m_floor(ms / tTEx.SECOND);
    return hh, mm, ss;
end

-- 天时分秒
function TimeEx.getDHMS(ms)
    local dd = m_floor(ms / tTEx.DAY);

    ms = ms % tTEx.DAY;
    local hh, mm, ss = tTEx.getHMS(ms);
    return hh, mm, ss, dd;
end

function TimeEx.getHMSBySec(sec) return tTEx.getHMS(sec * tTEx.SECOND); end
function TimeEx.getDHMSBySec(sec) return tTEx.getDHMS(sec * tTEx.SECOND); end

function TimeEx.addDHMS(day, hour, minute, second, isZero)
    local _val = (isZero == true) and tTEx.getZeroTime() or
                     tTEx.getCurrentTime();
    _val = _val +
               tTEx.toSec(
                   (day or 0) * tTEx.DAY + (hour or 0) * tTEx.HOUR +
                       (minute or 0) * tTEx.MINUTE + (second or 0) * tTEx.SECOND);
    return _val;
end

function TimeEx.addDay(day, isZero) return tTEx.addDHMS(day, 0, 0, 0, isZero); end

function TimeEx.addHour(hour, isZero) return tTEx.addDHMS(0, hour, 0, 0, isZero); end

function TimeEx.addMinue(minute, isZero)
    return tTEx.addDHMS(0, 0, minute, 0, isZero);
end

function TimeEx.addSecond(second, isZero)
    return tTEx.addDHMS(0, 0, 0, second, isZero);
end

-- 与0点的时间差
function TimeEx.getDiffZero(second) return tTEx.diffSec(nil, second); end
function TimeEx.toMS(sec) return sec * tTEx.SECOND; end
function TimeEx.toSec(ms) return ms * tTEx.TO_SECOND; end

--[[
--- 数与随机数
-- Author : canyon / 龚阳辉
-- Date : 2016-05-25 09:25
-- Desc : base : 随机数值最大值 , isSeek 是否重置随机种子需要先引起(属于底层基础)
-- math.random([n [, m])] 无参调用,产生(0,1)之间的浮点随机数,只有参数n,产生1-n之间的整数.
-- math.fmod(x,y) = 取x/y的余数?;math.modf(v) = 取整数,小数
--]]
if bit then
    bit_band = bit.band; -- 一个或多个无符号整数 '与 &' 运算 得到值
    bit_bor = bit.bor; -- 一个或多个无符号整数 '或 |' 运算 得到值
    bit_shl = bit.shl; -- 两个无符号整数,第一个参数是被移位的数，第二个参数是向左移动的位数
    bit_shr = bit.shr; -- 两个无符号整数,第一个参数是被移位的数，第二个参数是向右移动的位数
    bit_bnot = bit.bnot; -- 取反
end

function isNum(val) return type(val) == "number"; end

function tonum(val, base, def)
    def = def or 0;
    return tonumber(val, base) or def;
end

function tonum16(val, def) return tonum(val, 16, def); end

function tonum10(val, def)
    if isNum(val) then return val; end
    return tonum(val, 10, def);
end

function toint(val, def)
    if not isNum(val) then val = tonum(val, nil, def); end
    return m_round(val);
end

function todecimal(val, def, isRound, acc)
    local _pow = 1
    if isNum(acc) then for i = 1, acc do _pow = _pow * 10; end end

    local _v = tonum(val, nil, def) * _pow;
    _v = (isRound == true) and m_round(_v) or _v;
    if _pow > 1 then _v = m_floor(_v); end
    return _v / _pow;
end

function todecimal2(val, def, isRound) return todecimal(val, def, isRound, 2); end

NumEx = {};
local tNEx = NumEx;
function NumEx.onSeek()
    local _time = os.time();
    local _seed = tostring(_time):reverse():sub(1, 6);
    m_randomseed(_seed);
end

-- 保留小数
function NumEx.retainDecimal(v, fnum)
    fnum = tonum10(fnum, 2);
    if fnum > 0 then
        local fmt = "%." .. fnum .. "f";
        v = str_format(fmt, v);
        v = tonum10(v);
    end
    return v;
end

-- 产生 : 小于base的小数
function NumEx.nextFloat(base, isSeek)
    if isSeek == true then tNEx.onSeek(); end
    base = tonum10(base, 10000);
    return m_random() * base;
end

-- 产生 : 小于base并保留npos位的小数
function NumEx.nextFloatPos(base, npos, isSeek)
    local _f = tNEx.nextFloat(base, isSeek);
    return tNEx.retainDecimal(_f, npos);
end

-- 产生 : 小于base的两位小数
function NumEx.nextFloatPos2(base, isSeek)
    return tNEx.nextFloatPos(base, 2, isSeek);
end

-- 产生 : 整数 [1~base]
function NumEx.nextInt(base, isSeek)
    if isSeek == true then tNEx.onSeek(); end
    base = tonum10(base, 10000);
    if base <= 1 then return tNEx.nextInt(2); end

    return m_random(base);
end

-- 产生 : 整数 [0~base)
function NumEx.nextIntZero(base, isSeek)
    local _r = tNEx.nextInt(base, isSeek);
    return _r - 1;
end

-- 产生 : 整数 [min~max]
function NumEx.nextNum(min, max, isSeek)
    if isSeek == true then tNEx.onSeek(); end
    return m_random(min, max);
end

-- 随机 - bool值
function NumEx.nextBool()
    local _r = tNEx.nextIntZero(2);
    return _r == 1;
end

-- 随机 - 权重的index
function NumEx.nextWeightList(list, wKey)
    local _sum, _nv = 0
    for k, v in ipairs(list) do
        if (not wKey) or (v[wKey]) then
            _nv = tonumber(v) or v[wKey];
            _sum = _sum + _nv;
        end
    end
    if _sum > 0 then
        local _r = tNEx.nextInt(_sum);
        local _sum2 = 0;
        for k, v in ipairs(list) do
            if (not wKey) or (v[wKey]) then
                _nv = tonumber(v) or v[wKey];
                _sum2 = _sum2 + _nv;
                if _sum2 >= _r then return k, _r, _sum end
            end
        end
    end
    return 0
end

function NumEx.nextWeight(...)
    local _args = {...};
    return tNEx.nextWeightList(_args)
end

-- [0-9]随机数连接的字符串长度nlen
function NumEx.nextStr(nlen, isSeek)
    if isSeek == true then tNEx.onSeek(); end
    local val = {};
    for i = 1, nlen do tb_insert(val, tNEx.nextIntZero(10)); end
    return tb_concat(val, "");
end

function NumEx.bitOr(n1, n2)
    if bit_bor then
        return bit_bor(n1, n2);
    else
        return (n1 | n2);
    end
end

function NumEx.bitAnd(n1, n2)
    if bit_band then
        return bit_band(n1, n2);
    else
        return (n1 & n2);
    end
end

function NumEx.isBitAnd(n1, n2)
    local _min = n1 > n2 and n2 or n1;
    return tNEx.bitAnd(n1, n2) == _min;
end

-- 左移
function NumEx.bitLeft(org, pos)
    if bit_shl then
        return bit_shl(org, pos);
    else
        return org << pos;
    end
end

-- 右移
function NumEx.bitRight(org, pos)
    if bit_shr then
        return bit_shr(org, pos);
    else
        return org >> pos;
    end
end

-- 取反
function NumEx.bitNot(org)
    if bit_bnot then
        return bit_bnot(org);
    else
        return (~org);
    end
end

-- 取整数或小数
function NumEx.modDecimal(num, isInt)
    if (num == nil or num == 0) then return 0; end
    local _i, _d = m_modf(num)
    return (isInt == true) and _i or _d
end

-- 求余数
function NumEx.modf(src, divisor)
    if (src == nil or src == 0) or (divisor == nil or divisor == 0) then
        return 0;
    end
    if src < divisor then return src; end

    local _fl = m_floor(src / divisor);
    return src - (_fl * divisor);
end

-- 是否奇数
function NumEx.isOdd(src)
    local _mf = tNEx.modf(src, 2);
    return _mf == 1;
end

-- 是否偶数
function NumEx.isEven(src)
    local _mf = tNEx.modf(src, 2);
    return _mf == 0;
end

--[[
-- 常规函数
-- Author : canyon / 龚阳辉
-- Date : 2015-05-25 09:25
--]]
function clearLoadLua(luapath)
    package.loaded[luapath] = nil;
    package.preload[luapath] = nil;
end

function requireOriginal(name) return _require(name); end
-- function require(name) return _require(name); end

function reimport(name)
    clearLoadLua(name);
    return _require(name);
end

local function _lfNewIndex(t, k, v)
    error(str_format("[%s] is a read-only table , key = [%s] , val = [%s]",
                     t.name or t, tostring(k), tostring(v)), 2);
end

function readonly(tb)
    if type(tb) ~= "table" then return tb end
    local _ret = {};
    local _mt = {__index = tb, __newindex = _lfNewIndex};
    return setmetatable(_ret, _mt);
end

function extends(src, parent) return setmetatable(src, {__index = parent}); end

function weakTB(objIndex, weakKey)
    if weakKey ~= "k" and weakKey ~= "v" and weakKey ~= "kv" then
        weakKey = "v";
    end
    return setmetatable({}, {__mode = weakKey, __index = objIndex});
end
function lens4Variable(...) return select('#', ...); end
