--- 工具
-- Author : canyon / 龚阳辉
-- Date : 2018-05-18 10：25
-- Desc : 重新整理一遍

require("projs/toolex");

TB_EMPTY = {}; -- 全局空的对象(用于返回)
TB_NEW = {__call=function() return {}; end}; -- 用法: TB_NEW();