# SQL Server Relational Schema + ERD

A compact SQL Server project demonstrating relational database design and implementation:
- Primary Keys and Foreign Keys
- CHECK / UNIQUE constraints for validation
- Safe DROP + CREATE workflow
- Test queries to verify tables and relationships
- ERD generated using SSMS Database Diagrams

## Schema
Tables:
- Course
- Faculty
- Student
- Class
- StudentGrade

Key relationships:
- Class → Course
- StudentGrade → Student
- StudentGrade → Faculty
- StudentGrade → Course
- StudentGrade → Class (composite)

## How to run (SSMS)
1. Connect to your local SQL Server instance (e.g., `.\SQLEXPRESS`).
2. Run: `sql/schema.sql`
3. Use the test queries at the end of the script to verify objects.

## Artifacts
- ERD: `docs/erd.png`
- SSMS execution proof: `docs/ssms-run.png`
