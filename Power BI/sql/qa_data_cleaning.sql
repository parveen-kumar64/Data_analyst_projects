select  top 10 * from [dbo].[bug_reports];
Use qa_analytics
-- create reference table 
select * into bugreport_cleaned from [dbo].[bug_reports];

select * from bugreport_cleaned;
-- check for spaces in column 
select * from bugreport_cleaned where severity like '% %'
UPDATE bugreport_cleaned
SET severity = TRIM(severity),
    priority = TRIM(priority),
    status = TRIM(status);

-- formating with proper values first convert all in lover case and update

SELECT DISTINCT module_name
FROM bugreport_cleaned;

UPDATE bugreport_cleaned
SET module_name = 'Login'
WHERE LOWER(module_name) = 'login';

UPDATE bugreport_cleaned
SET module_name = 'Dashboard'
Where LOWER(module_name) = 'dashboard';

update bugreport_cleaned
set module_name = 'Report'
where LOWER(module_name) ='report'

update bugreport_cleaned
set module_name = 'Booking'
where LOWER(module_name) ='booking'


-- handling null values 
select top 10 * from bugreport_cleaned;
exec sp_help bugreport_cleaned;

-- handling status by mode most frequent value subquery to find most common status and assigned to that null value
UPDATE bugreport_cleaned
SET status = (
    SELECT TOP 1 status
    FROM bugreport_cleaned
    GROUP BY status
    ORDER BY COUNT(*) DESC
)
WHERE status IS NULL; 
-- after null all counts of status
SELECT count(*) status, status
    FROM bugreport_cleaned
    GROUP BY status
    ORDER BY COUNT(*) DESC
-- unique values checking null still exist
SELECT DISTINCT status
FROM bugreport_cleaned;


--handling priority by mode most frequent value subquery to find most common priority and assigned to that null value


UPDATE bugreport_cleaned
SET priority = (
    SELECT TOP 1 priority
    FROM bugreport_cleaned
    GROUP BY priority
    ORDER BY COUNT(*) DESC
)
WHERE priority IS NULL; 
--After reviewing the data, there are 3,129 NULL values, which is relatively high. From a business perspective, 
--it is advisable to handle these missing values by assigning them a neutral category such as “Medium

update bugreport_cleaned
set priority = 'Medium'
where priority is null;

-- unique values checking null still exist
SELECT DISTINCT priority
FROM bugreport_cleaned;


--handling severity by mode most frequent value subquery to find most common severity and assigned to that null value
update bugreport_cleaned
set severity = ( 
select top 1 severity 
from bugreport_cleaned
group by severity 
order by count(*) desc)
where severity is null

SELECT  count(*) severity ,severity
FROM bugreport_cleaned 
group  by severity

select distinct severity from bugreport_cleaned
select top 15 * from bugreport_cleaned
-- reopen_count null value handling no null then do nothing

select distinct reopen_count from bugreport_cleaned

-- status null value handling no null then do nothing
select distinct status from bugreport_cleaned

-- handle project name null value 
update bugreport_cleaned
set project_name = 'Unknown'
where lower(project_name) = 'unknown'

-- handle module name null value 
update bugreport_cleaned
set module_name = 'Unknown'
where module_name is null

-- handle developer_id  null value 
update bugreport_cleaned
set developer_id = 'Unassigned'
where developer_id is null

-- handle environment_id  null value 
update bugreport_cleaned
set environment_id = 'Undefined'
where environment_id is null

-- handle tester_id  null value 

update bugreport_cleaned
set tester_id = 'Unknown'
where tester_id is null

-- handle root_cause null value 

update bugreport_cleaned
set root_cause = 'Unknown'
where root_cause is null

-- handle release_version null value 

update bugreport_cleaned
set release_version = 'Pending'
where release_version is null


SELECT COUNT(*) AS total_rows
FROM bugreport_cleaned;

-- duplicate bug_ids
SELECT bug_id, COUNT(*) AS duplicate_count
FROM bugreport_cleaned
GROUP BY bug_id
HAVING COUNT(*) > 1;


select * from bugreport_cleaned