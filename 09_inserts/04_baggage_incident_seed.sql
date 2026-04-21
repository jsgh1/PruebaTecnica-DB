BEGIN;

INSERT INTO baggage_incident_status (status_code, status_name)
VALUES ('OPEN', 'Abierto'), ('IN_REVIEW', 'En revision'), ('RESOLVED', 'Resuelto')
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO baggage_incident_type (type_code, type_name)
VALUES ('LOST', 'Equipaje perdido'), ('DELAYED', 'Equipaje demorado'), ('DAMAGED', 'Equipaje averiado')
ON CONFLICT (type_code) DO NOTHING;

INSERT INTO baggage_incident (
    baggage_id,
    airport_id,
    reported_by_customer_id,
    baggage_incident_status_id,
    baggage_incident_type_id,
    report_code,
    reported_at,
    description,
    estimated_resolution_at
)
SELECT b.baggage_id, a.airport_id, c.customer_id, bis.baggage_incident_status_id, bit.baggage_incident_type_id,
       'INC-BAG-0001', TIMESTAMPTZ '2025-04-14 10:05:00-05',
       'El equipaje no fue encontrado en la banda de destino.', TIMESTAMPTZ '2025-04-15 18:00:00-05'
FROM baggage b
JOIN ticket_segment ts ON ts.ticket_segment_id = b.ticket_segment_id
JOIN ticket t ON t.ticket_id = ts.ticket_id
JOIN reservation_passenger rp ON rp.reservation_passenger_id = t.reservation_passenger_id
JOIN reservation r ON r.reservation_id = rp.reservation_id
JOIN customer c ON c.customer_id = r.booked_by_customer_id
JOIN airport a ON a.iata_code = 'BOG'
JOIN baggage_incident_status bis ON bis.status_code = 'OPEN'
JOIN baggage_incident_type bit ON bit.type_code = 'LOST'
WHERE b.baggage_tag = 'BG-0001'
ON CONFLICT (report_code) DO NOTHING;

INSERT INTO baggage_incident_event (baggage_incident_id, recorded_by_user_id, event_code, event_description, occurred_at)
SELECT bi.baggage_incident_id, ua.user_account_id, 'OPENED', 'Incidente creado en destino y pendiente de trazabilidad.', TIMESTAMPTZ '2025-04-14 10:05:00-05'
FROM baggage_incident bi
JOIN user_account ua ON ua.username = 'laura.gonzalez'
WHERE bi.report_code = 'INC-BAG-0001'
ON CONFLICT (baggage_incident_id, event_code, occurred_at) DO NOTHING;

INSERT INTO baggage_incident_event (baggage_incident_id, recorded_by_user_id, event_code, event_description, occurred_at)
SELECT bi.baggage_incident_id, ua.user_account_id, 'TRACE_SENT', 'Se solicita busqueda en bodega y conexion del ultimo tramo.', TIMESTAMPTZ '2025-04-14 10:25:00-05'
FROM baggage_incident bi
JOIN user_account ua ON ua.username = 'laura.gonzalez'
WHERE bi.report_code = 'INC-BAG-0001'
ON CONFLICT (baggage_incident_id, event_code, occurred_at) DO NOTHING;

COMMIT;
