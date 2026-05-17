/* =========================================================
   QA ANALYTICS — COMPLETE CONNECTED & MESSY DATASET
   SQL SERVER / SSMS
   ========================================================= */


/* =========================================================
   STEP 1 — CREATE DATABASE
   ========================================================= */

CREATE DATABASE qa_analytics;
GO

USE qa_analytics;
GO


/* =========================================================
   STEP 2 — MASTER TABLES
   ========================================================= */

CREATE TABLE testers (
    tester_id VARCHAR(10) PRIMARY KEY,
    tester_name VARCHAR(100)
);
GO

INSERT INTO testers VALUES
('T101', 'Rahul'),
('T102', 'Sneha'),
('T103', 'Priya'),
('T104', 'Rohit'),
('T105', 'Aman'),
('T106', 'Karan'),
('T107', 'Neha'),
('T108', 'Simran');
GO

select * from testers;
EXEC sp_help[testers];


CREATE TABLE developers (
    developer_id VARCHAR(10) PRIMARY KEY,
    developer_name VARCHAR(100)
);
GO

INSERT INTO developers VALUES
('D201', 'Amit'),
('D202', 'Vikas'),
('D203', 'Mohit'),
('D204', 'Ravi'),
('D205', 'Arjun'),
('D206', 'Ajay'),
('D207', 'Kunal'),
('D208', 'Suresh');
GO

select * from developers;
EXEC sp_help[developers];


CREATE TABLE environment_master (
    environment_id VARCHAR(10) PRIMARY KEY,
    environment_name VARCHAR(50)
);
GO

INSERT INTO environment_master VALUES
('E1', 'Production'),
('E2', 'Staging'),
('E3', 'Testing');
GO

select * from environment_master;
EXEC sp_help[environment_master];



CREATE TABLE release_data (
    release_version VARCHAR(20) PRIMARY KEY,
    release_date DATE,
    total_features INT,
    production_bugs INT,
    sprint_name VARCHAR(50)
);
GO

INSERT INTO release_data VALUES
('v1.0', '2025-01-15', 25, 12, 'Sprint-1'),
('v2.1', '2025-02-10', 30, 18, 'Sprint-2'),
('v3.0', '2025-03-05', 40, 10, 'Sprint-3'),
('v4.1', '2025-04-01', 35, 7,  'Sprint-4'),
('v5.2', '2025-05-01', 50, 5,  'Sprint-5');
GO

select * from release_data;
EXEC sp_help[release_data];


/* =========================================================
   STEP 3 — FACT TABLES
   ========================================================= */

CREATE TABLE bug_reports (
    bug_pk INT IDENTITY(1,1) PRIMARY KEY,
    bug_id VARCHAR(20),
    project_name VARCHAR(100),
    module_name VARCHAR(100),
    severity VARCHAR(50),
    priority VARCHAR(50),
    status VARCHAR(50),
    created_date DATE,
    resolved_date DATE,
    tester_id VARCHAR(10),
    developer_id VARCHAR(10) NULL,
    environment_id VARCHAR(10),
    root_cause VARCHAR(100) NULL,
    reopen_count INT,
    release_version VARCHAR(20),

    FOREIGN KEY (tester_id)
        REFERENCES testers(tester_id),

    FOREIGN KEY (developer_id)
        REFERENCES developers(developer_id),

    FOREIGN KEY (environment_id)
        REFERENCES environment_master(environment_id),

    FOREIGN KEY (release_version)
        REFERENCES release_data(release_version)
);
GO

select * from bug_reports;
exec sp_help [bug_reports];


CREATE TABLE test_execution (
    execution_pk INT IDENTITY(1,1) PRIMARY KEY,
    test_case_id VARCHAR(20),
    module_name VARCHAR(100),
    execution_date DATE,
    execution_status VARCHAR(50) NULL,
    tester_id VARCHAR(10),
    release_version VARCHAR(20),

    FOREIGN KEY (tester_id)
        REFERENCES testers(tester_id),

    FOREIGN KEY (release_version)
        REFERENCES release_data(release_version)
);
GO


/* =========================================================
   STEP 4 — INSERT 10,000 BUG REPORTS
   ========================================================= */

WITH Numbers AS (
    SELECT TOP 10000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS num
    FROM sys.objects a
    CROSS JOIN sys.objects b
)

INSERT INTO bug_reports
(
    bug_id,
    project_name,
    module_name,
    severity,
    priority,
    status,
    created_date,
    resolved_date,
    tester_id,
    developer_id,
    environment_id,
    root_cause,
    reopen_count,
    release_version
)

SELECT
    CONCAT('BUG-', 1000 + num),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 6 + 1,
        'Payment System',
        'Banking App',
        'CRM Portal',
        'Travel Portal',
        'Healthcare App',
        'Ecommerce App'),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 8 + 1,
        'Checkout',
        'Login',
        'Dashboard',
        'Reports',
        'Search',
        'Transfer',
        'Booking',
        'Cart'),

    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 2 THEN 'Critical'
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 20 THEN 'High'
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 90 THEN 'Medium'
        ELSE 'Low'
    END,

    CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1,
        'High',
        'Medium',
        'Low',
        'Critical'),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1,
        'Open',
        'Closed',
        'Reopened'),

    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 120, '2025-01-01'),

    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 140, '2025-01-01'),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 8 + 1,
        'T101',
        'T102',
        'T103',
        'T104',
        'T105',
        'T106',
        'T107',
        'T108'),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 8 + 1,
        'D201',
        'D202',
        'D203',
        'D204',
        'D205',
        'D206',
        'D207',
        'D208'),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1,
        'E1',
        'E2',
        'E3'),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 6 + 1,
        'Validation Issue',
        'API Failure',
        'Database Error',
        'Memory Leak',
        'UI Bug',
        'Calculation Error'),

    ABS(CHECKSUM(NEWID())) % 4,

    CHOOSE(ABS(CHECKSUM(NEWID())) % 5 + 1,
        'v1.0',
        'v2.1',
        'v3.0',
        'v4.1',
        'v5.2')

FROM Numbers;

select * from bug_reports
GO


/* =========================================================
   STEP 5 — INSERT 10,000 TEST EXECUTION ROWS
   ========================================================= */

WITH Numbers AS (
    SELECT TOP 10000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS num
    FROM sys.objects a
    CROSS JOIN sys.objects b
)

INSERT INTO test_execution
(
    test_case_id,
    module_name,
    execution_date,
    execution_status,
    tester_id,
    release_version
)

SELECT
    CONCAT('TC-', 5000 + num),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 8 + 1,
        'Checkout',
        'Login',
        'Dashboard',
        'Reports',
        'Search',
        'Transfer',
        'Booking',
        'Cart'),

    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 150, '2025-01-01'),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1,
        'Passed',
        'Failed',
        'Blocked',
        'Skipped'),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 8 + 1,
        'T101',
        'T102',
        'T103',
        'T104',
        'T105',
        'T106',
        'T107',
        'T108'),

    CHOOSE(ABS(CHECKSUM(NEWID())) % 5 + 1,
        'v1.0',
        'v2.1',
        'v3.0',
        'v4.1',
        'v5.2')

FROM Numbers;

select * from test_execution;
GO


/* =========================================================
   STEP 6 — CREATE MESSY DATA
   ========================================================= */


/* OPEN BUGS WITH NULL RESOLVED DATE */

UPDATE bug_reports
SET resolved_date = NULL
WHERE status = 'Open';
GO


/* CLOSED BUGS ALSO NULL */

UPDATE TOP (300) bug_reports
SET resolved_date = NULL
WHERE status = 'Closed';
GO


/* INCONSISTENT MODULE NAMES */

UPDATE TOP (400) bug_reports
SET module_name = 'login'
WHERE module_name = 'Login';
GO

UPDATE TOP (250) bug_reports
SET module_name = 'LOGIN'
WHERE module_name = 'Login';
GO

UPDATE TOP (150) bug_reports
SET module_name = 'Checkout Module'
WHERE module_name = 'Checkout';
GO

UPDATE TOP (120) bug_reports
SET module_name = 'dashboard'
WHERE module_name = 'Dashboard';
GO


/* MISSING ROOT CAUSE */

UPDATE TOP (700) bug_reports
SET root_cause = NULL;
GO


/* MISSING DEVELOPERS */

UPDATE TOP (500) bug_reports
SET developer_id = NULL;
GO


/* INVALID DATES */

UPDATE TOP (200) bug_reports
SET resolved_date = DATEADD(DAY, -5, created_date)
WHERE resolved_date IS NOT NULL;
GO


/* VERY OLD OPEN BUGS */

UPDATE TOP (250) bug_reports
SET created_date = '2024-01-01',
    resolved_date = NULL,
    status = 'Open';
GO


/* EXTRA SPACES */

UPDATE TOP (200) bug_reports
SET severity = ' High ';
GO

UPDATE TOP (150) bug_reports
SET priority = 'Medium ';
GO

UPDATE TOP (150) bug_reports
SET status = ' Closed';
GO


/* DUPLICATE BUGS */

INSERT INTO bug_reports
(
    bug_id,
    project_name,
    module_name,
    severity,
    priority,
    status,
    created_date,
    resolved_date,
    tester_id,
    developer_id,
    environment_id,
    root_cause,
    reopen_count,
    release_version
)

SELECT TOP 100
    bug_id,
    project_name,
    module_name,
    severity,
    priority,
    status,
    created_date,
    resolved_date,
    tester_id,
    developer_id,
    environment_id,
    root_cause,
    reopen_count,
    release_version
FROM bug_reports;
GO


/* TEST EXECUTION MESSY DATA */

UPDATE TOP (300) test_execution
SET execution_status = NULL;
GO

UPDATE TOP (150) test_execution
SET execution_status = 'pass'
WHERE execution_status = 'Passed';
GO

UPDATE TOP (150) test_execution
SET execution_status = 'FAIL'
WHERE execution_status = 'Failed';
GO

UPDATE TOP (100) test_execution
SET execution_status = 'blocked '
WHERE execution_status = 'Blocked';
GO

UPDATE TOP (100) test_execution
SET execution_date = '2023-01-01';
GO

UPDATE TOP (200) test_execution
SET module_name = 'Search Module'
WHERE module_name = 'Search';
GO

UPDATE TOP (150) test_execution
SET module_name = 'BOOKING'
WHERE module_name = 'Booking';
GO


/* RELEASE DATA MESSY VALUES */

UPDATE TOP (1) release_data
SET production_bugs = NULL;
GO

UPDATE TOP (1) release_data
SET total_features = -5;
GO

UPDATE TOP (1) release_data
SET sprint_name = ' Sprint-3 ';
GO


/* =========================================================
   STEP 7 — VERIFY DATA
   ========================================================= */

SELECT COUNT(*) AS bug_reports_count
FROM bug_reports;

SELECT COUNT(*) AS test_execution_count
FROM test_execution;

SELECT TOP 20 *
FROM bug_reports;

SELECT TOP 20 *
FROM test_execution;

SELECT *
FROM release_data;
GO

