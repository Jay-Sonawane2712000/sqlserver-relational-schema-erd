  IF DB_ID('CreatingTablesDB') IS NULL
CREATE DATABASE CreatingTablesDB;
GO
USE CreatingTablesDB;
GO

/* 

Project: SQL Server Relational Schema + ERD
Author: Jay Sanjay Sonawane
Date: 2026-01-25

Description:
Creates a small relational schema with PK/FK constraints, validation checks,
and test queries to verify tables and relationships.

*/

------------------------------------------------------------
--- DROP TABLES (run first if you need to re-create)
-----------------------------------------------------------------
IF OBJECT_ID('dbo.StudentGrade', 'U') IS NOT NULL DROP TABLE dbo.StudentGrade;
IF OBJECT_ID('dbo.[Class]', 'U') IS NOT NULL DROP TABLE dbo.[Class];
IF OBJECT_ID('dbo.Student', 'U') IS NOT NULL DROP TABLE dbo.Student;
IF OBJECT_ID('dbo.Faculty', 'U') IS NOT NULL DROP TABLE dbo.Faculty;
IF OBJECT_ID('dbo.Course', 'U') IS NOT NULL DROP TABLE dbo.Course;
GO

-----------------------------------------------------------------
-- CREATE TABLE: Course
-------------------------------------------------------------
CREATE TABLE dbo.Course
(
    CourseID          INT            NOT NULL,
    CourseDescription VARCHAR(200)   NOT NULL,
    CourseFee         DECIMAL(10, 2) NOT NULL,

    CONSTRAINT PK_Course PRIMARY KEY (CourseID),
    CONSTRAINT CK_CourseFee_NonNegative CHECK (CourseFee >= 0)
);
GO

--------------------------------------------------------------
-- CREATE TABLE: Faculty
------------------------------------------------------------
CREATE TABLE dbo.Faculty
(
    FacultyID     INT          NOT NULL,
    FirstName     VARCHAR(50)  NOT NULL,
    LastName      VARCHAR(50)  NOT NULL,
    PrimaryEmail  VARCHAR(255) NOT NULL,
    DateOfJoining DATE         NOT NULL,
    WorkPhone     VARCHAR(20)  NULL,

    CONSTRAINT PK_Faculty PRIMARY KEY (FacultyID),
    CONSTRAINT UQ_Faculty_PrimaryEmail UNIQUE (PrimaryEmail)
);
GO

-------------------------------------------------------------
-- CREATE TABLE: Student
------------------------------------------------------------
CREATE TABLE dbo.Student
(
    StudentID    INT         NOT NULL,
    FirstName    VARCHAR(50) NOT NULL,
    LastName     VARCHAR(50) NOT NULL,
    State        CHAR(2)     NULL,
    Zip          VARCHAR(10) NULL,
    Degree       VARCHAR(50) NULL,
    NoOfClasses  INT         NULL,

    CONSTRAINT PK_Student PRIMARY KEY (StudentID),
    CONSTRAINT CK_Student_NoOfClasses_NonNegative CHECK (NoOfClasses IS NULL OR NoOfClasses >= 0)
);
GO

------------------------------------------------------------
-- CREATE TABLE: Class  (Composite PK: ClassID + CourseID)
---------------------------------------------------------------
CREATE TABLE dbo.[Class]
(
    ClassID    INT          NOT NULL,
    CourseID   INT          NOT NULL,
    StartDate  DATE         NOT NULL,
    EndDate    DATE         NULL,
    Location   VARCHAR(100) NULL,

    CONSTRAINT PK_Class PRIMARY KEY (ClassID, CourseID),
    CONSTRAINT FK_Class_Course FOREIGN KEY (CourseID)
        REFERENCES dbo.Course (CourseID),
    CONSTRAINT CK_Class_EndDate CHECK (EndDate IS NULL OR EndDate >= StartDate)
);
GO

--------------------------------------------------------------
-- CREATE TABLE: StudentGrade (Composite PK: StudentID + ClassID + CourseID + FacultyID)
------------------------------------------------------------
CREATE TABLE dbo.StudentGrade
(
    StudentID INT          NOT NULL,
    ClassID   INT          NOT NULL,
    CourseID  INT          NOT NULL,
    FacultyID INT          NOT NULL,
    Grade     DECIMAL(3,2) NULL,   -- accepts values like 3.93, 4.00, etc.

    CONSTRAINT PK_StudentGrade PRIMARY KEY (StudentID, ClassID, CourseID, FacultyID),

    CONSTRAINT FK_StudentGrade_Student FOREIGN KEY (StudentID)
        REFERENCES dbo.Student (StudentID),

    CONSTRAINT FK_StudentGrade_Faculty FOREIGN KEY (FacultyID)
        REFERENCES dbo.Faculty (FacultyID),

    -- Composite FK back to Class table
    CONSTRAINT FK_StudentGrade_Class FOREIGN KEY (ClassID, CourseID)
        REFERENCES dbo.[Class] (ClassID, CourseID),

    -- Optional (redundant but fine): ensures CourseID exists in Course table directly
    CONSTRAINT FK_StudentGrade_Course FOREIGN KEY (CourseID)
        REFERENCES dbo.Course (CourseID),

    CONSTRAINT CK_StudentGrade_GradeRange CHECK (Grade IS NULL OR (Grade >= 0 AND Grade <= 4.00))
);
GO

------------------------------------------------------------------------
-- TEST QUERIES (to show tables were created)
-------------------------------------------------------------------
-- 1) Quick empty selects (no data will return, but should run without error)
SELECT TOP (0) * FROM dbo.Course;
SELECT TOP (0) * FROM dbo.Faculty;
SELECT TOP (0) * FROM dbo.Student;
SELECT TOP (0) * FROM dbo.[Class];
SELECT TOP (0) * FROM dbo.StudentGrade;

-- 2) List tables created
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN ('Course','Faculty','Student','Class','StudentGrade')
ORDER BY TABLE_NAME;

-- 3) List foreign keys (relationships)
SELECT fk.name AS ForeignKeyName,
       OBJECT_NAME(fk.parent_object_id) AS FromTable,
       OBJECT_NAME(fk.referenced_object_id) AS ToTable
FROM sys.foreign_keys fk
WHERE OBJECT_NAME(fk.parent_object_id) IN ('Class','StudentGrade')
ORDER BY FromTable, ForeignKeyName;
GO

