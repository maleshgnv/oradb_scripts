define sid=&sid
define ser=&ser
col SQL_ID for a13
col  WAIT_CLASS for a11
col EVENT  for a29
col TEMP_SPACE_ALLOCATED for 9999999
col sample_time for a25
set line 200
col blk_sid for 9999999
set line 200
col USER_NAME for a10
col PROGRAM for a35
col MACHINE for a15
col sid for 99999
set pages 100

select  MACHINE,sql_id,count(1)
from DBA_HIST_ACTIVE_SESS_HISTORY
where
--sample_time >  sysdate - interval '5' minute
--      SAMPLE_TIME BETWEEN
--      TO_TIMESTAMP('30.05.2017 13:45:00', 'dd.mm.yyyy hh24:mi:ss') AND
--      TO_TIMESTAMP('30.05.2017 14:25:00', 'dd.mm.yyyy hh24:mi:ss')
session_id=&sid
and  SESSION_SERIAL#=&ser
group by  MACHINE,sql_id
order by 3 desc;

select sample_time,sql_id, session_id sid ,session_serial# ser#,DECODE(EVENT,NULL,'ON CPU',EVENT) EVENT,WAIT_CLASS,CURRENT_OBJ# cur_obj#,PROGRAM,TEMP_SPACE_ALLOCATED tmpsz,count(1) secs
from DBA_HIST_ACTIVE_SESS_HISTORY
where
 --sample_time >  sysdate - interval '5' minute
 -- SAMPLE_TIME BETWEEN
 -- TO_TIMESTAMP('30.05.2017 13:45:00', 'dd.mm.yyyy hh24:mi:ss') AND
 -- TO_TIMESTAMP('30.05.2017 14:25:00', 'dd.mm.yyyy hh24:mi:ss')
 session_id=&sid
 and  SESSION_SERIAL#=&ser
 group by sample_time,sql_id, session_id,session_serial#,EVENT,
 WAIT_CLASS,CURRENT_OBJ#,PROGRAM,TEMP_SPACE_ALLOCATED
 order by sample_time,count(1) desc;
 undefine sid
 undefine ser
