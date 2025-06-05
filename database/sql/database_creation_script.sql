DROP DATABASE IF EXISTS ai_sdgs;
CREATE DATABASE ai_sdgs;

USE ai_sdgs;

DROP TABLE IF EXISTS articles;
CREATE TABLE articles (
	eid VARCHAR(50),
    title VARCHAR(500),
    year_pub INT,
    sdg CHAR(3),
    journal VARCHAR(255),
    cited_by INT,
    doi VARCHAR(255),
    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES articles_algorithms(eid)
);

ALTER TABLE articles
ADD COLUMN authors TEXT;
ALTER TABLE articles
MODIFY COLUMN title TEXT,
MODIFY COLUMN journal TEXT;


DROP TABLE IF EXISTS empirical_data;
CREATE TABLE empirical_data (
	eid VARCHAR(50),
    abstract TEXT,
    AI_scope VARCHAR(255),
    AI_as_buzzword BOOL,
	core_topic TEXT,
    means_vs_ends VARCHAR(255),
    sustainability_definition TEXT,
    spatial_scale VARCHAR(255),
    temporal_scope VARCHAR (255),
    temporal_scale VARCHAR (255),
    methodology VARCHAR (255),
    country_study VARCHAR(255),
    dataset_used TEXT,
    country_author VARCHAR(255),
    policy_recommendations BOOL,    
    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES articles(eid)
);

DROP TABLE IF EXISTS sus_lvl;
CREATE TABLE sus_lvl (
	eid VARCHAR(50),
	sustainability_conceptualization VARCHAR(50), 
    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES articles(eid)
);

DROP TABLE IF EXISTS type_of_article;
CREATE TABLE type_of_article (
	eid VARCHAR(50),
	article_type VARCHAR(50), 
    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES articles(eid)
);

DROP TABLE IF EXISTS articles_algorithms;
CREATE TABLE articles_algorithms (
	eid VARCHAR(50),
    algorithms VARCHAR(255),
    PRIMARY KEY (eid, algorithms),
    FOREIGN KEY (algorithms) REFERENCES algorithms_list(algorithms)
);

DROP TABLE IF EXISTS algorithms_list;
CREATE TABLE algorithms_list (
	algorithms VARCHAR(255), 
    algorithm_name TEXT,
    PRIMARY KEY (algorithms)
);
ALTER TABLE algorithms_list
MODIFY COLUMN algorithm_name TEXT;



DROP TABLE IF EXISTS algorithms_aitype;
CREATE TABLE algorithms_aitype (
    algorithms VARCHAR(255),
    ai_type VARCHAR(255),
    PRIMARY KEY (algorithms, ai_type),
    FOREIGN KEY (algorithms) REFERENCES algorithms_list(algorithms),
    FOREIGN KEY (ai_type) REFERENCES ai_type_list(ai_type)
);

DROP TABLE IF EXISTS ai_type_list;
CREATE TABLE ai_type_list (
	ai_type VARCHAR(255), 
    PRIMARY KEY (ai_type)
);

DROP TABLE IF EXISTS algorithms_tasktype;
CREATE TABLE algorithms_tasktype (
    algorithms VARCHAR(255),
    task_type VARCHAR(255),
    PRIMARY KEY (algorithms, task_type),
    FOREIGN KEY (algorithms) REFERENCES algorithms_list(algorithms),
    FOREIGN KEY (task_type) REFERENCES task_type_list(task_type)
);

DROP TABLE IF EXISTS task_type_list;
CREATE TABLE task_type_list (
	task_type VARCHAR(255), 
    PRIMARY KEY (task_type)
);

DROP TABLE IF EXISTS role_AI;
CREATE TABLE role_AI (
	eid VARCHAR(50),
	role_of_AI VARCHAR(255), 
    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES articles(eid)
);


DROP TABLE IF EXISTS clusters;
CREATE TABLE clusters (
	eid VARCHAR(50),
    words TEXT,
    cluster_number CHAR(5),
    cluster_name VARCHAR(255),
    article_file TEXT,
    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES articles(eid)
);

SELECT * FROM clusters;

DROP TABLE IF EXISTS clusters_revcon;
CREATE TABLE clusters_revcon (
	eid VARCHAR(50),
    words TEXT,
    cluster_number CHAR(5),
    cluster_name VARCHAR(255),
    article_file TEXT,
    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES articles(eid)
);

SELECT * FROM clusters_revcon;