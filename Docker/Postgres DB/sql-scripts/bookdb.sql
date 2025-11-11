-- Create bookData DB
create database bookData;

-- Author Table
create table authors (
  type text,
  key text not null,
  revision integer,
  last_modified date,
  data jsonb,
  constraint pk_author_key primary key (key)
);

-- Author Indexes
create unique index cuix_authors_key on authors (key);
alter table authors cluster on cuix_authors_key;

create index ix_authors_data on authors using gin (data jsonb_path_ops);

-- index name from the jsonb data
create index ix_authors_name on authors using gin ((data->>'name') gin_trgm_ops);

-- Editions Table
create table editions (
  type text,
  key text not null,
  revision integer,
  last_modified date,
  data jsonb,
  constraint pk_editions_key primary key (key)
);

-- Editions Indexes
create unique index cuix_editions_key on editions (key);
alter table editions cluster on cuix_editions_key;

create index ix_editions_workkey on editions (work_key);
create index ix_editions_data on editions using gin (data jsonb_path_ops);

-- index title and subtitle from the jsonb data
create index ix_editions_title on editions using gin ((data->>'title') gin_trgm_ops);
create index ix_editions_subtitle on editions using gin ((data->>'subtitle') gin_trgm_ops);

-- Edition-ISBNs Table
create table edition_isbns (
  edition_key text not null,
  isbn text not null,
  constraint pk_editionisbns_editionkey_isbn primary key (edition_key, isbn)
);

-- Editions- ISBNs Indexes
create unique index cuix_editions_key on editions (key);
alter table editions cluster on cuix_editions_key;

create index ix_editions_workkey on editions (work_key);
create index ix_editions_data on editions using gin (data jsonb_path_ops);

-- index title and subtitle from the jsonb data
create index ix_editions_title on editions using gin ((data->>'title') gin_trgm_ops);
create index ix_editions_subtitle on editions using gin ((data->>'subtitle') gin_trgm_ops);


-- Works Table
create table works (
  type text,
  key text NOT NULL,
  revision integer,
  last_modified date,
  data jsonb,
  constraint pk_works_key primary key(key)
);

-- Works Indexes
create unique index cuix_works_key on works (key);
alter table works cluster on cuix_works_key;

create index ix_works_data on works using gin (data jsonb_path_ops);

-- index title and subtitle from jsonb data
create index ix_works_title on works using gin ((data->>'title') gin_trgm_ops);
create index ix_works_subtitle on works using gin ((data->>'subtitle') gin_trgm_ops);

-- Author_Works Table
create table author_works (
  author_key text not null,
  work_key text not null,
  constraint pk_authorworks_authorkey_workkey primary key (author_key, work_key)
);

