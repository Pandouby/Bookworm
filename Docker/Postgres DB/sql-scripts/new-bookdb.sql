-- Create Language table
CREATE TABLE Languages (
    language_id VARCHAR(50) PRIMARY KEY,
    print_name VARCHAR(255) NOT NULL,
    inverted_name VARCHAR(255)
);

-- Create Author table
CREATE TABLE Authors (
    author_key VARCHAR(50) PRIMARY KEY,
    author_name VARCHAR(255) NOT NULL,
    birth_date VARCHAR(50),
    death_date VARCHAR(50),
    wikipedia VARCHAR(500)
);

-- Create Work table
CREATE TABLE Works (
    work_key VARCHAR(50) PRIMARY KEY,
    work_title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    work_description TEXT,
    first_publish_date DATE,
    revision INT
);

-- Create Subject table
CREATE TABLE Subjects (
    subject_id VARCHAR(100) PRIMARY KEY,
    subject_name VARCHAR(255) NOT NULL
);

-- Create Publisher table
CREATE TABLE Publishers (
    publisher_id VARCHAR(100) PRIMARY KEY,
    publisher_name VARCHAR(255) NOT NULL
);

-- Create Genre table
CREATE TABLE Genres (
    genre_id VARCHAR(100) PRIMARY KEY,
    genre_name VARCHAR(255) NOT NULL
);

-- Create Edition table
CREATE TABLE Editions (
    work_key VARCHAR(50),
    edition_key VARCHAR(50) PRIMARY KEY,
    physical_format VARCHAR(100),
    edition_title VARCHAR(500),
    edition_description TEXT,
    number_of_pages INT,
    isbn_13 VARCHAR(20),
    isbn_10 VARCHAR(20),
    publish_date DATE,
    oclc_number VARCHAR(50),
    revision INT,
    FOREIGN KEY (work_key) REFERENCES Works(work_key)
);

-- Create work_language junction table
CREATE TABLE works_languages (
    work_key VARCHAR(50),
    language_id VARCHAR(50),
    PRIMARY KEY (work_key, language_id),
    FOREIGN KEY (work_key) REFERENCES Works(work_key),
    FOREIGN KEY (language_id) REFERENCES Languages(language_id)
);

-- Create edition_language junction table
CREATE TABLE editions_languages (
    edition_key VARCHAR(50),
    language_id VARCHAR(50),
    PRIMARY KEY (edition_key, language_id),
    FOREIGN KEY (edition_key) REFERENCES Editions(edition_key),
    FOREIGN KEY (language_id) REFERENCES Languages(language_id)
);

-- Create Author_Work junction table
CREATE TABLE Authors_Works (
    author_key VARCHAR(50),
    work_key VARCHAR(50),
    PRIMARY KEY (author_key, work_key),
    FOREIGN KEY (author_key) REFERENCES Authors(author_key),
    FOREIGN KEY (work_key) REFERENCES Works(work_key)
);

-- Create Work_subject junction table
CREATE TABLE Works_subjects (
    work_key VARCHAR(50),
    subject_id VARCHAR(100),
    PRIMARY KEY (work_key, subject_id),
    FOREIGN KEY (work_key) REFERENCES Works(work_key),
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id)
);

-- Create Edition_subject junction table
CREATE TABLE Editions_subjects (
    edition_key VARCHAR(50),
    subject_id VARCHAR(100),
    PRIMARY KEY (edition_key, subject_id),
    FOREIGN KEY (edition_key) REFERENCES Editions(edition_key),
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id)
);

-- Create edition_publisher junction table
CREATE TABLE editions_publishers (
    edition_key VARCHAR(50),
    publisher_id VARCHAR(100),
    PRIMARY KEY (edition_key, publisher_id),
    FOREIGN KEY (edition_key) REFERENCES Editions(edition_key),
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id)
);

-- Create edition_genre junction table
CREATE TABLE editions_genres (
    edition_key VARCHAR(50),
    genre_id VARCHAR(100),
    PRIMARY KEY (edition_key, genre_id),
    FOREIGN KEY (edition_key) REFERENCES Editions(edition_key),
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
);

-- Create Rating table
CREATE TABLE Ratings (
    edition_key VARCHAR(50) NOT NULL,
    rating_id BIGSERIAL NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    rating_date DATE NOT NULL,
    PRIMARY KEY (edition_key, rating_id),
    FOREIGN KEY (edition_key) REFERENCES Editions(edition_key)
);

-- Create indexes for better query performance
CREATE INDEX idx_work_title ON Works(work_title);
CREATE INDEX idx_author_name ON Authors(author_name);
CREATE INDEX idx_edition_work ON Editions(work_key);
CREATE INDEX idx_rating_edition ON Ratings(edition_key);
CREATE INDEX idx_rating_date ON Ratings(rating_date);

-- Clear DB
-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;

-- Clear Table
-- DELETE FROM Works;
