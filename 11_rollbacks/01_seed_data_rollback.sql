BEGIN;

DELETE FROM baggage_incident_event WHERE baggage_incident_id IN (
    SELECT baggage_incident_id FROM baggage_incident WHERE report_code = 'INC-BAG-0001'
);
DELETE FROM baggage_incident WHERE report_code = 'INC-BAG-0001';
DELETE FROM baggage_incident_status WHERE status_code IN ('OPEN', 'IN_REVIEW', 'RESOLVED');
DELETE FROM baggage_incident_type WHERE type_code IN ('LOST', 'DELAYED', 'DAMAGED');

DELETE FROM boarding_validation WHERE notes = 'Validacion operativa correcta.';
DELETE FROM boarding_pass WHERE boarding_pass_code = 'BP-20250414-0001';
DELETE FROM check_in WHERE checked_in_at = TIMESTAMPTZ '2025-04-14 07:00:00-05';
DELETE FROM baggage WHERE baggage_tag = 'BG-0001';
DELETE FROM seat_assignment WHERE assigned_at = TIMESTAMPTZ '2025-04-14 06:07:00-05';
DELETE FROM ticket_segment WHERE fare_basis_code = 'YFLEX';
DELETE FROM ticket WHERE ticket_number = '220000000001';
DELETE FROM payment_transaction WHERE transaction_reference = 'TX-20250414-0001';
DELETE FROM payment WHERE payment_reference = 'PAY-20250414-0001';
DELETE FROM invoice_line WHERE invoice_id IN (SELECT invoice_id FROM invoice WHERE invoice_number = 'FAC-20250414-0001');
DELETE FROM invoice WHERE invoice_number = 'FAC-20250414-0001';
DELETE FROM exchange_rate WHERE effective_date = DATE '2025-04-14';
DELETE FROM sale WHERE sale_code = 'SALE-20250414-0001';
DELETE FROM reservation_passenger WHERE passenger_sequence_no = 1 AND passenger_type = 'ADULT';
DELETE FROM reservation WHERE reservation_code = 'RSV-20250414-0001';
DELETE FROM fare WHERE fare_code = 'MDEBOG-YFLEX';
DELETE FROM fare_class WHERE fare_class_code = 'YFLEX';
DELETE FROM flight_delay WHERE reported_at = TIMESTAMPTZ '2025-04-14 07:50:00-05';
DELETE FROM flight_segment WHERE scheduled_departure_at = TIMESTAMPTZ '2025-04-14 08:00:00-05';
DELETE FROM flight WHERE flight_number = 'SN1001' AND service_date = DATE '2025-04-14';
DELETE FROM maintenance_event WHERE started_at = TIMESTAMPTZ '2025-04-10 08:00:00-05';
DELETE FROM maintenance_provider WHERE provider_name = 'MRO Medellin';
DELETE FROM aircraft_seat WHERE aircraft_cabin_id IN (SELECT aircraft_cabin_id FROM aircraft_cabin WHERE cabin_code = 'ECO-1');
DELETE FROM aircraft_cabin WHERE cabin_code = 'ECO-1';
DELETE FROM aircraft WHERE registration_number = 'HK-0001';
DELETE FROM aircraft_model WHERE model_code = 'A320';
DELETE FROM airport_regulation WHERE regulation_code IN ('OPS-001', 'OPS-002');
DELETE FROM runway WHERE runway_code IN ('01L/19R', '14L/32R');
DELETE FROM boarding_gate WHERE gate_code IN ('A1', 'B2');
DELETE FROM terminal WHERE terminal_code = 'T1';
DELETE FROM airport WHERE iata_code IN ('MDE', 'BOG');
DELETE FROM customer_benefit WHERE notes = 'Beneficio inicial de onboarding.';
DELETE FROM miles_transaction WHERE reference_code = 'FLIGHT-SN1001';
DELETE FROM loyalty_account_tier WHERE assigned_at = TIMESTAMPTZ '2025-01-10 09:00:00-05';
DELETE FROM loyalty_account WHERE account_number = 'SM-0001';
DELETE FROM loyalty_tier WHERE tier_code = 'CLASSIC';
DELETE FROM loyalty_program WHERE program_code = 'SENA-MILES';
DELETE FROM customer WHERE customer_since = DATE '2025-01-10';
DELETE FROM user_role WHERE user_account_id IN (SELECT user_account_id FROM user_account WHERE username = 'laura.gonzalez');
DELETE FROM user_account WHERE username = 'laura.gonzalez';
DELETE FROM person_contact WHERE contact_value IN ('laura.gonzalez@senair.test', 'carlos.ramirez@correo.test');
DELETE FROM person_document WHERE document_number IN ('1020304050', '1122334455');
DELETE FROM person WHERE (first_name = 'Laura' AND last_name = 'Gonzalez') OR (first_name = 'Carlos' AND last_name = 'Ramirez');
DELETE FROM role_permission WHERE security_role_id IN (SELECT security_role_id FROM security_role WHERE role_code IN ('DB_ADMIN', 'OPS_AGENT', 'CHECKIN_AGENT', 'BILLING_ANALYST', 'AUDITOR'));
DELETE FROM security_permission WHERE permission_code IN ('ddl.manage', 'security.manage', 'flight.manage', 'boarding.manage', 'billing.manage', 'payment.manage', 'baggage.incident.manage', 'audit.read');
DELETE FROM security_role WHERE role_code IN ('DB_ADMIN', 'OPS_AGENT', 'CHECKIN_AGENT', 'BILLING_ANALYST', 'AUDITOR');
DELETE FROM airline WHERE airline_code = 'SENAIR';
DELETE FROM invoice_status WHERE status_code = 'ISSUED';
DELETE FROM tax WHERE tax_code = 'VAT19';
DELETE FROM payment_method WHERE method_code = 'CARD';
DELETE FROM payment_status WHERE status_code = 'APPROVED';
DELETE FROM check_in_status WHERE status_code = 'COMPLETED';
DELETE FROM boarding_group WHERE group_code = 'A';
DELETE FROM ticket_status WHERE status_code = 'ISSUED';
DELETE FROM sale_channel WHERE channel_code = 'WEB';
DELETE FROM reservation_status WHERE status_code = 'CONFIRMED';
DELETE FROM delay_reason_type WHERE reason_code = 'WX';
DELETE FROM flight_status WHERE status_code = 'SCHEDULED';
DELETE FROM maintenance_type WHERE type_code = 'A-CHECK';
DELETE FROM aircraft_manufacturer WHERE manufacturer_name = 'Airbus';
DELETE FROM benefit_type WHERE benefit_code = 'PRIORITY_BOARDING';
DELETE FROM customer_category WHERE category_code = 'REGULAR';
DELETE FROM user_status WHERE status_code = 'ACTIVE';
DELETE FROM contact_type WHERE type_code IN ('EMAIL', 'PHONE');
DELETE FROM document_type WHERE type_code IN ('CC', 'PASSPORT');
DELETE FROM person_type WHERE type_code IN ('PASSENGER', 'EMPLOYEE');
DELETE FROM exchange_rate WHERE effective_date = DATE '2025-04-14';
DELETE FROM currency WHERE iso_currency_code IN ('COP', 'USD');
DELETE FROM address WHERE address_line_1 IN (
    'Aerolinea SENA - Sede Operativa',
    'Aeropuerto Internacional Jose Maria Cordova',
    'Aeropuerto Internacional El Dorado',
    'Hangar de mantenimiento Medellin'
);
DELETE FROM district WHERE district_name IN ('Guayabal', 'Fontibon', 'El Poblado');
DELETE FROM city WHERE city_name IN ('Medellin', 'Bogota');
DELETE FROM state_province WHERE state_name IN ('Antioquia', 'Bogota D.C.');
DELETE FROM country WHERE iso_alpha2 = 'CO';
DELETE FROM continent WHERE continent_code = 'SAM';
DELETE FROM time_zone WHERE time_zone_name = 'America/Bogota';

COMMIT;
