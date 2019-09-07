!uptime
set line 200
col username for a10
col OPNAME for a16
col machine for a10
col program for a35
col module for a10
col SQL_TEXT for a30
set pagesize 150
col message for a75
col USERNAME for a5

PROMPT LONGOPS ...............

select Username,opname,time_remaining,round(((totalwork-sofar)/totalwork),4)*100 "Pct Remaining",
message,to_char(START_TIME,'DD-MON-YY HH:MI:SS') start_time,sid
from v$session_longops
where time_remaining >0;

set lines 200 pages 200
col sql_text for a50
col username for a12
col sid for 9999
col key for 99999999999999
col module for a16
col status for a10

PROMPT SQLMONITOR .......

select key, sid,session_serial# serial#, username,sql_id,module,status, sql_plan_hash_value plan_hash, elapsed_time, cpu_time, buffer_gets, disk_reads, substr(sql_text,1,50) sql_text
from v$sql_monitor
where status = 'EXECUTING'
order by cpu_time;

prompt PARALLEL PROCESS...

col "DOP/REQ" for a10
col  "Child SID" for a10
col "Server Set" for a22
set line 200
col Program for a30
set pages 100


select decode(ps.server_set,'',s.program,'  PX Slave') "Program",       ps.qcsid "Parent SID",
decode(ps.server_set,'',' --', ps.sid) "Child SID",       ps.degree ||decode(ps.degree,'',' --','/')||ps.req_degree "DOP/REQ",
decode(ps.server_set,'','Coordinator Process', ps.server_set) "Server Set",
nvl(p.server_name,' --') "PX Server",       nvl(p.status,' --') "PX Server Status",       pss.value "Physical Reads",
decode(ps.server_set,'',s.sql_hash_value,'') "SQL Hash Value",
decode(ps.server_set,'',s.last_call_et,'') "Seconds Elapsed",s.sql_id
from v$px_session ps, v$session s,v$px_process p,v$px_sesstat pss,v$statname sn
where       s.sid   = ps.qcsid (+)and   ps.sid  = p.sid(+)and   ps.sid  = pss.sid(+)and   pss.statistic# = sn.statistic# (+)
and   sn.name='physical reads'
and   s.status='ACTIVE'
and   not s.program like '%(A%' --Eliminate Streams Apply Process
and   not s.program like '%(C%' --Eliminate Streams Capture Process
order by ps.qcsid, "Server Set" desc, "PX Server";

select distinct qcsid, degree, req_degree
from v$px_session;
