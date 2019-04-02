--- lua table 对象
-- Anthor : canyon / 龚阳辉
-- Date : 2015-05-25 09:25
-- Desc : 
local table = table;
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

local math = math;
local math_max = math.max;
local math_min = math.min;
local math_random = math.random

function table.lens(src)
    local count = 0
    if type(src) == "table" then
        for _,_ in pairs(src) do
            count = count + 1;
        end
    end
    return count
end

function table.size(src)
    return table.lens(src);
end

function table.contains(src, element)
    if element and type(src) == "table" then
        for _,v in pairs(src) do
            if v == element then
                return true;
            end
        end
    end
    return false
end

function table.contains_func(src, func)
    if func and type(src) == "table" then
        for _,v in pairs(src) do
            if func(v) then
                return true;
            end
        end
    end
    return false
end

local function _keys_vals(src,sortFunc,isKey)
    local _ret = {};
    if type(src) == "table" then
        isKey = isKey == true;
        for k,v in pairs(src) do
            table_insert(_ret,isKey and k or v);
        end
        if sortFunc and #_ret > 1 then
            table_sort( _ret, sortFunc );
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
    if type(obj) == "table" then
        obj = obj.id;
    end
    return tostring(val.id) == tostring(obj);
end

function lfc_greater_than( a,b )
    return a > b;
end

function table.removeValues( src,element,times )
    return table.removeValuesFunc( src,lfc_equal,element,times );
end

function table.removeValuesFunc( src,func,obj,times )
    times = tonum10(times,-1);
    local _lens = 0;
    if 0 ~= times and func and type(src) == "table" then
        local _lbRm = {};
        for k,v in pairs(src) do
            if times == 0 then
                break;
            end
            if func(v,obj) then
                times = times - 1;
                table_insert(_lbRm,k);
            end
        end

        _lens = #_lbRm;
        if _lens > 0 then
            table_sort(_lbRm,lfc_greater_than);

            for i=1,_lens do
                table_remove(src,_lbRm[i]);
            end
        end
    end
    return src,_lens;
end

function table.sub(src,nBegin,nEnd)
    local _ret = {};
    for i,v in ipairs(src) do
        if i >= nBegin and i <= nEnd then
            table_insert(_ret,v);
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
    local _lens = #array
    for i = begin or 1, _lens do
        if array[i] == value then return i end
    end
    return false
end

function table.keyOf(src, value)
    for k, v in pairs(src) do
        if v == value then return k end
    end
end

function table.foreach(src, fnkv)
    for k, v in pairs(src) do
        fnkv(k,v);
    end
end

function table.foreach_new(src, fnkv)
    local _ret = {}
    for k, v in pairs(src) do
        _ret[k] = fnkv(k,v);
    end
    return _ret;
end

function table.filter(src,fn)
    local n = {}
    for k, v in pairs(src) do
        if fn(v, k) then
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

local function _deepCopy( src,dest )
    dest = dest or {}
    for k, v in pairs( src ) do
        if type(v) == "table" then
            dest[k] = _deepCopy( v )
        else
            dest[k] = v
        end
    end
    return dest
end

function table.deepCopy( src,dest )
    return _deepCopy( src,dest )
end

function table.getSafeArrayValue( array,index )
    index = math_min(#array,math_max(index, 1));
    return array[ index ]
end

function table.shuffle(arrTab)
    if arrTab == nil then
        return
    end
    local _lens = #arrTab;
    if _lens <= 1 then
        return arrTab;
    end
    
    local _tmp,_ret = {},{}
    for i = 1,_lens do
        table_insert(_tmp,i);
    end

    local _nVal,_nInd;
    while _lens > 0 do
        _nInd = math_random(_lens);
        _nVal = _tmp[_nInd];
        if _nVal and arrTab[_nVal] then
            table_insert(_ret,arrTab[_nVal]);
            table_remove(_tmp,_nInd);
            _lens = #_tmp;
        end
    end
    return _ret;
end