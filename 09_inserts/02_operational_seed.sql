BEGIN;

-- Fidelizacion y cliente de prueba
INSERT INTO loyalty_program (airline_id, default_currency_id, program_code, program_name, expiration_months)
SELECT a.airline_id, c.currency_id, 'SENA-MILES', 'SENA Miles', 24
FROM airline a
JOIN currency c ON c.iso_currency_code = 'COP'
WHERE a.airline_code = 'SENAIR'
ON CONFLICT (airline_id, program_code) DO NOTHING;

INSERT INTO loyalty_tier (loyalty_program_id, tier_code, tier_name, priority_level, required_miles)
SELECT lp.loyalty_program_id, 'CLASSIC', 'Classic', 1, 0
FROM loyalty_program lp
WHERE lp.program_code = 'SENA-MILES'
ON CONFLICT (loyalty_program_id, tier_code) DO NOTHING;

INSERT INTO person (person_type_id, nationality_country_id, first_name, last_name, birth_date, gender_code)
SELECT pt.person_type_id, c.country_id, 'Carlos', 'Ramirez', DATE '1992-08-21', 'M'
FROM person_type pt
JOIN country c ON c.iso_alpha2 = 'CO'
WHERE pt.type_code = 'PASSENGER'
AND NOT EXISTS (
    SELECT 1 FROM person WHERE first_name = 'Carlos' AND last_name = 'Ramirez' AND birth_date = DATE '1992-08-21'
);

INSERT INTO person_document (person_id, document_type_id, issuing_country_id, document_number, issued_on)
SELECT p.person_id, dt.document_type_id, c.country_id, '1122334455', DATE '2020-03-10'
FROM person p
JOIN document_type dt ON dt.type_code = 'CC'
JOIN country c ON c.iso_alpha2 = 'CO'
WHERE p.first_name = 'Carlos' AND p.last_name = 'Ramirez'
AND NOT EXISTS (
    SELECT 1 FROM person_document WHERE document_number = '1122334455'
);

INSERT INTO person_contact (person_id, contact_type_id, contact_value, is_primary)
SELECT p.person_id, ct.contact_type_id, 'carlos.ramirez@correo.test', true
FROM person p
JOIN contact_type ct ON ct.type_code = 'EMAIL'
WHERE p.first_name = 'Carlos' AND p.last_name = 'Ramirez'
AND NOT EXISTS (
    SELECT 1 FROM person_contact WHERE contact_value = 'carlos.ramirez@correo.test'
);

INSERT INTO customer (airline_id, person_id, customer_category_id, customer_since)
SELECT a.airline_id, p.person_id, cc.customer_category_id, DATE '2025-01-10'
FROM airline a
JOIN person p ON p.first_name = 'Carlos' AND p.last_name = 'Ramirez'
LEFT JOIN customer_category cc ON cc.category_code = 'REGULAR'
WHERE a.airline_code = 'SENAIR'
ON CONFLICT (airline_id, person_id) DO NOTHING;

INSERT INTO loyalty_account (customer_id, loyalty_program_id, account_number, opened_at)
SELECT c.customer_id, lp.loyalty_program_id, 'SM-0001', TIMESTAMPTZ '2025-01-10 09:00:00-05'
FROM customer c
JOIN person p ON p.person_id = c.person_id
JOIN loyalty_program lp ON lp.program_code = 'SENA-MILES'
WHERE p.first_name = 'Carlos' AND p.last_name = 'Ramirez'
ON CONFLICT (account_number) DO NOTHING;

INSERT INTO loyalty_account_tier (loyalty_account_id, loyalty_tier_id, assigned_at)
SELECT la.loyalty_account_id, lt.loyalty_tier_id, TIMESTAMPTZ '2025-01-10 09:00:00-05'
FROM loyalty_account la
JOIN loyalty_tier lt ON lt.tier_code = 'CLASSIC'
WHERE la.account_number = 'SM-0001'
ON CONFLICT (loyalty_account_id, assigned_at) DO NOTHING;

INSERT INTO miles_transaction (loyalty_account_id, transaction_type, miles_delta, occurred_at, reference_code, notes)
SELECT la.loyalty_account_id, 'EARN', 350, TIMESTAMPTZ '2025-04-14 07:00:00-05', 'FLIGHT-SN1001', 'Carga inicial por vuelo de prueba.'
FROM loyalty_account la
WHERE la.account_number = 'SM-0001'
AND NOT EXISTS (SELECT 1 FROM miles_transaction WHERE reference_code = 'FLIGHT-SN1001');

INSERT INTO customer_benefit (customer_id, benefit_type_id, granted_at, expires_at, notes)
SELECT c.customer_id, bt.benefit_type_id, TIMESTAMPTZ '2025-01-10 09:00:00-05', TIMESTAMPTZ '2025-12-31 23:59:59-05', 'Beneficio inicial de onboarding.'
FROM customer c
JOIN person p ON p.person_id = c.person_id
JOIN benefit_type bt ON bt.benefit_code = 'PRIORITY_BOARDING'
WHERE p.first_name = 'Carlos' AND p.last_name = 'Ramirez'
ON CONFLICT (customer_id, benefit_type_id, granted_at) DO NOTHING;

-- Aeropuertos y operación
INSERT INTO airport (address_id, airport_name, iata_code, icao_code)
SELECT ad.address_id, 'Jose Maria Cordova', 'MDE', 'SKRG'
FROM address ad
WHERE ad.address_line_1 = 'Aeropuerto Internacional Jose Maria Cordova'
ON CONFLICT (iata_code) DO NOTHING;

INSERT INTO airport (address_id, airport_name, iata_code, icao_code)
SELECT ad.address_id, 'El Dorado', 'BOG', 'SKBO'
FROM address ad
WHERE ad.address_line_1 = 'Aeropuerto Internacional El Dorado'
ON CONFLICT (iata_code) DO NOTHING;

INSERT INTO terminal (airport_id, terminal_code, terminal_name)
SELECT a.airport_id, 'T1', 'Terminal principal'
FROM airport a
WHERE a.iata_code IN ('MDE', 'BOG')
ON CONFLICT (airport_id, terminal_code) DO NOTHING;

INSERT INTO boarding_gate (terminal_id, gate_code)
SELECT t.terminal_id, CASE ap.iata_code WHEN 'MDE' THEN 'A1' ELSE 'B2' END
FROM terminal t
JOIN airport ap ON ap.airport_id = t.airport_id
WHERE t.terminal_code = 'T1'
ON CONFLICT (terminal_id, gate_code) DO NOTHING;

INSERT INTO runway (airport_id, runway_code, length_meters, surface_type)
SELECT a.airport_id, CASE a.iata_code WHEN 'MDE' THEN '01L/19R' ELSE '14L/32R' END,
       CASE a.iata_code WHEN 'MDE' THEN 3550 ELSE 3800 END,
       'ASPHALT'
FROM airport a
WHERE a.iata_code IN ('MDE', 'BOG')
ON CONFLICT (airport_id, runway_code) DO NOTHING;

INSERT INTO airport_regulation (airport_id, regulation_code, regulation_title, issuing_authority, effective_from)
SELECT a.airport_id, 'OPS-001', 'Regla operativa terminal', 'Aerocivil', DATE '2025-01-01'
FROM airport a
WHERE a.iata_code = 'MDE'
ON CONFLICT (airport_id, regulation_code) DO NOTHING;

INSERT INTO airport_regulation (airport_id, regulation_code, regulation_title, issuing_authority, effective_from)
SELECT a.airport_id, 'OPS-002', 'Control operacional pista', 'Aerocivil', DATE '2025-01-01'
FROM airport a
WHERE a.iata_code = 'BOG'
ON CONFLICT (airport_id, regulation_code) DO NOTHING;

INSERT INTO aircraft_model (aircraft_manufacturer_id, model_code, model_name, max_range_km)
SELECT am.aircraft_manufacturer_id, 'A320', 'Airbus A320', 6100
FROM aircraft_manufacturer am
WHERE am.manufacturer_name = 'Airbus'
ON CONFLICT (aircraft_manufacturer_id, model_code) DO NOTHING;

INSERT INTO aircraft (airline_id, aircraft_model_id, registration_number, serial_number, in_service_on)
SELECT a.airline_id, am.aircraft_model_id, 'HK-0001', 'SN-A320-0001', DATE '2023-01-15'
FROM airline a
JOIN aircraft_model am ON am.model_code = 'A320'
WHERE a.airline_code = 'SENAIR'
ON CONFLICT (registration_number) DO NOTHING;

INSERT INTO aircraft_cabin (aircraft_id, cabin_class_id, cabin_code, deck_number)
SELECT ac.aircraft_id, cc.cabin_class_id, 'ECO-1', 1
FROM aircraft ac
JOIN cabin_class cc ON cc.class_code = 'ECO'
WHERE ac.registration_number = 'HK-0001'
ON CONFLICT (aircraft_id, cabin_code) DO NOTHING;

INSERT INTO aircraft_seat (aircraft_cabin_id, seat_row_number, seat_column_code, is_window, is_aisle)
SELECT cabin.aircraft_cabin_id, s.row_no, s.col_code, s.is_window, s.is_aisle
FROM aircraft_cabin cabin
CROSS JOIN (
    VALUES (1, 'A', true, false),
           (1, 'C', false, true),
           (1, 'D', false, true),
           (1, 'F', true, false)
) AS s(row_no, col_code, is_window, is_aisle)
WHERE cabin.cabin_code = 'ECO-1'
ON CONFLICT (aircraft_cabin_id, seat_row_number, seat_column_code) DO NOTHING;

INSERT INTO maintenance_provider (address_id, provider_name, contact_name)
SELECT ad.address_id, 'MRO Medellin', 'Equipo tecnico MRO'
FROM address ad
WHERE ad.address_line_1 = 'Hangar de mantenimiento Medellin'
ON CONFLICT (provider_name) DO NOTHING;

INSERT INTO maintenance_event (aircraft_id, maintenance_type_id, maintenance_provider_id, status_code, started_at, completed_at, notes)
SELECT ac.aircraft_id, mt.maintenance_type_id, mp.maintenance_provider_id,
       'COMPLETED', TIMESTAMPTZ '2025-04-10 08:00:00-05', TIMESTAMPTZ '2025-04-10 14:00:00-05', 'Evento previo a liberacion operacional.'
FROM aircraft ac
JOIN maintenance_type mt ON mt.type_code = 'A-CHECK'
JOIN maintenance_provider mp ON mp.provider_name = 'MRO Medellin'
WHERE ac.registration_number = 'HK-0001'
AND NOT EXISTS (
    SELECT 1 FROM maintenance_event WHERE aircraft_id = ac.aircraft_id AND started_at = TIMESTAMPTZ '2025-04-10 08:00:00-05'
);

INSERT INTO flight (airline_id, aircraft_id, flight_status_id, flight_number, service_date)
SELECT a.airline_id, ac.aircraft_id, fs.flight_status_id, 'SN1001', DATE '2025-04-14'
FROM airline a
JOIN aircraft ac ON ac.registration_number = 'HK-0001'
JOIN flight_status fs ON fs.status_code = 'SCHEDULED'
WHERE a.airline_code = 'SENAIR'
ON CONFLICT (airline_id, flight_number, service_date) DO NOTHING;

INSERT INTO flight_segment (
    flight_id,
    origin_airport_id,
    destination_airport_id,
    segment_number,
    scheduled_departure_at,
    scheduled_arrival_at,
    actual_departure_at,
    actual_arrival_at
)
SELECT f.flight_id, ao.airport_id, ad.airport_id, 1,
       TIMESTAMPTZ '2025-04-14 08:00:00-05', TIMESTAMPTZ '2025-04-14 09:10:00-05',
       TIMESTAMPTZ '2025-04-14 08:12:00-05', TIMESTAMPTZ '2025-04-14 09:18:00-05'
FROM flight f
JOIN airport ao ON ao.iata_code = 'MDE'
JOIN airport ad ON ad.iata_code = 'BOG'
WHERE f.flight_number = 'SN1001' AND f.service_date = DATE '2025-04-14'
ON CONFLICT (flight_id, segment_number) DO NOTHING;

INSERT INTO flight_delay (flight_segment_id, delay_reason_type_id, reported_at, delay_minutes, notes)
SELECT fs.flight_segment_id, drt.delay_reason_type_id, TIMESTAMPTZ '2025-04-14 07:50:00-05', 12, 'Demora controlada por clima.'
FROM flight_segment fs
JOIN flight f ON f.flight_id = fs.flight_id
JOIN delay_reason_type drt ON drt.reason_code = 'WX'
WHERE f.flight_number = 'SN1001' AND fs.segment_number = 1
AND NOT EXISTS (
    SELECT 1 FROM flight_delay WHERE flight_segment_id = fs.flight_segment_id AND reported_at = TIMESTAMPTZ '2025-04-14 07:50:00-05'
);

INSERT INTO fare_class (cabin_class_id, fare_class_code, fare_class_name, is_refundable_by_default)
SELECT cc.cabin_class_id, 'YFLEX', 'Economy Flex', true
FROM cabin_class cc
WHERE cc.class_code = 'ECO'
ON CONFLICT (fare_class_code) DO NOTHING;

INSERT INTO fare (
    airline_id,
    origin_airport_id,
    destination_airport_id,
    fare_class_id,
    currency_id,
    fare_code,
    base_amount,
    valid_from,
    valid_to,
    baggage_allowance_qty,
    change_penalty_amount,
    refund_penalty_amount
)
SELECT a.airline_id, ao.airport_id, ad.airport_id, fc.fare_class_id, cur.currency_id,
       'MDEBOG-YFLEX', 280000.00, DATE '2025-01-01', DATE '2025-12-31', 1, 25000.00, 35000.00
FROM airline a
JOIN airport ao ON ao.iata_code = 'MDE'
JOIN airport ad ON ad.iata_code = 'BOG'
JOIN fare_class fc ON fc.fare_class_code = 'YFLEX'
JOIN currency cur ON cur.iso_currency_code = 'COP'
WHERE a.airline_code = 'SENAIR'
ON CONFLICT (fare_code) DO NOTHING;

COMMIT;
