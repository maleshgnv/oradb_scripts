prompt Show instance memory usage breakdown from v$memory_dynamic_components
set line 200
COLUMN mem_component FORMAT A30
SELECT
    component mem_component
  , ROUND(current_size/1024/1024) AS current_size_mb
  , ROUND(min_size/1024/1024) AS min_size_mb
  , ROUND(max_size/1024/1024) AS max_size_mb
  , ROUND(user_specified_size/1048576)    spec_mb
  , oper_count
  , last_oper_type last_optype
  , last_oper_mode last_opmode
  , last_oper_time last_optime
  , granule_size/1048576        gran_mb
FROM
    v$memory_dynamic_components
    WHERE   current_size != 0
    ORDER BY component;


COLUMN component FORMAT A30

SELECT  component,
        ROUND(current_size/1024/1024) AS current_size_mb,
        ROUND(min_size/1024/1024) AS min_size_mb,
        ROUND(max_size/1024/1024) AS max_size_mb
FROM    v$sga_dynamic_components
WHERE   current_size != 0
ORDER BY component;

REM Memory_target growth/shrink
SET LINESIZE 200
COLUMN parameter FORMAT A25
col COMPONENT for a30
set pages 30
SELECT start_time,
       end_time,
       component,
       oper_type,
       oper_mode,
       parameter,
       ROUND(initial_size/1024/1024) AS initial_size_mb,
       ROUND(target_size/1024/1024) AS target_size_mb,
       ROUND(final_size/1024/1024) AS final_size_mb,
       status
FROM   v$memory_resize_ops
ORDER BY start_time;


REM aggregate PGA auto target -> 
REM If this value is small compared to the value of PGA_AGGREGATE_TARGET, 
REM then a large amount of PGA memory is used by other components of the system (for example, PL/SQL or Java memory) 
REM and little is left for work areas. The DBA must ensure that enough PGA memory is left for work areas running in automatic mode.

set line 200
select name,round(value/1024/1024,2) "In MB",round(value/1024/1024/1024,2) "In GB"
from v$pgastat
where name in ('aggregate PGA target parameter',
'aggregate PGA auto target',
'total PGA inuse',
'total PGA allocated');



REM The second and third columns show how much extra work is needed by the
REM database if the PGA changes by that factor. We want to size the PGA such that the values
REM in the second and third column are 0. We can see in the row where the factor equals 1
REM that we have a nonzero value, so we should consider increasing the PGA.

col ESTD_EXTRA_BYTES_RW for 9999999999999999
select	round(pga_target_for_estimate/1024/1024) as est_mb,pga_target_factor,estd_extra_bytes_rw,estd_overalloc_count
from v$pga_target_advice;

REM In the output above, our current SGA has an estimated DB time value of 60,692
REM and an estimated number of physical reads of 4,175,955. If we increase the SGA by 25%
REM (factor=1.25), the estimated DB time drops a little, as does the estimated physical reads.
REM Notice that if we increase the SGA by a factor of 50%, the estimated physical reads do not
REM change. This view is showing us that doubling the SGA size would not give us that much
REM better performance than increasing by a more modest amount of 25%.

select sga_size_factor,estd_db_time,estd_physical_reads
from v$sga_target_advice;


REM Memory Usage:

select max(p.pga_max_mem)/1024/1024 "PGA MAX_MEMORY USER SESS (MB)"
from v$process p, v$session s
where P.ADDR = S.paddr and s.username is not null;

SELECT spid, program,
            pga_max_mem      max,
            pga_alloc_mem    alloc,
            pga_used_mem     used,
            pga_freeable_mem free
FROM V$PROCESS;

SELECT spid, program,
            pga_max_mem      max,
            pga_alloc_mem    alloc,
            pga_used_mem     used,
            pga_freeable_mem free
       FROM V$PROCESS
      WHERE spid = 2587;

SELECT p.program,
            p.spid,
            pm.category,
            pm.allocated,
            pm.used,
            pm.max_allocated
       FROM V$PROCESS p, V$PROCESS_MEMORY pm
      WHERE p.pid = pm.pid
        AND p.spid = 2587;







