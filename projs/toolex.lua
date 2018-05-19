--- 工具
-- Anthor : canyon / 龚阳辉
-- Date : 2018-05-18 10：25
-- Desc : 重新整理一遍

require("projs/numex")
require("projs/strex")
require("projs/tabex")

local _fmtColor = "<color=#%s>%s</color>";

local table = table
local table_insert = table.insert
local table_sort = table.sort

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

		local function _printTable( t )
			table_insert( str, "{" )
			tabNum = tabNum + 1

			local keys = table.keys(t);
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
				if vtp == "table" then
					table_insert( str, string_format('\n%s%s = ', stab(tabNum),kk))
					_printTable( v )
				else
					if vtp == "string" then
						vv = string_format("\"%s\"", v)
					elseif vtp == "number" or vtp == "boolean" then
						vv = tostring(v)
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

		title = title or "table"
		table_insert( str, string_format("\n----------begin[%s]----------[%s]\n", title, os.date("%H:%M:%S") )  )
		_printTable( tb )
		table_insert( str, string_format("\n----------end  [%s]----------\n", title))

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