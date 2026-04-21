BEGIN;

-- Roles y permisos RBAC base
INSERT INTO security_role (role_code, role_name, role_description)
VALUES
    ('DB_ADMIN', 'Administrador de base de datos', 'Control de cambios, despliegues y recuperacion.'),
    ('OPS_AGENT', 'Agente de operaciones', 'Gestion de vuelos, aeronaves y mantenimiento.'),
    ('CHECKIN_AGENT', 'Agente de check-in', 'Gestion de check-in y validacion de abordaje.'),
    ('BILLING_ANALYST', 'Analista de facturacion', 'Seguimiento a pagos, facturas y conciliaciones.'),
    ('AUDITOR', 'Auditor', 'Consulta y trazabilidad sin permisos operativos.')
ON CONFLICT (role_code) DO NOTHING;

INSERT INTO security_permission (permission_code, permission_name, permission_description)
VALUES
    ('ddl.manage', 'Gestionar DDL', 'Crear y versionar objetos del esquema.'),
    ('security.manage', 'Gestionar seguridad', 'Administrar roles, permisos y usuarios.'),
    ('flight.manage', 'Gestionar vuelos', 'Administrar vuelos, segmentos y demoras.'),
    ('boarding.manage', 'Gestionar abordaje', 'Ejecutar check-in y validaciones de embarque.'),
    ('billing.manage', 'Gestionar facturacion', 'Emitir facturas y revisar lineas.'),
    ('payment.manage', 'Gestionar pagos', 'Registrar pagos, transacciones y reembolsos.'),
    ('baggage.incident.manage', 'Gestionar incidentes de equipaje', 'Registrar y dar seguimiento a incidentes.'),
    ('audit.read', 'Consultar trazabilidad', 'Lectura de informacion con fines de auditoria.')
ON CONFLICT (permission_code) DO NOTHING;

INSERT INTO role_permission (security_role_id, security_permission_id)
SELECT r.security_role_id, p.security_permission_id
FROM security_role r
JOIN security_permission p ON p.permission_code IN ('ddl.manage', 'security.manage', 'audit.read')
WHERE r.role_code = 'DB_ADMIN'
ON CONFLICT (security_role_id, security_permission_id) DO NOTHING;

INSERT INTO role_permission (security_role_id, security_permission_id)
SELECT r.security_role_id, p.security_permission_id
FROM security_role r
JOIN security_permission p ON p.permission_code IN ('flight.manage', 'baggage.incident.manage', 'audit.read')
WHERE r.role_code = 'OPS_AGENT'
ON CONFLICT (security_role_id, security_permission_id) DO NOTHING;

INSERT INTO role_permission (security_role_id, security_permission_id)
SELECT r.security_role_id, p.security_permission_id
FROM security_role r
JOIN security_permission p ON p.permission_code IN ('boarding.manage', 'baggage.incident.manage', 'audit.read')
WHERE r.role_code = 'CHECKIN_AGENT'
ON CONFLICT (security_role_id, security_permission_id) DO NOTHING;

INSERT INTO role_permission (security_role_id, security_permission_id)
SELECT r.security_role_id, p.security_permission_id
FROM security_role r
JOIN security_permission p ON p.permission_code IN ('billing.manage', 'payment.manage', 'audit.read')
WHERE r.role_code = 'BILLING_ANALYST'
ON CONFLICT (security_role_id, security_permission_id) DO NOTHING;

INSERT INTO role_permission (security_role_id, security_permission_id)
SELECT r.security_role_id, p.security_permission_id
FROM security_role r
JOIN security_permission p ON p.permission_code = 'audit.read'
WHERE r.role_code = 'AUDITOR'
ON CONFLICT (security_role_id, security_permission_id) DO NOTHING;

-- Empleado base para operar pruebas de check-in y trazabilidad
INSERT INTO person (person_type_id, nationality_country_id, first_name, last_name, birth_date, gender_code)
SELECT pt.person_type_id, c.country_id, 'Laura', 'Gonzalez', DATE '1995-02-11', 'F'
FROM person_type pt
JOIN country c ON c.iso_alpha2 = 'CO'
WHERE pt.type_code = 'EMPLOYEE'
AND NOT EXISTS (
    SELECT 1 FROM person WHERE first_name = 'Laura' AND last_name = 'Gonzalez' AND birth_date = DATE '1995-02-11'
);

INSERT INTO person_document (person_id, document_type_id, issuing_country_id, document_number, issued_on)
SELECT p.person_id, dt.document_type_id, c.country_id, '1020304050', DATE '2018-01-15'
FROM person p
JOIN document_type dt ON dt.type_code = 'CC'
JOIN country c ON c.iso_alpha2 = 'CO'
WHERE p.first_name = 'Laura' AND p.last_name = 'Gonzalez'
AND NOT EXISTS (
    SELECT 1 FROM person_document WHERE document_number = '1020304050'
);

INSERT INTO person_contact (person_id, contact_type_id, contact_value, is_primary)
SELECT p.person_id, ct.contact_type_id, 'laura.gonzalez@senair.test', true
FROM person p
JOIN contact_type ct ON ct.type_code = 'EMAIL'
WHERE p.first_name = 'Laura' AND p.last_name = 'Gonzalez'
AND NOT EXISTS (
    SELECT 1 FROM person_contact WHERE contact_value = 'laura.gonzalez@senair.test'
);

INSERT INTO user_account (person_id, user_status_id, username, password_hash)
SELECT p.person_id, us.user_status_id, 'laura.gonzalez', 'HASH_PLACEHOLDER_SUPERVISED_PHASE'
FROM person p
JOIN user_status us ON us.status_code = 'ACTIVE'
WHERE p.first_name = 'Laura' AND p.last_name = 'Gonzalez'
ON CONFLICT (username) DO NOTHING;

INSERT INTO user_role (user_account_id, security_role_id, assigned_by_user_id)
SELECT ua.user_account_id, sr.security_role_id, ua.user_account_id
FROM user_account ua
JOIN security_role sr ON sr.role_code IN ('CHECKIN_AGENT', 'OPS_AGENT')
WHERE ua.username = 'laura.gonzalez'
ON CONFLICT (user_account_id, security_role_id) DO NOTHING;

COMMIT;
