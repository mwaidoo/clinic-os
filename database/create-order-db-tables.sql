
DROP DATABASE IF EXISTS order_db;
CREATE DATABASE order_db;
USE order_db;

CREATE TABLE urgency_level (
    id INT AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(32) NOT NULL,
    description VARCHAR(255),

    CONSTRAINT pk_urgency_level PRIMARY KEY (id),
    CONSTRAINT uq_urgency_level_code UNIQUE (code)
);

CREATE TABLE category (
    id INT AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(32) NOT NULL,
    description VARCHAR(255),

    CONSTRAINT pk_category PRIMARY KEY (id),
    CONSTRAINT uq_category_code UNIQUE (code)
);

CREATE TABLE completion_status (
    id INT AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(32) NOT NULL,
    description VARCHAR(255),

    CONSTRAINT pk_completion_status PRIMARY KEY (id),
    CONSTRAINT uq_completion_status_code UNIQUE (code)
);

CREATE TABLE medical_order (
    id INT AUTO_INCREMENT,
    policy_set_id INT NOT NULL,
    urgency_level_id INT NOT NULL,
    category_id INT NOT NULL,
    ordering_npi CHAR(10) NOT NULL,
    servicing_npi CHAR(10) NOT NULL,
    service_location_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    recommended_completion_date DATE NULL DEFAULT NULL,
    expires_on DATE NOT NULL,

    CONSTRAINT pk_medical_order PRIMARY KEY (id),

    CONSTRAINT fk_medical_order_urgency_level
        FOREIGN KEY (urgency_level_id)
        REFERENCES urgency_level (id),

    CONSTRAINT fk_medical_order_category
        FOREIGN KEY (category_id)
        REFERENCES category (id)
);

CREATE TABLE medical_order_completion_status (
    id INT AUTO_INCREMENT,
    medical_order_id INT NOT NULL,
    completion_status_id INT NOT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_medical_order_completion_status PRIMARY KEY (id),

    CONSTRAINT fk_mocs_medical_order
        FOREIGN KEY (medical_order_id)
        REFERENCES medical_order (id),

    CONSTRAINT fk_mocs_completion_status
        FOREIGN KEY (completion_status_id)
        REFERENCES completion_status (id)
);

CREATE TABLE service (
    id INT AUTO_INCREMENT,
    medical_order_id INT NOT NULL,
    cpt_id INT NOT NULL,
    units INT NOT NULL DEFAULT 1,

    CONSTRAINT pk_service PRIMARY KEY (id),

    CONSTRAINT uq_service_order_cpt
        UNIQUE (medical_order_id, cpt_id),

    CONSTRAINT fk_service_medical_order
        FOREIGN KEY (medical_order_id)
        REFERENCES medical_order (id),

    CONSTRAINT chk_service_units
        CHECK (units > 0)
);

CREATE TABLE covered_service (
    id INT AUTO_INCREMENT,
    service_id INT NOT NULL,
    maximum_allowable_amount DECIMAL(10,2) NOT NULL,
    coinsurance_rate DECIMAL(5,2) NOT NULL,
    copay_amount DECIMAL(10,2) NOT NULL,
    deductible_applies BOOLEAN NOT NULL,
    determined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_covered_service PRIMARY KEY (id),

    CONSTRAINT uq_covered_service_service
        UNIQUE (service_id),

    CONSTRAINT fk_covered_service_service
        FOREIGN KEY (service_id)
        REFERENCES service (id),

    CONSTRAINT chk_covered_maximum_allowable_amount
        CHECK (maximum_allowable_amount >= 0),

    CONSTRAINT chk_covered_coinsurance_rate
        CHECK (coinsurance_rate BETWEEN 0 AND 100),

    CONSTRAINT chk_covered_copay_amount
        CHECK (copay_amount >= 0)
);

CREATE TABLE non_covered_service (
    id INT AUTO_INCREMENT,
    service_id INT NOT NULL,
    determined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_non_covered_service PRIMARY KEY (id),

    CONSTRAINT uq_non_covered_service_service
        UNIQUE (service_id),

    CONSTRAINT fk_non_covered_service_service
        FOREIGN KEY (service_id)
        REFERENCES service (id)
);

CREATE TABLE authorization_exemption (
    id INT AUTO_INCREMENT,
    service_id INT NOT NULL,

    CONSTRAINT pk_authorization_exemption PRIMARY KEY (id),

    CONSTRAINT uq_authorization_exemption_service
        UNIQUE (service_id),

    CONSTRAINT fk_authorization_exemption_service
        FOREIGN KEY (service_id)
        REFERENCES service (id)
);

CREATE TABLE authorization_request (
    id INT AUTO_INCREMENT,
    service_id INT NOT NULL,
    units_requested INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_authorization_request PRIMARY KEY (id),

    CONSTRAINT uq_authorization_request_service
        UNIQUE (service_id),

    CONSTRAINT fk_authorization_request_service
        FOREIGN KEY (service_id)
        REFERENCES service (id),

    CONSTRAINT chk_authorization_request_units
        CHECK (units_requested > 0)
);

CREATE TABLE authorization_submission (
    id INT AUTO_INCREMENT,
    authorization_request_id INT NOT NULL,
    tracking_code VARCHAR(32) NOT NULL,
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_authorization_submission PRIMARY KEY (id),

    CONSTRAINT fk_authorization_submission_request
        FOREIGN KEY (authorization_request_id)
        REFERENCES authorization_request (id)
);

CREATE TABLE denial (
    id INT AUTO_INCREMENT,
    authorization_request_id INT NOT NULL,
    reason VARCHAR(255),
    final BOOLEAN NOT NULL DEFAULT FALSE,
    decision_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_denial PRIMARY KEY (id),

    CONSTRAINT fk_denial_authorization_request
        FOREIGN KEY (authorization_request_id)
        REFERENCES authorization_request (id)
);

CREATE TABLE appeal (
    id INT AUTO_INCREMENT,
    denial_id INT NOT NULL,
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_appeal PRIMARY KEY (id),

    CONSTRAINT fk_appeal_denial
        FOREIGN KEY (denial_id)
        REFERENCES denial (id)
);

CREATE TABLE approval (
    id INT AUTO_INCREMENT,
    authorization_request_id INT NOT NULL,
    approval_code VARCHAR(32) NOT NULL,
    units_approved INT NOT NULL,
    decision_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,

    CONSTRAINT pk_approval PRIMARY KEY (id),

    CONSTRAINT fk_approval_authorization_request
        FOREIGN KEY (authorization_request_id)
        REFERENCES authorization_request (id),

    CONSTRAINT chk_approval_units
        CHECK (units_approved > 0),

    CONSTRAINT chk_approval_dates
        CHECK (expiration_date >= effective_date)
);

CREATE TABLE approval_consumption (
    id INT AUTO_INCREMENT,
    approval_id INT NOT NULL,
    appointment_id INT NOT NULL,
    units_consumed INT NOT NULL,

    CONSTRAINT pk_approval_consumption PRIMARY KEY (id),

    CONSTRAINT uq_approval_consumption
        UNIQUE (approval_id, appointment_id),

    CONSTRAINT fk_approval_consumption_approval
        FOREIGN KEY (approval_id)
        REFERENCES approval (id),

    CONSTRAINT chk_approval_consumption_units
        CHECK (units_consumed > 0)
);
