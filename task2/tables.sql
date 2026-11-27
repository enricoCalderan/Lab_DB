-- This will be based on tables.sql from task 1, extended and corrected to match your final schema.

CREATE TABLE Departments(
    name TEXT PRIMARY KEY,
    abbreviation TEXT NOT NULL,
    UNIQUE (abbreviation)
);

CREATE TABLE Programs(
    name TEXT PRIMARY KEY,
    abbreviation TEXT NOT NULL
);

CREATE TABLE Students (
    idnr CHAR(10) PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES Programs(name),
    UNIQUE (idnr, program)
);

CREATE TABLE Branches(
    name TEXT,
    program TEXT,
    PRIMARY KEY(name, program),
    FOREIGN KEY (program) REFERENCES Programs(name)
);

CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL CHECK(credits > 0),
    department TEXT NOT NULL,
    FOREIGN KEY (department) REFERENCES Departments(name)
);

CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY REFERENCES Courses(code),
    capacity INT NOT NULL CHECK(capacity >= 0)
);

CREATE TABLE StudentBranches(
    student CHAR(10) PRIMARY KEY ,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    FOREIGN KEY (student, program) REFERENCES Students(idnr, program)
);

CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified(
    course CHAR(6) REFERENCES Courses(code),
    classification TEXT NOT NULL REFERENCES Classifications(name),
    PRIMARY KEY (course, classification)
);

CREATE TABLE MandatoryProgramCourses(
    course CHAR(6) REFERENCES Courses(code),
    program TEXT,
    PRIMARY KEY (course, program),
    FOREIGN KEY (program) REFERENCES Programs(name)
);

CREATE TABLE MandatoryBranchCourses(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY(branch, program) REFERENCES Branches(name,program)
);

CREATE TABLE RecommendedBranchCourses(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY(branch, program) REFERENCES Branches(name,program)
);

CREATE TABLE Registered(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);

CREATE TABLE Taken(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    grade char(1) NOT NULL CHECK (grade IN ('U', '3', '4','5')),
    PRIMARY KEY(student, course)
);

CREATE TABLE WaitingList(
    student CHAR(10) REFERENCES Students(idnr),
    course CHAR(6) REFERENCES LimitedCourses(code),
    position INT NOT NULL CHECK (position > 0),
    PRIMARY KEY(student, course),
    UNIQUE (course, position)
);



CREATE TABLE HostedBy(
    department TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(department, program),
    FOREIGN KEY(department) REFERENCES Departments(name),
    FOREIGN KEY(program) REFERENCES Programs(name)
);

CREATE TABLE Prerequisites(
    course CHAR(6) REFERENCES Courses(code),
    prerequisite CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(course, prerequisite)
);