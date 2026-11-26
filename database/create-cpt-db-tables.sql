/*DROP DATABASE cpt_db;*/
/*CREATE DATABASE cpt_db;*/
/*USE cpt_db;*/
/*SELECT DATABASE();*/

CREATE TABLE cpt (
    id INT AUTO_INCREMENT,
    code VARCHAR(16),
    CONSTRAINT pk_cpt PRIMARY KEY (id),
    CONSTRAINT uq_cpt_code UNIQUE (code)
);