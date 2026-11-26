/*DROP DATABASE resource_db;*/
/*CREATE DATABASE resource_db;*/
/*USE resource_db;*/
/*SELECT DATABASE();*/

CREATE TABLE resource_category (
    id INT AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL,
    code VARCHAR(16) NOT NULL,
    max_concurrent_reservations INT NOT NULL DEFAULT 1,
    CONSTRAINT pk_resource_category PRIMARY KEY (id),
    CONSTRAINT uq_resource_category_name UNIQUE (name),
    CONSTRAINT uq_resource_category_code UNIQUE (code),
    CONSTRAINT chk_resource_max_concurrent_reservations CHECK (max_concurrent_reservations > 0)
)  ENGINE=INNODB DEFAULT CHARACTER SET UTF8MB4 COLLATE UTF8MB4_0900_AS_CS;

CREATE TABLE resource (
    id INT AUTO_INCREMENT,
    resource_category_id INT NOT NULL,
    name VARCHAR(64) NOT NULL,
    code VARCHAR(16) NOT NULL,
    CONSTRAINT pk_resource PRIMARY KEY (id),
    CONSTRAINT fk_resource_resource_category FOREIGN KEY (resource_category_id)
        REFERENCES resource_category (id),
    CONSTRAINT uq_resource_name UNIQUE (name),
    CONSTRAINT uq_resource_code UNIQUE (code)
)  ENGINE=INNODB DEFAULT CHARACTER SET UTF8MB4 COLLATE UTF8MB4_0900_AS_CS;

CREATE TABLE room;
CREATE TABLE sonograph;
CREATE TABLE electrocardiograph;
CREATE TABLE office;
CREATE TABLE staff;
CREATE TABLE nurse;
CREATE TABLE doctor;
CREATE TABLE sonographer;
CREATE TABLE pager;
CREATE TABLE phone;
CREATE TABLE medical_assistant;
CREATE TABLE chair;
CREATE TABLE person;
CREATE TABLE blood_pressure_monitor;
CREATE TABLE computer;