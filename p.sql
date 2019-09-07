Prompt Verify if plan is changing for the SQLID .............

set lines 200
col execs for 999,999,999
col avg_etime_secs for 999,999.999
col avg_lio for 999,999,999,999.9
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime_secs,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = '&sql_id'
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 1
/

SELECT sql_id,plan_hash_value,hash_value,executions,PARSE_CALLS,LOADED_VERSIONS,VERSION_COUNT,buffer_gets,DISK_READS,rows_processed,elapsed_Time / (1000000 * decode(executions,0,1, executions) ) etime_per_exec,
LOADS,INVALIDATIONS,(cpu_time/1000000)/60 "CPU time In Mins",is_bind_sensitive,is_bind_aware,SQL_PLAN_BASELINE,PX_SERVERS_EXECUTIONS
FROM v$sqlarea
WHERE sql_id = '&sql_id';

Prompt Fetching execution plan for the SQLID .............

REM SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(('&sql_id'),NULL,'BASIC +PEEKED_BINDS'));
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(('&sql_id'),CURSOR_CHILD_NO=>NULL,FORMAT=>'+PEEKED_BINDS'));
