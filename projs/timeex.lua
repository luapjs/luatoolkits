--- 时间Ex
-- Anthor : canyon / 龚阳辉
-- Date : 2016-05-25 09:25
-- DeSc : 

local os = os
local os_time = os.time
local os_date = os.date
local os_difftime = os.difftime

local math = math
local math_round = math.round
local math_floor = math.floor

local M = {};
local this = M;

function M.getTime( year,month,day,hour,minute,second)
  local date;
  if year or month or day or hour or minute or second then
    date = { year = year, month = month, day = day, hour = hour, min = minute, sec = second};
  end
  if date then
    return os_time(date);
  end
  return os_time();
end

-- 取得当前时间(单位:second)
function M.getCurrentTime()
  local _val = this.getTime() + this.DIFF_SEC;
  return math_round(_val);
end

-- 相差时间秒 = (t2-t1)
function M.diffSec(t1Sec,t2Sec)
  t2Sec = t2Sec or this.getCurrentTime();
  return os_difftime(t2Sec,t1Sec);
end

function M.format(sec,fmtStr)
	sec = sec or this.getCurrentTime();
	fmtStr = fmtStr or "%Y%m%d";
	return os_date(fmtStr,sec);
end

function M.getDate(sec)
  sec = sec or this.getCurrentTime();
  return this.format(sec,"*t");
end

-- 零点时间
function M.getZeroTime( sec )
  local date = this.getDate(sec);
  return this.getTime(date.year,date.month,date.day);
end

-- 取得当前时间的yyyyMMdd
function M.getYyyyMMdd()
  return this.format();
end

function M.setDiffSec( diffSec )
  this.DIFF_SEC = diffSec or 0;
end

function M.getHMS( ms )
  local hh,mm,ss = 0,0,0;
  hh = math_floor( ms / this.HOUR );
  
  ms = ms % this.HOUR;
  mm = math_floor( ms / this.MINUTE );

  ms = ms % this.MINUTE;
  ss = ms / this.SECOND;
  return hh,mm,ss;
end

function M.getDHMS( ms )
  local dd = math_floor( ms / this.DAY );

  ms = ms % this.DAY;
  local hh,mm,ss = this.getHMS(ms);
  return dd,hh,mm,ss;
end

function M.getHMSBySec( sec )
  return this.getHMS(sec * this.SECOND)
end

function M.getDHMSBySec( sec )
  return this.getDHMS(sec * this.SECOND)
end

function M.addDay( day,isZero )
  local _val = (isZero == true) and this.getZeroTime() or this.getCurrentTime()
  return _val + day * this.DAY * this.TO_SECOND;
end

function M.addMinue( minute,isZero )
  local _val = (isZero == true) and this.getZeroTime() or this.getCurrentTime()
  return _val + minute * this.MINUTE * this.TO_SECOND;
end

function M.addSecond( second,isZero )
  local _val = (isZero == true) and this.getZeroTime() or this.getCurrentTime()
  return _val + second;
end

this.MS = 1;
this.TO_SECOND = 0.001;
this.SECOND = this.MS * 1000;
this.MINUTE = this.SECOND * 60;
this.HOUR = this.MINUTE * 60;
this.DAY = this.HOUR * 24;
this.WEEK = this.DAY * 7;
this.DIFF_SEC = 0; -- 相差时间(秒)
TimeEx = this;

return M;