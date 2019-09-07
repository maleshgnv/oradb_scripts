define sid=&sid
define ser=&ser
col PROGRAM for a30
col SQL_ID for a13
col  WAIT_CLASS for a11
col EVENT  for a29
col TEMP_SPACE_ALLOCATED for 9999999
col sample_time for a25
set line 200
col blk_sid for 9999999
set line 200
col USER_NAME for a10
col PROGRAM for a33
col MACHINE for a15
set pages 100
Prompt Open cursors mentioned by SID ....................
SELECT
  OC.SID,S.SERIAL#,
  OC.USER_NAME,
  --s.username,
  S.STATUS,
  S.PROGRAM,S.MACHINE,TO_CHAR(OC.LAST_SQL_ACTIVE_TIME,'DD-MON-YYYY HH24:MI:SS')LAST_SQL_ACTIVE_TIME,
  --S.MODULE,
  OC.SQL_ID
  ,OC.SQL_TEXT
FROM
  V$OPEN_CURSOR OC,
  V$SESSION S
WHERE
  OC.SQL_TEXT NOT LIKE '%obj#,%'
  AND OC.SQL_TEXT NOT LIKE '%grantee#,%'
  AND OC.SQL_TEXT NOT LIKE '%privilege#%'
  --AND OC.SQL_TEXT NOT LIKE 'DECLARE%'
  AND OC.SQL_TEXT NOT LIKE '%/*+ rule */%'
  AND OC.SQL_TEXT NOT LIKE '%col#%'
  AND OC.SQL_TEXT NOT LIKE '%sys.mon_mods$%'
  AND OC.SQL_TEXT NOT LIKE '%obj#=%'
  AND OC.SQL_TEXT NOT LIKE '%update$,%'
  AND OC.SID=S.SID
  --AND OC.USER_NAME NOT IN ('SYS','DBSNMP','SYSTEM','SYSMAN','RMAN')
  AND OC.USER_NAME NOT IN ('DBSNMP','SYSTEM','SYSMAN','RMAN')
  AND S.SID=&sid
  AND S.SERIAL#=&ser
ORDER by OC.LAST_SQL_ACTIVE_TIME;

Prompt  ...........SQLIDs from active session history ......................
select  MACHINE,sql_id,count(1)
from v$active_session_history
where
--sample_time >  sysdate - interval '5' minute
--      SAMPLE_TIME BETWEEN
--      TO_TIMESTAMP('30.05.2017 13:45:00', 'dd.mm.yyyy hh24:mi:ss') AND
--      TO_TIMESTAMP('30.05.2017 14:25:00', 'dd.mm.yyyy hh24:mi:ss')
session_id=&sid
and  SESSION_SERIAL#=&ser
group by  MACHINE,sql_id
order by 3 desc;

select sample_time,sql_id, session_id sid ,session_serial# ser#,DECODE(EVENT,NULL,'ON CPU',EVENT) EVENT,
WAIT_CLASS,CURRENT_OBJ# cur_obj#,substr(PROGRAM,1,30) PROGRAM,
--TEMP_SPACE_ALLOCATED tmpsz,
BLOCKING_SESSION blk_sid,count(1) secs
from v$active_session_history
where
--sample_time >  sysdate - interval '5' minute
--      SAMPLE_TIME BETWEEN
--      TO_TIMESTAMP('30.05.2017 13:45:00', 'dd.mm.yyyy hh24:mi:ss') AND
--      TO_TIMESTAMP('30.05.2017 14:25:00', 'dd.mm.yyyy hh24:mi:ss')
session_id=&sid
and  SESSION_SERIAL#=&ser
group by sample_time,sql_id, session_id,session_serial#,EVENT,
WAIT_CLASS,CURRENT_OBJ#,PROGRAM
--,TEMP_SPACE_ALLOCATED
,BLOCKING_SESSION
order by sample_time,count(1) desc;

undefine sid
undefine ser

