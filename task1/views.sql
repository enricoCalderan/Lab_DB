
/* 1 VIEW */

CREATE VIEW BasicInformation AS(
    SELECT idnr, name, login, Students.program, branch
    FROM Students
    LEFT JOIN StudentBranches
    ON idnr = student
);

--SELECT * FROM BasicInformation;


/* 2 VIEW */

CREATE VIEW FinishedCourses AS(
    SELECT student, course, name AS courseName, grade, credits
    FROM Taken
    JOIN Courses
    ON course = code
);

--SELECT * FROM FinishedCourses;


/* 3 VIEW */

CREATE VIEW Registrations AS(
    SELECT student, course, 'registered' AS status
    FROM Registered
)   UNION(
    SELECT student, course, 'waiting' AS status
    FROM WaitingList
);

--SELECT * FROM Registrations;


/* 4 VIEW (with supporting views) */

CREATE VIEW PassedCourses AS(
    SELECT student, course, credits
    FROM FinishedCourses
    WHERE grade != 'U'
);

--SELECT * FROM PassedCourses;


CREATE VIEW UnreadMandatory AS
(
    SELECT idnr AS student, course
    FROM Students
    JOIN MandatoryProgram USING (program)
)
UNION
(
    SELECT student, course
    FROM StudentBranches
    JOIN MandatoryBranch
    USING (branch,program)
)
EXCEPT
(
    SELECT student, course
    FROM PassedCourses
);

--SELECT * FROM UnreadMandatory;

CREATE VIEW RecommendedCourses AS(
    SELECT student, course, credits
    FROM PassedCourses
    JOIN StudentBranches USING (student)
    JOIN RecommendedBranch USING (course, branch, program)
);

--SELECT * FROM RecommendedCourses;


CREATE VIEW PathToGraduation AS(
    WITH
        TotalCredits AS (
            SELECT student, SUM(credits) AS totalCredits
            FROM PassedCourses
            GROUP BY student
        ),
        MandatoryLeft AS (
            SELECT student, COUNT(*) AS mandatoryLeft
            FROM UnreadMandatory
            GROUP BY student
        ),
        MathCredits AS (
            SELECT student, SUM(credits) AS mathCredits
            FROM PassedCourses
            JOIN Classified USING (course)
            WHERE classification = 'math'
            GROUP BY student
        ),
        SeminarCourses AS (
            SELECT student, COUNT(*) AS seminarCourses
            FROM PassedCourses
            JOIN Classified USING (course)
            WHERE classification = 'seminar'
            GROUP BY student
        ),
        RecommendedCredits AS (
            SELECT student, SUM(credits) AS recommendedCredits
            FROM RecommendedCourses
            GROUP BY student
        )
    SELECT
        Students.idnr AS student,
        COALESCE(totalCredits, 0) AS totalCredits,
        COALESCE(mandatoryLeft, 0) AS mandatoryLeft,
        COALESCE(mathCredits, 0) AS mathCredits,
        COALESCE(seminarCourses, 0) AS seminarCourses,
        (
            StudentBranches.branch IS NOT NULL
            AND COALESCE(mandatoryLeft, 0) = 0
            AND COALESCE(recommendedCredits, 0) >= 10
            AND COALESCE(mathCredits, 0) >= 20
            AND COALESCE(seminarCourses, 0) >= 1
        ) AS qualified
    FROM Students
    LEFT JOIN StudentBranches ON Students.idnr = StudentBranches.student
    LEFT JOIN TotalCredits ON Students.idnr = TotalCredits.student
    LEFT JOIN MandatoryLeft ON Students.idnr = MandatoryLeft.student
    LEFT JOIN MathCredits ON Students.idnr = MathCredits.student
    LEFT JOIN SeminarCourses ON Students.idnr = SeminarCourses.student
    LEFT JOIN RecommendedCredits ON Students.idnr = RecommendedCredits.student
);

--SELECT * FROM PathToGraduation;