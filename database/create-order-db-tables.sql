/*DROP DATABASE order_db;*/
/*CREATE DATABASE order_db;*/
/*USE order_db;*/
/*SELECT DATABASE();*/

CREATE TABLE urgency_level (
    id INT AUTO_INCREMENT,
    code VARCHAR (16) NOT NULL,
    CONSTRAINT pk_urgency_level PRIMARY KEY (id),
    CONSTRAINT uq_urgency_level_code UNIQUE (code)
);

CREATE TABLE order_status (
    id INT AUTO_INCREMENT,
    code VARCHAR (16) NOT NULL,
    CONSTRAINT pk_order_status PRIMARY KEY (id),
    CONSTRAINT uq_order_status_code UNIQUE (code)
);

CREATE TABLE medical_order (
    id INT AUTO_INCREMENT,
    patient_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    urgency_level_id INT NOT NULL,
    order_status_id INT NOT NULL,
    do_within_days INT NOT NULL,
    expiration DATE DEFAULT NULL,
    CONSTRAINT pk_medical_order PRIMARY KEY (id),
    CONSTRAINT fk_medical_order_patient FOREIGN KEY (patient_id)
        REFERENCES patient_db.patient (id),
    CONSTRAINT fk_medical_order_urgency_level FOREIGN KEY (urgency_level_id)
        REFERENCES urgency_level (id),
    CONSTRAINT fk_medical_order_order_status FOREIGN KEY (order_status_id)
        REFERENCES order_status (id),
    CONSTRAINT chk_medical_order_expiration CHECK (expiration > CURRENT_TIMESTAMP)
);

CREATE TABLE ordered_cpt (
    id INT AUTO_INCREMENT,
    order_id INT NOT NULL,
    cpt_id INT NOT NULL,
    CONSTRAINT pk_ordered_cpt PRIMARY KEY (id),
    CONSTRAINT fk_ordered_cpt_medical_order FOREIGN KEY (order_id)
        REFERENCES medical_order (id),
    CONSTRAINT fk_ordered_cpt_cpt FOREIGN KEY (cpt_id)
        REFERENCES cpt_db.cpt (id)
);

CREATE TABLE patient_responsibility (
    id INT AUTO_INCREMENT,
    authorization_request INT NOT NULL,
    maximum_allowable_amount_dollars INT,
    coinsurance_percent INT,
    copay_dollars INT,
    deductible_applies BOOLEAN,
);

CREATE TABLE authorization_status (
    id INT AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL,
    CONSTRAINT pk_authorization_status PRIMARY KEY (id),
    CONSTRAINT uq_authorization_status_code UNIQUE (code)
);

CREATE TABLE authorization_request (
    id INT AUTO_INCREMENT,
    case_number VARCHAR(32),
    ordered_cpt_id INT NOT NULL,
    authorization_status_id INT NOT NULL,
    units_requested INT NOT NULL,
    submission_date DATE NOT NULL,
    submitted_via VARCHAR(16) NOT NULL,
    faxed_to CHAR(11) NULL,
    CONSTRAINT pk_authorization_request PRIMARY KEY (id),
    CONSTRAINT fk_authorization_request_ordered_cpt FOREIGN KEY (ordered_cpt_id)
        REFERENCES ordered_cpt (id),
    CONSTRAINT fk_authorization_request_authorization_status FOREIGN KEY (authorization_status_id)
        REFERENCES authorization_status (id)
 );

 CREATE TABLE denial (
    id INT AUTO_INCREMENT,
    authorization_request_id INT NOT NULL,
    reason VARCHAR(128),
    final BOOLEAN,
    decision_date DATE NOT NULL,
    CONSTRAINT pk_denial PRIMARY KEY (id),
    CONSTRAINT fk_authorization_request FOREIGN KEY (authorization_request_id)
        REFERENCES authorization_request(id)
 );

CREATE TABLE appeal (
    id INT AUTO_INCREMENT,
    denial_id INT NOT NULL,
    submission_date DATE NOT NULL,
    submitted_via VARCHAR(16) NOT NULL,
    faxed_to CHAR(11) NULL,
    CONSTRAINT pk_appeal PRIMARY KEY (id),
    CONSTRAINT fk_appeal_denial FOREIGN KEY (denial_id)
        REFERENCES denial (id),
 );

 CREATE TABLE approval (
    id INT AUTO_INCREMENT,
    authorization_request_id INT NOT NULL,
    approval_number VARCHAR(32) NOT NULL,
    decision_date DATE NOT NULL,
    approved_from DATE NOT NULL,
    approved_through DATE NOT NULL,
    CONSTRAINT pk_approval PRIMARY KEY (id),
    CONSTRAINT fk_approval_authorization_request FOREIGN KEY (authorization_request_id)
        REFERENCES authorization_request
 );

CREATE TABLE call_log;

CREATE TABLE online_inquiry_log;

 CREATE TABLE consumption (
    approval_id INT NOT NULL,
    appointment_id INT NOT NULL,
    CONSTRAINT pk_consumption PRIMARY KEY (approval_id, appointment_id),
    CONSTRAINT fk_consumption_approval FOREIGN KEY (approval_id)
        REFERENCES approval (id),
    CONSTRAINT fk_consumption_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointment_db.appointment (id)
 );