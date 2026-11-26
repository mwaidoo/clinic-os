/*DROP DATABASE appointment_db;*/
/*CREATE DATABASE appointment_db;*/
/*USE appointment_db;*/
/*SELECT DATABASE();*/

CREATE TABLE appointment_type (
    id INT AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 15,
    CONSTRAINT chk_appointment_type_duration_minutes CHECK (duration_minutes > 0),
    CONSTRAINT pk_appointment_type PRIMARY KEY (id),
    CONSTRAINT uq_appointment_type_name UNIQUE (name)
)  ENGINE=INNODB DEFAULT CHARACTER SET UTF8MB4 COLLATE UTF8MB4_0900_AS_CS;

CREATE TABLE appointment_status (
    id INT AUTO_INCREMENT,
    name VARCHAR(32) NOT NULL,
    code VARCHAR(16) NOT NULL,
    CONSTRAINT pk_appointment_status PRIMARY KEY (id),
    CONSTRAINT uq_appointment_status_name UNIQUE (name),
    CONSTRAINT uq_appointment_status_code UNIQUE (code)
)  ENGINE=INNODB DEFAULT CHARACTER SET UTF8MB4 COLLATE UTF8MB4_0900_AS_CS;

CREATE TABLE appointment (
    id INT AUTO_INCREMENT,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    appointment_type_id INT NOT NULL,
    appointment_status_id INT NOT NULL,
    CONSTRAINT pk_appointment PRIMARY KEY (id),
    CONSTRAINT chk_appointment_time CHECK (end_time > start_time),
    CONSTRAINT fk_appointment_appointment_type FOREIGN KEY (appointment_type_id)
        REFERENCES appointment_type (id),
    CONSTRAINT fk_appointment_appointment_status FOREIGN KEY (appointment_status_id)
        REFERENCES appointment_status (id)
)  ENGINE=INNODB DEFAULT CHARACTER SET UTF8MB4 COLLATE UTF8MB4_0900_AS_CS;

CREATE TABLE reservation (
    appointment_id INT NOT NULL,
    resource_id INT NOT NULL,
    CONSTRAINT pk_reservation PRIMARY KEY (appointment_id , resource_id),
    CONSTRAINT fk_reservation_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointment (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_reservation_resource FOREIGN KEY (resource_id)
        REFERENCES resource (id),
    INDEX idx_reservation_resource (resource_id , appointment_id)
)  ENGINE=INNODB DEFAULT CHARACTER SET UTF8MB4 COLLATE UTF8MB4_0900_AS_CS;