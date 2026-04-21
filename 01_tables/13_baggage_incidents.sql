-- ============================================
-- BAGGAGE INCIDENTS (ADR-001)
-- ============================================

CREATE TABLE baggage_incident_status (
    baggage_incident_status_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code varchar(20) NOT NULL,
    status_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_baggage_incident_status_code UNIQUE (status_code),
    CONSTRAINT uq_baggage_incident_status_name UNIQUE (status_name)
);

CREATE TABLE baggage_incident_type (
    baggage_incident_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code varchar(20) NOT NULL,
    type_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_baggage_incident_type_code UNIQUE (type_code),
    CONSTRAINT uq_baggage_incident_type_name UNIQUE (type_name)
);

CREATE TABLE baggage_incident (
    baggage_incident_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baggage_id uuid NOT NULL REFERENCES baggage(baggage_id),
    airport_id uuid REFERENCES airport(airport_id),
    reported_by_customer_id uuid REFERENCES customer(customer_id),
    baggage_incident_status_id uuid NOT NULL REFERENCES baggage_incident_status(baggage_incident_status_id),
    baggage_incident_type_id uuid NOT NULL REFERENCES baggage_incident_type(baggage_incident_type_id),
    report_code varchar(30) NOT NULL,
    reported_at timestamptz NOT NULL,
    description text,
    estimated_resolution_at timestamptz,
    resolved_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_baggage_incident_report_code UNIQUE (report_code),
    CONSTRAINT ck_baggage_incident_dates CHECK (
        (estimated_resolution_at IS NULL OR estimated_resolution_at >= reported_at)
        AND (resolved_at IS NULL OR resolved_at >= reported_at)
    )
);

CREATE TABLE baggage_incident_event (
    baggage_incident_event_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    baggage_incident_id uuid NOT NULL REFERENCES baggage_incident(baggage_incident_id),
    recorded_by_user_id uuid REFERENCES user_account(user_account_id),
    event_code varchar(30) NOT NULL,
    event_description varchar(200) NOT NULL,
    occurred_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_baggage_incident_event UNIQUE (baggage_incident_id, event_code, occurred_at)
);

COMMENT ON TABLE baggage_incident IS 'Registro operacional para trazabilidad de equipaje perdido, retrasado o averiado.';
COMMENT ON TABLE baggage_incident_event IS 'Seguimiento cronologico de la atencion del incidente de equipaje.';
