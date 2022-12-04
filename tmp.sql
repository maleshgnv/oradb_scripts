set line 200

col PROPERTY_NAME for a30
col PROPERTY_VALUE for a15
col DESCRIPTION for a45

Select * from database_properties where PROPERTY_NAME='DEFAULT_TEMP_TABLESPACE';

REM =======================================================================================================
REM  For TEMP Tablespace 
REM =======================================================================================================
select TABLESPACE_NAME,CONTENTS from dba_tablespaces where CONTENTS='TEMPORARY';

set line 200
set pages 200
set verify off
COLUMN tablespace_name        format a25             heading 'Tablespace|(TBS)|Name'
COLUMN autoextensible         format a6              heading 'Can|Auto|Extend'
COLUMN files_in_tablespace    format 999             heading 'Files|In|TBS'
COLUMN total_tablespace_space format 99,999,999,999 heading 'Total|Current|TBS|Space(MB)'
COLUMN total_used_space       format 99,999,999,999 heading 'Total|Current|Used|Space(MB)'
COLUMN total_tablespace_free_space format 99,999,999,999 heading 'Total|Current|Free|Space(MB)'
COLUMN total_used_pct              format 999.99      heading 'Total|Current|Used|PCT'
COLUMN total_free_pct              format 999.99      heading 'Total|Current|Free|PCT'
COLUMN max_size_of_tablespace      format 99,999,999,999 heading 'TBS|Max|Size(MB)'
COLUMN total_auto_used_pct         format 999.99      heading 'Total|Max|Used|PCT'
COLUMN total_auto_free_pct         format 999.99      heading 'Total|Max|Free|PCT'

REM TTITLE left _date center "Tablespace Space Utilization Status Report" skip 2

select * from 
(
WITH tbs_auto AS
     (SELECT DISTINCT tablespace_name, autoextensible
                 FROM dba_temp_files
                WHERE autoextensible = 'YES'),
     files AS
     (SELECT   tablespace_name, COUNT (*) tbs_files,
               SUM (BYTES) total_tbs_bytes
          FROM dba_temp_files
      GROUP BY tablespace_name),
     fragments AS
     (select d.TABLESPACE_NAME,
		d.TEMP_TOTAL - sum (nvl(a.used_blocks,0) * nvl(d.block_size,0)) total_tbs_free_bytes
		from v$sort_segment a,
		(
			select b.name TABLESPACE_NAME, c.block_size, sum (c.bytes) TEMP_TOTAL
			from v$tablespace b, v$tempfile c
			where b.ts#= c.ts#
			group by b.name, c.block_size
		) d
	where a.tablespace_name(+) = d.TABLESPACE_NAME 
	group by d.TABLESPACE_NAME, d.TEMP_TOTAL
     ),
     AUTOEXTEND AS
     (SELECT   tablespace_name, SUM (size_to_grow) total_growth_tbs
          FROM (SELECT   tablespace_name, SUM (maxbytes) size_to_grow
                    FROM dba_temp_files
                   WHERE autoextensible = 'YES'
                GROUP BY tablespace_name
                UNION
                SELECT   tablespace_name, SUM (BYTES) size_to_grow
                    FROM dba_temp_files
                   WHERE autoextensible = 'NO'
                GROUP BY tablespace_name)
      GROUP BY tablespace_name)
SELECT a.tablespace_name,
       CASE tbs_auto.autoextensible
          WHEN 'YES'
             THEN 'YES'
          ELSE 'NO'
       END AS autoextensible,
       files.tbs_files files_in_tablespace,
       files.total_tbs_bytes/1024/1024 total_tablespace_space,
       (files.total_tbs_bytes - fragments.total_tbs_free_bytes
       )/1024/1024 total_used_space,
       fragments.total_tbs_free_bytes/1024/1024 total_tablespace_free_space,
       (  (  (files.total_tbs_bytes - fragments.total_tbs_free_bytes)
           / files.total_tbs_bytes
          )
        * 100
       ) total_used_pct,
       ((fragments.total_tbs_free_bytes / files.total_tbs_bytes) * 100
       ) total_free_pct,
       AUTOEXTEND.total_growth_tbs/1024/1024 max_size_of_tablespace,
       round((AUTOEXTEND.total_growth_tbs-((files.total_tbs_bytes - fragments.total_tbs_free_bytes)))/1024/1024) can_grow_Mb,
        (((files.total_tbs_bytes - fragments.total_tbs_free_bytes)/AUTOEXTEND.total_growth_tbs)*100) total_auto_used_pct,
        (100-(((files.total_tbs_bytes - fragments.total_tbs_free_bytes)/AUTOEXTEND.total_growth_tbs)*100)) total_auto_free_pct
  FROM dba_tablespaces a, files, fragments, AUTOEXTEND, tbs_auto
  WHERE a.tablespace_name = files.tablespace_name
   AND a.tablespace_name = fragments.tablespace_name
   AND a.tablespace_name = AUTOEXTEND.tablespace_name
   AND a.tablespace_name = tbs_auto.tablespace_name(+) 
)
where tablespace_name in (select TABLESPACE_NAME from dba_tablespaces where CONTENTS='TEMPORARY');

prompt 
prompt #####################################################################
prompt #######################GLOBAL TEMP USAGE#####RAC#####################
prompt #####################################################################
prompt 
 
select d.inst_id,d.name,
d.TEMP_TOTAL_MB,
sum (nvl(a.used_blocks,0) * nvl(d.block_size,0)) / 1024 / 1024 TEMP_USED_MB,
d.TEMP_TOTAL_MB - sum (nvl(a.used_blocks,0) * nvl(d.block_size,0)) / 1024 / 1024 TEMP_FREE_MB
from gv$sort_segment a,
(
select B.INST_ID,b.name, c.block_size, round(sum (c.bytes) / 1024 / 1024) TEMP_TOTAL_MB
from gv$tablespace b, gv$tempfile c
where b.ts#= c.ts#
and c.inst_id=b.inst_id
group by B.INST_ID,B.name, C.block_size
) d
where a.tablespace_name(+) = d.name
and A.inst_id(+)=D.inst_id
group by d.inst_id,d.name, d.TEMP_TOTAL_MB;

prompt #####################################################################
prompt #######################NON RAC#####################
prompt #####################################################################
select TABLESPACE_NAME,
round((TABLESPACE_SIZE*8192)/1024/1024) TBS_SIZE_MB,
round((USED_SPACE*8192)/1024/1024) USED_SPACE_MB,
round(USED_PERCENT) USED_PERCENT 
from DBA_TABLESPACE_USAGE_METRICS
where TABLESPACE_NAME in (select TABLESPACE_NAME from dba_tablespaces where CONTENTS='TEMPORARY');



set line 200
set pages 200
col SID_SERIAL for a20
col MODULE for a25
col PROGRAM for a25
col OSUSER for a15
col TABLESPACE for a15
col USERNAME for a18

col spid for a10
SELECT   S.sid || ',' || S.serial# sid_serial, S.username, S.osuser, to_char(P.spid)spid,
         S.module, s.sql_id,s.status,
         SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
         COUNT(*) sort_ops
FROM     v$sort_usage T, v$session S, dba_tablespaces TBS, v$process P
WHERE    T.session_addr = S.saddr
AND      S.paddr = P.addr
AND      T.tablespace = TBS.tablespace_name
--AND      T.tablespace = 'TEMP1'
AND s.status='ACTIVE'
GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, S.module,
         S.program, s.sql_id,s.status,TBS.block_size, T.tablespace
ORDER BY 8,sid_serial;



