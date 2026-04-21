BEGIN;

-- 1. Geografía y datos de referencia
INSERT INTO time_zone (time_zone_name, utc_offset_minutes)
VALUES ('America/Bogota', -300)
ON CONFLICT (time_zone_name) DO NOTHING;

INSERT INTO continent (continent_code, continent_name)
VALUES ('SAM', 'South America')
ON CONFLICT (continent_code) DO NOTHING;

INSERT INTO country (continent_id, iso_alpha2, iso_alpha3, country_name)
SELECT c.continent_id, 'CO', 'COL', 'Colombia'
FROM continent c
WHERE c.continent_code = 'SAM'
ON CONFLICT (iso_alpha2) DO NOTHING;

INSERT INTO state_province (country_id, state_code, state_name)
SELECT country_id, 'ANT', 'Antioquia'
FROM country WHERE iso_alpha2 = 'CO'
ON CONFLICT (country_id, state_name) DO NOTHING;

INSERT INTO state_province (country_id, state_code, state_name)
SELECT country_id, 'DC', 'Bogota D.C.'
FROM country WHERE iso_alpha2 = 'CO'
ON CONFLICT (country_id, state_name) DO NOTHING;

INSERT INTO city (state_province_id, time_zone_id, city_name)
SELECT sp.state_province_id, tz.time_zone_id, 'Medellin'
FROM state_province sp
JOIN time_zone tz ON tz.time_zone_name = 'America/Bogota'
WHERE sp.state_name = 'Antioquia'
ON CONFLICT (state_province_id, city_name) DO NOTHING;

INSERT INTO city (state_province_id, time_zone_id, city_name)
SELECT sp.state_province_id, tz.time_zone_id, 'Bogota'
FROM state_province sp
JOIN time_zone tz ON tz.time_zone_name = 'America/Bogota'
WHERE sp.state_name = 'Bogota D.C.'
ON CONFLICT (state_province_id, city_name) DO NOTHING;

INSERT INTO district (city_id, district_name)
SELECT city_id, 'Guayabal'
FROM city WHERE city_name = 'Medellin'
ON CONFLICT (city_id, district_name) DO NOTHING;

INSERT INTO district (city_id, district_name)
SELECT city_id, 'Fontibon'
FROM city WHERE city_name = 'Bogota'
ON CONFLICT (city_id, district_name) DO NOTHING;

INSERT INTO district (city_id, district_name)
SELECT city_id, 'El Poblado'
FROM city WHERE city_name = 'Medellin'
ON CONFLICT (city_id, district_name) DO NOTHING;

INSERT INTO address (district_id, address_line_1, postal_code, latitude, longitude)
SELECT district_id, 'Aerolinea SENA - Sede Operativa', '050021', 6.2057000, -75.5741000
FROM district WHERE district_name = 'El Poblado'
AND NOT EXISTS (SELECT 1 FROM address WHERE address_line_1 = 'Aerolinea SENA - Sede Operativa');

INSERT INTO address (district_id, address_line_1, postal_code, latitude, longitude)
SELECT district_id, 'Aeropuerto Internacional Jose Maria Cordova', '054047', 6.1645000, -75.4231000
FROM district WHERE district_name = 'Guayabal'
AND NOT EXISTS (SELECT 1 FROM address WHERE address_line_1 = 'Aeropuerto Internacional Jose Maria Cordova');

INSERT INTO address (district_id, address_line_1, postal_code, latitude, longitude)
SELECT district_id, 'Aeropuerto Internacional El Dorado', '110911', 4.7016000, -74.1469000
FROM district WHERE district_name = 'Fontibon'
AND NOT EXISTS (SELECT 1 FROM address WHERE address_line_1 = 'Aeropuerto Internacional El Dorado');

INSERT INTO address (district_id, address_line_1, postal_code)
SELECT district_id, 'Hangar de mantenimiento Medellin', '050022'
FROM district WHERE district_name = 'Guayabal'
AND NOT EXISTS (SELECT 1 FROM address WHERE address_line_1 = 'Hangar de mantenimiento Medellin');

INSERT INTO currency (iso_currency_code, currency_name, currency_symbol, minor_units)
VALUES ('COP', 'Peso colombiano', '$', 2)
ON CONFLICT (iso_currency_code) DO NOTHING;

INSERT INTO currency (iso_currency_code, currency_name, currency_symbol, minor_units)
VALUES ('USD', 'US Dollar', '$', 2)
ON CONFLICT (iso_currency_code) DO NOTHING;

-- 2. Catálogos transversales
INSERT INTO person_type (type_code, type_name)
VALUES ('PASSENGER', 'Pasajero'), ('EMPLOYEE', 'Empleado')
ON CONFLICT (type_code) DO NOTHING;

INSERT INTO document_type (type_code, type_name)
VALUES ('CC', 'Cedula de ciudadania'), ('PASSPORT', 'Pasaporte')
ON CONFLICT (type_code) DO NOTHING;

INSERT INTO contact_type (type_code, type_name)
VALUES ('EMAIL', 'Correo electronico'), ('PHONE', 'Telefono')
ON CONFLICT (type_code) DO NOTHING;

INSERT INTO user_status (status_code, status_name)
VALUES ('ACTIVE', 'Activo')
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO customer_category (category_code, category_name)
VALUES ('REGULAR', 'Cliente regular')
ON CONFLICT (category_code) DO NOTHING;

INSERT INTO benefit_type (benefit_code, benefit_name, benefit_description)
VALUES ('PRIORITY_BOARDING', 'Abordaje prioritario', 'Beneficio entregado por fidelizacion.')
ON CONFLICT (benefit_code) DO NOTHING;

INSERT INTO aircraft_manufacturer (manufacturer_name)
VALUES ('Airbus')
ON CONFLICT (manufacturer_name) DO NOTHING;

INSERT INTO cabin_class (class_code, class_name)
VALUES ('ECO', 'Economy')
ON CONFLICT (class_code) DO NOTHING;

INSERT INTO maintenance_type (type_code, type_name)
VALUES ('A-CHECK', 'Inspeccion A-Check')
ON CONFLICT (type_code) DO NOTHING;

INSERT INTO flight_status (status_code, status_name)
VALUES ('SCHEDULED', 'Programado')
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO delay_reason_type (reason_code, reason_name)
VALUES ('WX', 'Condiciones meteorologicas')
ON CONFLICT (reason_code) DO NOTHING;

INSERT INTO reservation_status (status_code, status_name)
VALUES ('CONFIRMED', 'Confirmada')
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO sale_channel (channel_code, channel_name)
VALUES ('WEB', 'Portal web')
ON CONFLICT (channel_code) DO NOTHING;

INSERT INTO ticket_status (status_code, status_name)
VALUES ('ISSUED', 'Emitido')
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO boarding_group (group_code, group_name, sequence_no)
VALUES ('A', 'Grupo A', 1)
ON CONFLICT (group_code) DO NOTHING;

INSERT INTO check_in_status (status_code, status_name)
VALUES ('COMPLETED', 'Completado')
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO payment_status (status_code, status_name)
VALUES ('APPROVED', 'Aprobado')
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO payment_method (method_code, method_name)
VALUES ('CARD', 'Tarjeta')
ON CONFLICT (method_code) DO NOTHING;

INSERT INTO tax (tax_code, tax_name, rate_percentage, effective_from)
VALUES ('VAT19', 'IVA 19%', 19.000, DATE '2025-01-01')
ON CONFLICT (tax_code) DO NOTHING;

INSERT INTO invoice_status (status_code, status_name)
VALUES ('ISSUED', 'Emitida')
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO airline (home_country_id, airline_code, airline_name, iata_code, icao_code)
SELECT country_id, 'SENAIR', 'Aerolinea SENA', 'SN', 'SNA'
FROM country WHERE iso_alpha2 = 'CO'
ON CONFLICT (airline_code) DO NOTHING;

COMMIT;
