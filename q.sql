set long 6000
set line 200
set pages 200
set long 999999999
col SQL_TEXT  for a500
col SQL_FULLTEXT for a800
define SQLID=&SQLID
SELECT SQL_ID,SQL_FULLTEXT FROM v$sqlarea WHERE sql_id in ('&SQLID');

SELECT sql_id,plan_hash_value,hash_value,executions,PARSE_CALLS,LOADED_VERSIONS,VERSION_COUNT,buffer_gets,DISK_READS,rows_processed,elapsed_Time / (1000000 * decode(executions,0,1, executions) ) etime_per_exec,
LOADS,INVALIDATIONS,(cpu_time/1000000)/60 "CPU time In Mins",is_bind_sensitive,is_bind_aware,SQL_PLAN_BASELINE
  FROM v$sqlarea
WHERE sql_id = '&SQLID';

SELECT sql_id,address,hash_value,child_number,peeked,executions,rows_processed,buffer_gets,(cpu_time/1000000)/60 "CPU time In Mins"
from v$sql_cs_statistics where sql_id = '&SQLID';

PAUSE Do You Want to See the execution plan for all those above child cursors ..... ?

/*
col sql_plan_baseline for a30
SELECT sql_id,plan_hash_value,hash_value,child_number,executions,buffer_gets,is_bind_sensitive,is_bind_aware,sql_plan_baseline
  FROM v$sql
WHERE sql_id = '&SQLID';
*/

/*
col value_string format a20
col name for a4

select s.sql_id,s.child_number,s.is_bind_sensitive,s.is_bind_aware,is_shareable,plan_hash_value,name,position,value_string,datatype_string
from v$sql s, v$sql_bind_capture b
where s.sql_id='&SQLID'
and s.sql_id=b.sql_id
and s.child_number=b.child_number
order by s.child_number;
*/


SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(('&SQLID'),CURSOR_CHILD_NO=>NULL,FORMAT=>'+PEEKED_BINDS'));

REM SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR(('&SQLID'),'&PLAN_HASH_VALUE',FORMAT=>'+PEEKED_BINDS'));

undefine SQLID

