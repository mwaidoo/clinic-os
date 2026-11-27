DROP DATABASE order_db;
CREATE DATABASE order_db;
USE order_db;
SELECT DATABASE();

CREATE TABLE urgency_level (
    id INT AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(32) NOT NULL,
    description VARCHAR(64) NOT NULL,
    CONSTRAINT pk_urgency_level PRIMARY KEY (id),
    CONSTRAINT uq_urgency_level_code UNIQUE (code)
);

CREATE TABLE category (
    id INT AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(32) NOT NULL,
    description VARCHAR(64) NOT NULL,
    CONSTRAINT pk_category PRIMARY KEY (id),
    CONSTRAINT uq_category_code UNIQUE (code)
);

CREATE TABLE medical_order (
    id INT AUTO_INCREMENT,
    policy_set_id INT NOT NULL,
    urgency_level_id INT NOT NULL,
    category_id INT NOT NULL,
    ordering_npi INT NOT NULL,
    servicing_npi INT NOT NULL,
    service_location_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reccommended_completetion_date DATE NOT NULL,
    expires_on DATE NOT NULL COMMENT "defaults to 365 days after order creation",
    CONSTRAINT pk_medical_order PRIMARY KEY (id),
    CONSTRAINT fk_medical_order_category FOREIGN KEY (category_id) REFERENCES category (id)
);

CREATE TABLE authorization_status (
    id INT AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(32) NOT NULL,
    description VARCHAR(64) NOT NULL,
    CONSTRAINT pk_authorization_status PRIMARY KEY (id),
    CONSTRAINT uq_authorization_status_code UNIQUE (code)
);

CREATE TABLE completion_status (
    id INT AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(32) NOT NULL,
    description VARCHAR(64) NOT NULL,
    CONSTRAINT pk_completion_status PRIMARY KEY (id),
    CONSTRAINT uq_completion_status_code UNIQUE (code)
);

-- stores order updates to order completion stage
CREATE TABLE medical_order_completion_status (
    id INT AUTO_INCREMENT,
    medical_order_id INT NOT NULL,
    completion_status_id INT NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_medical_order_completion_status PRIMARY KEY (id),
    /*CONSTRAINT uq_medical_order_completion_status_medical_order_id_completion_status_id */UNIQUE (medical_order_id, completion_status_id),
    CONSTRAINT fk_medical_order_completion_status_medical_order FOREIGN KEY (medical_order_id)
        REFERENCES medical_order (id),
    CONSTRAINT fk_medical_order_completion_status_completion_status FOREIGN KEY (completion_status_id)
        REFERENCES completion_status (id)
);

-- stores order updates to order completion stage
CREATE TABLE medical_order_authorization_status (
    id INT AUTO_INCREMENT,
    medical_order_id INT NOT NULL,
    authorization_status_id INT NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PRIMARY KEY (id),
    CONSTRAINT UNIQUE (medical_order_id, authorization_status_id),
    CONSTRAINT FOREIGN KEY (medical_order_id)
        REFERENCES medical_order (id),
    CONSTRAINT FOREIGN KEY (authorization_status_id)
        REFERENCES authorization_status (id)
);

-- many to many relationship between medical order and cpt code
-- an authorization task or ticket
CREATE TABLE service (
    id INT AUTO_INCREMENT,
    medical_order_id INT NOT NULL,
    cpt_id INT NOT NULL,
    units INT NOT NULL DEFAULT 1,
    CONSTRAINT pk_service PRIMARY KEY (id),
    CONSTRAINT UNIQUE (medical_order_id, cpt_id),
    CONSTRAINT fk_service_medical_order FOREIGN KEY (medical_order_id)
        REFERENCES medical_order (id)
);

-- many to many relationship between service and diagnosis code
/*CREATE TABLE service_diagnosis_code;*/

CREATE TABLE covered_service (
    id INT AUTO_INCREMENT,
    service_id INT NOT NULL,
    maximum_allowable_amount_dollars INT NOT NULL,
    coinsurance_rate DECIMAL(5, 2) NOT NULL,
    copay_dollars INT NOT NULL,
    deductible_applies BOOLEAN NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id)
        REFERENCES service (id)
    #TODO: add check constraints
);

-- services that do not require authorization
CREATE TABLE authorized_service (
    id INT AUTO_INCREMENT,
    service_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (service_id)
        REFERENCES service (id)
);

CREATE TABLE authorization_request (
    id INT AUTO_INCREMENT,
    service_id INT NOT NULL,
    tracking_code VARCHAR(32) NOT NULL,
    units_requested INT NOT NULL,
    submission_date DATE NOT NULL,
    CONSTRAINT pk_authorization_request PRIMARY KEY (id),
    CONSTRAINT fk_authorization_request_service FOREIGN KEY (service_id)
        REFERENCES service (id)
);

 CREATE TABLE denial (
    id INT AUTO_INCREMENT,
    authorization_request_id INT NOT NULL,
    reason VARCHAR(128),
    final BOOLEAN NOT NULL,
    decision_date DATE NOT NULL,
    CONSTRAINT pk_denial PRIMARY KEY (id),
    CONSTRAINT fk_denial_authorization_request FOREIGN KEY (authorization_request_id)
        REFERENCES authorization_request (id)
);

CREATE TABLE appeal (
    id INT AUTO_INCREMENT,
    denial_id INT NOT NULL,
    submission_date DATE NOT NULL,
    CONSTRAINT pk_appeal PRIMARY KEY (id),
    CONSTRAINT fk_appeal_denial FOREIGN KEY (denial_id)
        REFERENCES denial (id)
 );

 CREATE TABLE approval (
    id INT AUTO_INCREMENT,
    authorization_request_id INT NOT NULL,
    approval_code VARCHAR(32) NOT NULL,
    units_approved INT NOT NULL,
    decision_date DATE NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    CONSTRAINT pk_approval PRIMARY KEY (id),
    CONSTRAINT fk_approval_authorization_request FOREIGN KEY (authorization_request_id)
        REFERENCES authorization_request
);

 CREATE TABLE approval_consumption (
    id INT AUTO_INCREMENT,
    approval_id INT NOT NULL,
    appointment_id INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (approval_id, appointment_id),
    FOREIGN KEY (approval_id)
        REFERENCES approval (id)
);