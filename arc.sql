
REM set echo on
set linesize 300
set pagesize 500
column day format a16 heading 'Dia'
column d_0 format a3 heading '00'
column d_1 format a3 heading '01'
column d_2 format a3 heading '02'
column d_3 format a3 heading '03'
column d_4 format a3 heading '04'
column d_5 format a3 heading '05'
column d_6 format a3 heading '06'
column d_7 format a3 heading '07'
column d_8 format a3 heading '08'
column d_9 format a3 heading '09'
column d_10 format a3 heading '10'
column d_11 format a3 heading '11'
column d_12 format a3 heading '12'
column d_13 format a3 heading '13'
column d_14 format a3 heading '14'
column d_15 format a3 heading '15'
column d_16 format a3 heading '16'
column d_17 format a3 heading '17'
column d_18 format a3 heading '18'
column d_19 format a3 heading '19'
column d_20 format a3 heading '20'
column d_21 format a3 heading '21'
column d_22 format a3 heading '22'
column d_23 format a3 heading '23'
column Total format 9999
column status format a8
column member format a50
column archived heading 'Archived' format a8
column bytes heading 'Bytes|(MB)' format 9999
col Dia for a20


REM ########################################################################################################


prompt =========================================================================================================================


Ttitle 'Log Switch on hour basis' skip 2

select to_char(FIRST_TIME,'DY, DD-MON-YYYY') dia,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) d_0,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) d_1,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) d_2,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) d_3,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) d_4,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) d_5,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) d_6,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) d_7,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) d_5,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) d_9,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) d_10,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) d_11,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) d_12,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) d_13,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) d_14,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) d_15,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) d_16,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) d_17,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) d_18,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) d_19,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) d_20,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) d_21,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) d_22,
decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) d_23,
count(trunc(FIRST_TIME)) Total
from v$log_history
group by to_char(FIRST_TIME,'DY, DD-MON-YYYY')
order by to_date(substr(to_char(FIRST_TIME,'DY, DD-MON-YYYY'),5,15) );


Ttitle off

prompt **************************************************************
Prompt Daily Archive Generation Rate ............
prompt **************************************************************
     set lines 180
     set pages 500
     set feedback off
     select trunc(NEXT_TIME)"Date" ,round((sum(blocks)*block_size)/1024)"Total Size(Kb)",
        round((sum(blocks)*block_size)/1024/1024)"Total Size(Mb)",
        round((sum(blocks)*block_size)/1024/1024/1024,2)"Total Size(Gb)",
     count(*) "Total Archive Logs Generated"
     from v$archived_log
     where DEST_ID=1
     and trunc(NEXT_TIME) >=trunc(sysdate -7)
     group by trunc(NEXT_TIME),block_size
     order by trunc(NEXT_TIME);

select trunc(completion_time) as "DATE", count(*) as "LOG SWITCHES", round(sum(blocks*block_size)/1024/1024) as "REDO PER DAY (MB)" 
from v$archived_log 
where dest_id=1 
group by trunc(completion_time) order by 1;

Prompt **************************************************************
Prompt RMAN has deleted the archive :
Prompt **************************************************************
select THREAD#,to_char (completion_time, 'yyyy-mm-dd') day
, round(sum (case when archived='YES' then blocks * block_size /1048576 end), 2) generated_MB
, round(sum (case when archived='YES' then blocks * block_size /1073741824 end), 2) generated_GB
, round(sum (case when archived='YES' and deleted='YES' then blocks * block_size /1048576 end), 2) deleted_mb
, round(sum (case when archived='YES' and deleted='NO' then blocks * block_size /1048576 end), 2) remaining_mb
from v$archived_log
where DEST_ID=1 
group by THREAD#,to_char (completion_time, 'yyyy-mm-dd')
order by day;

prompt **************************************************************
Prompt Hourly Archive Generation Rate ............
prompt **************************************************************
col "DD-MON-YYYY HH24"  for a20
     set lines 180
     set pages 100
     set feedback off
     select to_char(NEXT_TIME,'DD-MON-YYYY HH24') "DD-MON-YYYY HH24" ,
        round((sum(blocks)*block_size)/1024)"Total Size(Kb)",
        round((sum(blocks)*block_size)/1024/1024)"Total Size(Mb)",
        round((sum(blocks)*block_size)/1024/1024/1024,2)"Total Size(Gb)",
     count(*) "Total Archive Logs Generated"
     from v$archived_log
     where DEST_ID=1
     --and NEXT_TIME >=trunc(sysdate-7)
     and trunc(NEXT_TIME) >=trunc(sysdate-7)
     group by to_char(NEXT_TIME,'DD-MON-YYYY HH24'),block_size
     order by 1;

REM sessions gerneration REDO
REM --------------------------------
set lines 2000
set pages 1000
col sid for 99999
col name for a09
col username for a14
col PROGRAM for a21
col MODULE for a25
select s.sid,sn.SERIAL#,n.name, round(value/1024/1024,2) redo_mb, sn.username,sn.status,substr (sn.program,1,21) "program", sn.type, sn.module,sn.sql_id
from v$sesstat s join v$statname n on n.statistic# = s.statistic#
join v$session sn on sn.sid = s.sid 
where 
sn.status='ACTIVE' 
and sn.TYPE='USER'
and n.name like 'redo size' 
and s.value!=0 
order by redo_mb desc;
