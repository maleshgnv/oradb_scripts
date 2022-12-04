set line 200
set pages 200
COLUMN tablespace_name        format a25             heading 'Tablespace|(TBS)|Name'
COLUMN autoextensible         format a6              heading 'Can|Auto|Extend'
COLUMN files_in_tablespace    format 999             heading 'Files|In|TBS'
COLUMN total_tablespace_space format 99,999,999,999 heading 'Total|Current|TBS|Space(MB)'
COLUMN total_used_space       format 99,999,999,999 heading 'Total|Current|Used|Space(MB)'
COLUMN total_tablespace_free_space format 99,999,999,999 heading 'Total|Current|Free|Space(MB)'
COLUMN total_used_pct              format 999.99      heading 'Total|Current|Used|PCT'
COLUMN total_free_pct              format 999.99      heading 'Total|Current|Free|PCT'
COLUMN max_size_of_tablespace      format 99,999,999,999 heading 'TBS|Max|Size(MB)'
COLUMN can_grow                    format 99,999,999,999 heading 'TBS|Can|Grow|Size(MB)'
COLUMN total_auto_used_pct         format 999.99      heading 'Total|Max|Used|PCT'
COLUMN total_auto_free_pct         format 999.99      heading 'Total|Max|Free|PCT'
TTITLE left _date center "Tablespace Space Utilization Status Report" skip 2

select * from
(WITH tbs_auto AS
     (SELECT DISTINCT tablespace_name, autoextensible
                 FROM dba_data_files
                WHERE autoextensible = 'YES'),
     files AS
     (SELECT   tablespace_name, COUNT (*) tbs_files,
               SUM (BYTES) total_tbs_bytes
          FROM dba_data_files
      GROUP BY tablespace_name),
     fragments AS
     (SELECT   tablespace_name, COUNT (*) tbs_fragments,
               SUM (BYTES) total_tbs_free_bytes,MAX (BYTES) max_free_chunk_bytes
          FROM dba_free_space
      GROUP BY tablespace_name),
     AUTOEXTEND AS
     (SELECT   tablespace_name, SUM (size_to_grow) total_growth_tbs
          FROM (SELECT   tablespace_name, SUM (maxbytes) size_to_grow
                    FROM dba_data_files
                   WHERE autoextensible = 'YES'
                GROUP BY tablespace_name
                UNION
                SELECT   tablespace_name, SUM (BYTES) size_to_grow
                    FROM dba_data_files
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
       round((AUTOEXTEND.total_growth_tbs-((files.total_tbs_bytes - fragments.total_tbs_free_bytes)))/1024/1024) can_grow,
        (((files.total_tbs_bytes - fragments.total_tbs_free_bytes)/AUTOEXTEND.total_growth_tbs)*100) total_auto_used_pct,
        (100-(((files.total_tbs_bytes - fragments.total_tbs_free_bytes)/AUTOEXTEND.total_growth_tbs)*100)) total_auto_free_pct
  FROM dba_tablespaces a, files, fragments, AUTOEXTEND, tbs_auto
  WHERE a.tablespace_name = files.tablespace_name
   AND a.tablespace_name = fragments.tablespace_name
   AND a.tablespace_name = AUTOEXTEND.tablespace_name
   AND a.tablespace_name = tbs_auto.tablespace_name(+) )
where tablespace_name='&&tbs';

set line 200
col FILE_NAME for a60
col TABLESPACE_NAME for a25
select d.file_id,
d.tablespace_name,
d.file_name,
d.totmb,
round(nvl(f.free_mb,0),2) freemb,
d.totmb-round(nvl(f.free_mb,0),2) usedmb,
round(((d.totmb-round(nvl(f.free_mb,0),2))/d.totmb)*100,2) "Usedpct(%)",
round((nvl(f.free_mb,0)/d.totmb)*100,2) "Freepct(%)",d.autoe,d.maxsz_mb
from
(select file_id,tablespace_name,AUTOEXTENSIBLE autoe,file_name, bytes/1024/1024 totmb,MAXBYTES/1024/1024 maxsz_mb from dba_data_files where TABLESPACE_NAME='&tbs' ) d,
(select FILE_ID,sum(BYTES/1024/1024) free_mb from dba_free_space where TABLESPACE_NAME='&tbs' group by file_id ) f
where d.file_id=f.file_id(+)
order by d.file_id;
undefine tbs

