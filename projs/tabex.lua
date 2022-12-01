--- lua table 对象
-- Author : canyon / 龚阳辉
-- Date : 2015-05-25 09:25
-- Desc : 
local table,type,tostring = table,type,tostring;
local tb_insert = table.insert
local tb_remove = table.remove
local tb_sort = table.sort

local math = math;
local math_max = math.max;
local math_min = math.min;
local math_random = math.random

-- 取数组长度
function table.lens(src)
    local cnt = 0
    if type(src) == "table" then
        cnt = #src  -- # 官方解释，取非队列数组的对象的长度不固定的
    end
    return cnt
end

-- 取数组长度
function table.lens2(src)
    local cnt = 0
    if type(src) == "table" then
        for _,_ in ipairs(src) do
            cnt = cnt + 1;
        end
    end
    return cnt
end

-- 取对象长度
function table.size(src)
    local cnt = 0
    if type(src) == "table" then
        for _,_ in pairs(src) do
            cnt = cnt + 1;
        end
    end
    return cnt
end

function table.end_arr(src,nEnd)
    if type(src) == "table" then
        local cnt = #src
        nEnd = (nEnd ~= nil) and (cnt + nEnd) or cnt
        if nEnd >= cnt then nEnd = cnt end
        return src[nEnd]
    end
end

function table.contains(src,element)
    if element and type(src) == "table" then
        for k,v in pairs(src) do
            if v == element then
				return true,k,v;
            end
        end
    end
    return false
end

function table.contains_func(src,func,obj)
    if func and type(src) == "table" then
        for k,v in pairs(src) do
            if func(v,obj) then
				return true,k,v;
            end
        end
    end
    return false
end

function table.contains_id(src,obj)
    return table.contains_func(src,lfc_equalId,obj)
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

function lfc_equal( val,obj )
    return val == obj;
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

function table.removeEqual(tOrg,obj,times)
    return table.removeByFunc( tOrg,lfc_equal,times,obj )
end

function table.removeEqualById(tList,obj,times)
    return table.removeByFunc( tList,lfc_equalId,times,obj )
end

function table.removeListEqual(tList,obj,times)
    return table.removeListByFunc( tList,lfc_equal,times,obj )
end

function table.removeListEqualById(tList,obj,times)
    return table.removeListByFunc( tList,lfc_equalId,times,obj )
end

function table.insertOnly(tList,obj,func)
    if obj and type(tList) == "table" then
        local _isHas = false
        if func then
            for i = #tList,1,-1 do
                if func( tList[i],obj ) then
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

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
    return dest;
end

function table.append(dest,src,begin)
    begin = toint(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
    return dest;
end

function table.indexOf(array, value, begin)
    local cnt = #array
    for i = begin or 1, cnt do
        if array[i] == value then return i end
    end
    return false
end

function table.keyOf(src, value)
    for k, v in pairs(src) do
        if v == value then return k end
    end
end

function table.foreach(src, fnvk)
    for k, v in pairs(src) do
        fnvk(v,k);
    end
end

function table.foreachArrs(src, fnvk)
    for k, v in ipairs(src) do
        fnvk(v,k);
    end
end

function table.foreach_new(src, fnvk)
    local _ret = {}
    for k, v in pairs(src) do
        _ret[k] = fnvk(v,k);
    end
    return _ret;
end

function table.filter(src,fnvk)
    local n = {}
    for k, v in pairs(src) do
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

local function _copyTableValue( tSrc,tDest )
    if type(tSrc) ~= "table" then
        return tSrc
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

function table.getSafeArrayValue( array,index )
    index = math_min(#array,math_max(index, 1));
    return array[ index ]
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

function table.getVK(src,itKey,itVal)
	if src and itKey and itVal then
		for k, v in pairs( src ) do
			if v[itKey] == itVal then
				return v,k;
			end
		end
	end
end

function table.getVK4Arr(src,itKey,itVal)
	if src and itKey and itVal then
		for k, v in ipairs( src ) do
			if v[itKey] == itVal then
				return v,k;
			end
		end
	end
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