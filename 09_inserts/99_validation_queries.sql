-- Validaciones recomendadas posteriores a la carga de datos de prueba

-- 1. Resumen de cobertura por dominio clave
SELECT 'airline' AS table_name, COUNT(*) AS total_rows FROM airline
UNION ALL
SELECT 'customer', COUNT(*) FROM customer
UNION ALL
SELECT 'flight', COUNT(*) FROM flight
UNION ALL
SELECT 'reservation', COUNT(*) FROM reservation
UNION ALL
SELECT 'payment', COUNT(*) FROM payment
UNION ALL
SELECT 'invoice', COUNT(*) FROM invoice
UNION ALL
SELECT 'baggage_incident', COUNT(*) FROM baggage_incident;

-- 2. Flujo comercial completo desde reserva hasta factura
SELECT
    r.reservation_code,
    s.sale_code,
    t.ticket_number,
    p.payment_reference,
    i.invoice_number
FROM reservation r
JOIN sale s ON s.reservation_id = r.reservation_id
JOIN ticket t ON t.sale_id = s.sale_id
JOIN payment p ON p.sale_id = s.sale_id
JOIN invoice i ON i.sale_id = s.sale_id
WHERE r.reservation_code = 'RSV-20250414-0001';

-- 3. Asiento asignado y puerta de abordaje
SELECT
    t.ticket_number,
    fs.segment_number,
    seat.seat_row_number,
    seat.seat_column_code,
    bg.gate_code,
    bv.validation_result
FROM ticket t
JOIN ticket_segment ts ON ts.ticket_id = t.ticket_id
JOIN flight_segment fs ON fs.flight_segment_id = ts.flight_segment_id
JOIN seat_assignment sa ON sa.ticket_segment_id = ts.ticket_segment_id
JOIN aircraft_seat seat ON seat.aircraft_seat_id = sa.aircraft_seat_id
LEFT JOIN check_in ci ON ci.ticket_segment_id = ts.ticket_segment_id
LEFT JOIN boarding_pass bp ON bp.check_in_id = ci.check_in_id
LEFT JOIN boarding_validation bv ON bv.boarding_pass_id = bp.boarding_pass_id
LEFT JOIN boarding_gate bg ON bg.boarding_gate_id = bv.boarding_gate_id
WHERE t.ticket_number = '220000000001';

-- 4. Estado del incidente de equipaje y su bitacora
SELECT
    bi.report_code,
    bit.type_name,
    bis.status_name,
    bie.event_code,
    bie.event_description,
    bie.occurred_at
FROM baggage_incident bi
JOIN baggage_incident_type bit ON bit.baggage_incident_type_id = bi.baggage_incident_type_id
JOIN baggage_incident_status bis ON bis.baggage_incident_status_id = bi.baggage_incident_status_id
JOIN baggage_incident_event bie ON bie.baggage_incident_id = bi.baggage_incident_id
WHERE bi.report_code = 'INC-BAG-0001'
ORDER BY bie.occurred_at;
