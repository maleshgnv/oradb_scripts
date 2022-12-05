
set line 400
set pages 500
set trimspool on
col program for a30
col LOGON_TIME for a19
col RUNING_SINCE for a22
col waiting_sess_tree format a17;
col USERNAME for a20
col MACHINE for a28
col event  for a35
col CURR_DATE for a20

Set trimspool on
column timecol new_value timestamp
column dbn new_value dbname
set termout off
select to_char(sysdate,'DD-MON-YY') timecol from dual;
select name dbn from v$database;
set termout on
set verify off
spool load_test_&dbname..&timestamp..log append

Select 'Script Executed at :'||to_char(sysdate,'DD-MON-YYYY:HH:MI:SS') ||' For database:'||name "Script Executed At" from V$database;
Prompt ==============================================================================================================
Prompt Checking User Session State , BG (Oracle BACKGROUND Processes)...............
select * from v$resource_limit where RESOURCE_NAME='processes';

select inst_id,decode(status,'ACTIVE','ACTIVE-USERS','INACTIVE-USERS') status,count(1) from gv$session where type='USER'  group by inst_id,status
                        union
select inst_id,decode(status,'ACTIVE','ACTIVE-BG','INACTIVE-BG') status,count(1) from gv$session where type='BACKGROUND' group by inst_id,status order by 1,3 desc;

                        select inst_id,machine, status,count(1)
                        from gv$session
                        where type='USER'
                        and status='ACTIVE'
                        group by inst_id,machine, status
                        order by 1, 4 desc;

col name for a20
set pages 100
prompt Invalid Password logins
prompt ===============================================================================================
select USER#,NAME,LCOUNT,CTIME,PTIME,EXPTIME,LTIME,SPARE6 from user$ where LCOUNT > 0;

Prompt Checking User-Schema wise connections...............
Prompt ==============================================================================================================
col username for a18
select username,count(1) from v$session group by username order by 2 desc;
select inst_id,username,status,count(1) from gv$session group by inst_id,username,status order by 1,2,4 desc;

prompt Checking SQL_ID running from number of session and max time taken for that SQLID ..................
Prompt ==============================================================================================================
col COMMAND_NAME for a10
select s.sql_id,c.command_name,s.event,s.machine,s.username,s.status,count(*),max(s.last_call_et)  
from v$session s,v$sqlcommand c
where s.command=c.command_type
and s.status='ACTIVE'
and s.type='USER'
and s.sql_id is not null
and s.USERNAME is not null
and s.event not like 'SQL*Net message%'
group by s.sql_id,c.command_name,s.event,s.machine,s.username,s.status
having count(*)>=1
order by 8 ;

select s.sql_id,c.command_name,s.event,s.status,count(*),max(s.last_call_et)
from v$session s,v$sqlcommand c
where s.command=c.command_type
and s.status='ACTIVE'
and s.type='USER'
and s.sql_id is not null
group by s.sql_id,c.command_name,s.event,s.status
having count(*)>=1 
order by 6;

Prompt Checking Machine wise connections ......................
Prompt ==============================================================================================================
 col DB_NAME for a10
 col db_server_name for a25
 col CLIENT_APP_MACHINE  for a28
 set line 200
 set pages 100
/*
 select to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') curr_date,
 sys_context('USERENV','DB_NAME')                db_name,
 sys_context('USERENV','SERVER_HOST')            db_server_name,
 (select count(1) from v$session )              curr_tot_db_session,
 machine client_app_machine,count(1)             client_tot_conn_estab
 from v$session
 group by machine order by 6;
*/

select s.inst_id,
to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') curr_date,
sys_context('USERENV','DB_NAME')                db_name,
sys_context('USERENV','SERVER_HOST')            db_server_name,
t.tot_conn 					 curr_tot_db_session,
machine client_app_machine,
count(1)             client_tot_conn_estab
from gv$session s,  
(select inst_id,count(1) tot_conn from gv$session group by inst_id )  t
where s.inst_id=t.inst_id
group by s.inst_id,t.tot_conn,machine 
order by 1,7;


Prompt Checking Current Wait events from v$session ..........................
Prompt ==============================================================================================================
col event  for a60
select event,count(1) from v$session where  status='ACTIVE' group by event order by 2 desc;

Prompt Checking Blocker - Waiters ......................
Prompt ==============================================================================================================
prompt checking dba_waiters........
Prompt ==============================================================================================================
set line 200
col username for a15
col EVENT for a30
col machine for a20
col BLOCKING_STATUS for a10
col BLOCKING_SESSION for 999999
col STATE for a8
select  sid,
        username,
        s.status,
        s.state,
        s.event,
        s.machine,
        decode(BLOCKING_SESSION_STATUS,'VALID','BLOCKED',BLOCKING_SESSION_STATUS ) BLOCKING_STATUS,
        s.BLOCKING_SESSION blkg_ssn,FINAL_BLOCKING_SESSION fn_blkg_ssn,
        s.sql_id,prev_sql_id,
        round(last_call_et/60,2) "In Min(s)"
from v$session s where BLOCKING_SESSION is not null
order by 11 desc;


SELECT
s.inst_id,
s.FINAL_BLOCKING_SESSION fn_blkg_ssn,
s.blocking_session,
s.sid,
s.serial#,
s.sql_id,
c.command_name,
s.seconds_in_wait
FROM gv$session s,v$sqlcommand c
WHERE s.command=c.command_type
and s.blocking_session IS NOT NULL
--order by s.seconds_in_wait desc
order by s.BLOCKING_SESSION,s.SID;

prompt checking dba_blockers ......
Prompt ==============================================================================================================
col PID for 9999999
col clientpid for a8
col MACHINE for a15
SELECT /*+ RULE*/ a.username,a.machine,a.sid,c.PID,to_char(a.process) clientpid,a.serial#,to_char(c.spid) spid, a.sql_id,event,state,status,FINAL_BLOCKING_SESSION fn_blkg_ssn,round(last_call_et/60,2) "In Min(s)"
  FROM v$session a, v$process c
WHERE a.paddr = c.addr
and a.sid in (select BLOCKING_SESSION from v$session where blocking_session is not null)
order by 12 desc;

col waiting_session format 99999999999
prompt checking dba_blockers view ......
Prompt ==============================================================================================================
REM select * from dba_blockers;

set line 400
set pages 400
col program for a30
col LOGON_TIME for a19
col RUNING_SINCE for a20
col waiting_session format a20
col USERNAME for a15
col MACHINE for a28
col spid for a10

/*
Prompt Checking Hierarchy-Tree - session waits .................
Prompt ==============================================================================================================

select /*+ RULE*/ lpad(' ',3*(level-1)) || SID waiting_session,
BLOCKING_SESSION ,SERIAL#,spid,status,USERNAME,status,sql_id,Prev_sql_id,machine,PROGRAM,LOGON_TIME,RUNING_SINCE
from (
select s.SID,s.SERIAL#,p.spid,s.USERNAME,s.sql_id,s.Prev_sql_id,s.machine,s.STATUS,s.PROGRAM,s.BLOCKING_SESSION_STATUS,
s.BLOCKING_INSTANCE,s.BLOCKING_SESSION,to_char(LOGON_TIME,'DD-MON-YY HH24:Mi:ss')LOGON_TIME,
lpad(to_char(trunc(LAST_CALL_ET/3600)),2,0)||'Hr : '||
lpad(to_char(trunc(LAST_CALL_ET/60)-(trunc(LAST_CALL_ET/3600)*60)),2,0)||'Mi : ' ||
lpad(to_char(LAST_CALL_ET-(trunc(LAST_CALL_ET/60)*60)),2,0)||'Sec' RUNING_SINCE
from v$session s,v$process p
where s.paddr=p.addr
and (BLOCKING_SESSION_STATUS='VALID'
OR SID in (select BLOCKING_SESSION from v$session))
)
connect by  prior SID = BLOCKING_SESSION  start with  BLOCKING_SESSION  is null;
*/

Prompt Checking Blocker - Waiters ......................
Prompt ==============================================================================================================
set line 200
col "Object Name" for a30
col "Lock Type" for a18
col "Lock Mode" for a18
col "Lock Request Type" for a18
col "Object Type" for a30
col "Blk User" for a10
col "Wait User" for a10
col "Blocking Machine" for a30
col "Waiting Machine" for a30
col MODE_HELD for a15
col MODE_REQUESTED for a15
col "Blk OS User" for a10
col "Wait OS User" for a10
col LOCK_TYPE for a12
col blk_sess for a10
col wait_sess for a10

SELECT /*+ CHOOSE */
 bs.sid ||','|| bs.serial# blk_sess,
 bs.username "Blk User",
 bs.sql_id blk_sql_id,
 bs.osuser "Blk OS User",
 bs.machine "Blocking Machine",
 ws.sid ||','|| ws.serial# wait_sess,
 ws.username "Wait User",
 ws.sql_id wait_sql_id,
-- bs.sql_address "address",
-- bs.sql_hash_value "Sql hash",
-- bs.program "Blocking App",
-- ws.program "Waiting App",
 ws.machine "Waiting Machine",
-- ws.osuser "Wait OS User",
 DECODE(wk.TYPE,
        'MR', 'Media Recovery','RT', 'Redo Thread','UN', 'USER Name',
        'TX', 'Transaction',    'TM', 'DML',    'UL', 'PL/SQL USER LOCK',
        'DX', 'Distributed Xaction', 'CF', 'Control FILE',      'IS', 'Instance State',
        'FS', 'FILE SET', 'IR', 'Instance Recovery',    'ST', 'Disk SPACE Transaction',
        'TS', 'Temp Segment', 'IV', 'Library Cache Invalidation',
        'LS', 'LOG START OR Switch',    'RW', 'ROW Wait','SQ', 'Sequence Number',
        'TE', 'Extend TABLE', 'TT', 'Temp TABLE',       wk.TYPE) lock_type,
        DECODE(hk.lmode, 0, 'None',1, 'NULL', 2, 'ROW-S (SS)', 3, 'ROW-X (SX)', 4, 'SHARE',5, 'S/ROW-X (SSX)', 6, 'EXCLUSIVE', TO_CHAR(hk.lmode)) mode_held
      ,DECODE(wk.request,     0, 'None',      1, 'NULL',      2, 'ROW-S (SS)',  3, 'ROW-X (SX)', 4, 'SHARE',  5, 'S/ROW-X (SSX)',6, 'EXCLUSIVE', TO_CHAR(wk.request)) mode_requested
-- ,TO_CHAR(hk.id1) lock_id1,
-- TO_CHAR(hk.id2) lock_id2
FROM
   v$lock hk,  v$session bs,
                        v$lock wk,  v$session ws
WHERE
     hk.block   = 1
AND  hk.lmode  != 0
AND  hk.lmode  != 1
AND  wk.request  != 0
AND  wk.TYPE (+) = hk.TYPE
AND  wk.id1  (+) = hk.id1
AND  wk.id2  (+) = hk.id2
AND  hk.sid    = bs.sid(+)
AND  wk.sid    = ws.sid(+)
ORDER BY 1;


REM prompt checking dba_waiters........
REM Prompt ==============================================================================================================
REM select * from dba_waiters;
prompt checking ROW contending for
Prompt ==============================================================================================================
col ROW_ID for a20
col OBJECT_NAME for a30
set line 400
col sid for 99999
col username for a15
select s.sid,s.serial#,s.sql_id,s.username,do.object_name,
row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#,
--dbms_rowid.rowid_create ( 1, ROW_WAIT_OBJ#, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# ) ROW_ID
dbms_rowid.rowid_create( 1, do.DATA_OBJECT_ID, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# ) ROW_ID
from v$session s, dba_objects do
where sid in ( select sid from v$session where BLOCKING_SESSION_STATUS='VALID')
and s.ROW_WAIT_OBJ# = do.OBJECT_ID ;

prompt checking for library cache: mutex X ....
Prompt ==============================================================================================================

prompt Blocker or culprit session kill him
Prompt Blocked session OR He is waiting
Prompt ==============================================================================================================

select p2raw,to_number(substr(to_char(rawtohex(p2raw)),1,8),'XXXXXXXX') sid
      from v$session
      where event = 'library cache: mutex X';

REM The blocker session can be queried to see what it is doing and if anyone is blocking him...
Prompt Kill the below blocker/Culprit session,The blocker session can be queried to see what it is doing and if anyone is blocking him....
Prompt ==============================================================================================================
col event for a46
col module for a25
col "KillSessions" for a50
col "OS_PID" for a6
set line 200
SELECT /*+ RULE*/ s.sid, s.serial#, p.spid as "OS_PID",s.BLOCKING_SESSION,s.last_call_et,s.sql_id,s.status,s.module,s.event,
'alter system kill session '||''''||s.SID||','||s.SERIAL#||''' Immediate;' "KillSessions"
FROM v$session s, v$process p
WHERE s.paddr = p.addr
and s.username is not null
and SID in
(
select distinct to_number(substr(to_char(rawtohex(p2raw)),1,8),'XXXXXXXX')
      from v$session
      where event = 'library cache: mutex X'
);


REM The Blocked/Waiter as he is waiting to get the resource ....
Prompt The Blocked/Waiter as he is waiting to get the resource ....
Prompt ==============================================================================================================
select sid,serial#,SQL_ID,BLOCKING_SESSION,BLOCKING_SESSION_STATUS,EVENT
      from v$session where event ='library cache: mutex X';

Prompt Who is holding the latch - v$latchholder
select * from v$latchholder;

Prompt What All Objects Changed in last 5 days
Prompt ==============================================================================================================

col owner for a15
set line 200
col OBJECT_NAME for a30
col CREATED for a25
col LAST_DDL_TIME for a25
select OWNER,OBJECT_NAME,OBJECT_TYPE,to_char(CREATED,'DD-MON-YYYY hh24:mi:ss')CREATED, to_char(LAST_DDL_TIME,'DD-MON-YYYY hh24:mi:ss') LAST_DDL_TIME 
from dba_objects 
--where owner not in (select USERNAME from dba_users where ORACLE_MAINTAINED='Y')
where owner not in ('SYS','GSMADMIN_INTERNAL','ORACLE_OCM','EXFSYS','GGSADMIN')
AND (CREATED >= sysdate - 1 OR LAST_DDL_TIME>= sysdate -1)
order by LAST_DDL_TIME asc;

Prompt What PL-SQL program is currently running
Prompt ==============================================================================================================

col OBJECT_NAME for a30
col USERNAME for a15
col OWNER for a15
col EVENT for a20
select sid,serial#,s.sql_id,s.username,o.owner,o.object_name,o.object_type,s.status,event,last_call_et/60 mins 
from v$session s , dba_objects o
where s.PLSQL_ENTRY_OBJECT_ID=o.object_id
and s.PLSQL_ENTRY_OBJECT_ID > 0;

Prompt What INDEXES are UNUSABLE
Prompt ==============================================================================================================

set line 200
col OWNER for a15
col INDEX_NAME for a30
col TABLESPACE_NAME for a25
col PARTITION for a15
col SUBPARTITION for a15
select owner, index_name,tablespace_name,'No Partition' partition,'No Subpartition' Subpartition,status from dba_indexes where status not in('VALID','USABLE','N/A') and Owner not in ('SYS')
union
select index_owner owner,index_name,tablespace_name,partition_name partition,'No Subpartition' Subpartition,status from dba_ind_partitions where status not in('VALID','USABLE','N/A') and index_owner not in ('SYS')
union
select index_owner owner, index_name,tablespace_name,partition_name partition,subpartition_name Subpartition,status from dba_ind_subpartitions where status not in('VALID','USABLE','N/A') and index_owner not in ('SYS');

Prompt Check if RMAN Backup is runnning
Prompt ==============================================================================================================

set line 200
col "Start Time" for a25
col "Time Taken" for a10
col "End Time" for a25
col "Input Size" for a10
col "Output Size" for a10
col status for a10
col "Output Rate (Per Sec)" for a22

SELECT
TO_CHAR(b.start_time, 'MON DD, YYYY HH12:MI:SS PM') as "Start Time",
TO_CHAR(b.end_time, 'MON DD, YYYY HH12:MI:SS PM') as "End Time",
b.status as "Status",
b.time_taken_display as "Time Taken", b.input_type as "Type",
b.output_device_type as "Output Devices", b.input_bytes_display as "Input Size",
b.output_bytes_display as "Output Size", b.output_bytes_per_sec_display as "Output Rate (Per Sec)"
FROM V$RMAN_BACKUP_JOB_DETAILS b
where b.status='RUNNING'
ORDER BY b.start_time DESC;

/* 
Below hangs in 11g
SELECT sid,operation
	, status
	, mbytes_processed
	, start_time
	, end_time
FROM	  v$rman_status
where  status ='RUNNING';
*/

Prompt ========================================== uptime ============================================================
Spool off
host uptime |tee -a load_test_&dbname..&timestamp..log
host vmstat -tw 1 10 |tee -a load_test_&dbname..&timestamp..log
host ps -ef |egrep 'find|gzip|exp|imp|rman|defunct'|grep -v grep|grep -v mice |tee -a load_test_&dbname..&timestamp..log

--exit
/*
col SEQUENCE_OWNER for a10
col SEQUENCE_NAME for a30
col NEXTVALUE for 999,999,999,999,999
select SEQUENCE_OWNER,SEQUENCE_NAME,NEXTVALUE,INCREMENT_BY,CACHE_SIZE,CYCLE_FLAG
from v$_sequences
where SEQUENCE_OWNER='MALU'
and SEQUENCE_NAME like 'SQ_COURSEEVENTS%';

col MAX_VALUE for 9999999999999999999999999999999999
col LAST_NUMBER for 999,999,999,999,999

select SEQUENCE_OWNER,SEQUENCE_NAME,MIN_VALUE,MAX_VALUE,INCREMENT_BY,LAST_NUMBER,CACHE_SIZE,CYCLE_FLAG
from dba_sequences
where SEQUENCE_OWNER='MALU'
and SEQUENCE_NAME like 'SQ_COURSEEVENTS%';
*/
