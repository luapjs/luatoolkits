--- 工具Ex
-- Anthor : canyon / 龚阳辉
-- Date : 2018-05-18 10：25
-- Desc : 重新整理一遍

require("projs/numex")
require("projs/strex")
require("projs/tabex")
require("projs/timeex")

local _fmtColor = "<color=#%s>%s</color>";

local table = table
local table_insert = table.insert
local table_sort = table.sort
local table_keys = table.keys
local table_lens = table.lens

local string_format = string.format
local string_gsub = string.gsub
local string_rep = string.rep
local table_concat = table.concat
local string_byte = string.byte

function handler( obj, method )
    return function( ... )
        return method( obj, ... )
    end
end

function callFunc( funcName )
	return function ( ... )
		local arg = {...}
		return function ( self )
			if self[funcName] then
				self[funcName]( self, unpack( arg ) )
			else
				error( "can't find function by name %s in table=[%s]", funcName,self.name or self );
			end
		end
	end
end

local function _appendHeap( src )
	return string_format("%s\n%s",src,debug.traceback());
end

local function _sort_key( a,b )
	return string_byte(a) < string_byte(b);
end

function printTable( tb,title,notSort,rgb )
	rgb = rgb or "09f68f";
	if not tb or type(tb) ~= "table" then
		title = string_format(_fmtColor,rgb,tb)
	else
		local tabNum = 0;
		local function stab( numTab )
			return string_rep("    ", numTab);
		end
		local str = {};
		local _dic,_str_temp = {};

		local function _printTable( t )
			table_insert( str, "{" )
			tabNum = tabNum + 1

			local keys = table_keys(t);
			if not notSort then table_sort(keys,_sort_key); end

			local v,kk,ktp,vtp;
			for _, k in pairs( keys ) do
				v = t[ k ]
				ktp = type(k)
				vtp = type(v)
				if ktp == "string" then
					kk = "['" .. k .. "']"
				else
					kk = "[" .. tostring(k) .. "]"
				end
				_str_temp = tostring(v)
		
				if (vtp == "table") and (not _dic[_str_temp]) then
					_dic[_str_temp] = true;
					table_insert( str, string_format('\n%s%s = ', stab(tabNum),kk))
					_printTable( v )
				else
					if vtp == "string" then
						vv = string_format("\"%s\"", v)
					elseif vtp == "number" or vtp == "boolean" or vtp == "table" then
						vv = _str_temp
					else
						vv = "[" .. vtp .. "]"
					end

					if ktp == "string" then
						table_insert( str, string_format("\n%s%-18s = %s,", stab(tabNum), kk, string_gsub(vv, "%%", "?") ) )
					else
						table_insert( str, string_format("\n%s%-4s = %s,", stab(tabNum), kk, string_gsub(vv, "%%", "?") ) )
					end
				end
			end
			tabNum = tabNum - 1

			if tabNum == 0 then
				table_insert( str, '}' )
			else
				table_insert( str, '},' )
			end
		end

		title = string_format("%s = %s",(title or ""),tb);
		table_insert( str, string_format("\n====== beg [%s]------[%s]\n", title, os.date("%H:%M:%S") )  )
		_str_temp = tostring(tb)
		_dic[_str_temp] = true;
		_printTable( tb )
		table_insert( str, string_format("\n====== end [%s]------\n", title))

		title = table_concat(str, "")
		title = string_format(_fmtColor,rgb,title)
	end

	title = _appendHeap(title);
	print(title)
end

function readonly( tb )
	local _ret = {};
	local _mt = {
		__index = tb,
		__newindex = function ( t,k,v )
			error(string_format("[%s] is a read-only table",t.name or t),2);
		end
	}
	setmetatable(_ret,_mt);
	return _ret;
end

------ 排序相关 -----
local function _quickSortBase(p)
	if p == nil or p.h >= p.t then return end

	local head,tail
	head = p.h
	tail = p.t
	local key = p.ka[head]
	local left,right
	
	left,right = head,tail
	
	while left < right do
		while (left <right) and p.f(p.a[p.ka[right]],p.a[key]) >= 0 do
			right = right - 1
		end
		p.ka[left] = p.ka[right]
		
	
		while (left < right) and p.f(p.a[p.ka[left]] ,p.a[key]) < 0 do
			left = left + 1
		end
		p.ka[right] = p.ka[left]
	end
	p.ka[left] = key


	p.h = head
	p.t = left - 1
	_quickSortBase(p)
	p.h = left + 1
	p.t = tail
	_quickSortBase(p)
end 

local function _quickSort( a, head, tail, f )
	if head >= tail then
		return
	end

	local key = a[head]
	local left,right
	
	left,right = head,tail
	
	while left < right do
		while (left <right) and f(a[right],key) >= 0 do
			right = right - 1
		end
		a[left] = a[right]
		
	
		while (left < right) and f(a[left] ,key) < 0 do
			left = left + 1
		end
		a[right] = a[left]
	end
	a[left] = key

	_quickSort( a, head, left - 1, f )
	_quickSort( a, left + 1,tail, f )
end

local function _quickSort2(a,f)
	local ka = {}
	for k, v in pairs( a ) do
		table_insert( ka, k )
	end
	local p = {}
	p.a = a
	p.ka = ka
	p.h = 1
	p.t = table_lens(ka)
	p.f = f
	_quickSortBase(p)
	return ka
end

-- fields 是 array中对象tab的key值,如果对象前面加 "-" 标识排倒叙
function sortArrayByField( array, fields )
	-- 重载，允许只有一个字符串
	if type( fields ) == "string" then
		fields = { fields }
	end

	-- 处理一次fields
	local fieldConfig = {}
	for _, v in pairs( fields ) do
		if string.sub( v, 1, 1 ) == "-" then
			table_insert( fieldConfig, { string.sub( v, 2, string.len( v ) ), true } )
		else
			table_insert( fieldConfig, { v, false } )
		end
	end

	-- 按照优先级进行排序
	local sorter = function( a, b )
		local ret = 0

		for _, v in pairs( fieldConfig ) do
			local field, desc = v[1], v[2]

			local v1, v2 = a[field], b[field]
			if v1 then
				if desc then
					ret = v2 - v1
				else
					ret = v1- v2
				end

				if ret ~= 0 then
					return ret
				end
			end
		end
		return ret
	end

	local sortd = {}
	local keys = _quickSort2( array, sorter )

	for _, v in pairs( keys ) do
		table_insert( sortd, array[ v ] )
	end

	return sortd
end