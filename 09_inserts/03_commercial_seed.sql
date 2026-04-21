BEGIN;

-- Flujo comercial completo: reserva -> venta -> ticket -> check-in -> pago -> factura
INSERT INTO reservation (booked_by_customer_id, reservation_status_id, sale_channel_id, reservation_code, booked_at, expires_at, notes)
SELECT c.customer_id, rs.reservation_status_id, sc.sale_channel_id, 'RSV-20250414-0001',
       TIMESTAMPTZ '2025-04-14 06:00:00-05', TIMESTAMPTZ '2025-04-14 08:00:00-05', 'Reserva supervisada de prueba tecnica.'
FROM customer c
JOIN person p ON p.person_id = c.person_id
JOIN reservation_status rs ON rs.status_code = 'CONFIRMED'
JOIN sale_channel sc ON sc.channel_code = 'WEB'
WHERE p.first_name = 'Carlos' AND p.last_name = 'Ramirez'
ON CONFLICT (reservation_code) DO NOTHING;

INSERT INTO reservation_passenger (reservation_id, person_id, passenger_sequence_no, passenger_type)
SELECT r.reservation_id, p.person_id, 1, 'ADULT'
FROM reservation r
JOIN person p ON p.first_name = 'Carlos' AND p.last_name = 'Ramirez'
WHERE r.reservation_code = 'RSV-20250414-0001'
ON CONFLICT (reservation_id, person_id) DO NOTHING;

INSERT INTO sale (reservation_id, currency_id, sale_code, sold_at, external_reference)
SELECT r.reservation_id, cur.currency_id, 'SALE-20250414-0001', TIMESTAMPTZ '2025-04-14 06:05:00-05', 'GW-APR-0001'
FROM reservation r
JOIN currency cur ON cur.iso_currency_code = 'COP'
WHERE r.reservation_code = 'RSV-20250414-0001'
ON CONFLICT (sale_code) DO NOTHING;

INSERT INTO ticket (sale_id, reservation_passenger_id, fare_id, ticket_status_id, ticket_number, issued_at)
SELECT s.sale_id, rp.reservation_passenger_id, f.fare_id, ts.ticket_status_id, '220000000001', TIMESTAMPTZ '2025-04-14 06:06:00-05'
FROM sale s
JOIN reservation r ON r.reservation_id = s.reservation_id
JOIN reservation_passenger rp ON rp.reservation_id = r.reservation_id
JOIN fare f ON f.fare_code = 'MDEBOG-YFLEX'
JOIN ticket_status ts ON ts.status_code = 'ISSUED'
WHERE s.sale_code = 'SALE-20250414-0001'
ON CONFLICT (ticket_number) DO NOTHING;

INSERT INTO ticket_segment (ticket_id, flight_segment_id, segment_sequence_no, fare_basis_code)
SELECT t.ticket_id, fs.flight_segment_id, 1, 'YFLEX'
FROM ticket t
JOIN flight_segment fs ON TRUE
JOIN flight f ON f.flight_id = fs.flight_id
WHERE t.ticket_number = '220000000001' AND f.flight_number = 'SN1001' AND fs.segment_number = 1
ON CONFLICT (ticket_id, segment_sequence_no) DO NOTHING;

INSERT INTO seat_assignment (ticket_segment_id, flight_segment_id, aircraft_seat_id, assigned_at, assignment_source)
SELECT ts.ticket_segment_id, ts.flight_segment_id, s.aircraft_seat_id, TIMESTAMPTZ '2025-04-14 06:07:00-05', 'AUTO'
FROM ticket_segment ts
JOIN ticket t ON t.ticket_id = ts.ticket_id
JOIN aircraft_seat s ON s.seat_row_number = 1 AND s.seat_column_code = 'A'
JOIN aircraft_cabin cab ON cab.aircraft_cabin_id = s.aircraft_cabin_id AND cab.cabin_code = 'ECO-1'
WHERE t.ticket_number = '220000000001'
ON CONFLICT (ticket_segment_id) DO NOTHING;

INSERT INTO baggage (ticket_segment_id, baggage_tag, baggage_type, baggage_status, weight_kg, checked_at)
SELECT ts.ticket_segment_id, 'BG-0001', 'CHECKED', 'LOST', 18.50, TIMESTAMPTZ '2025-04-14 07:05:00-05'
FROM ticket_segment ts
JOIN ticket t ON t.ticket_id = ts.ticket_id
WHERE t.ticket_number = '220000000001'
ON CONFLICT (baggage_tag) DO NOTHING;

INSERT INTO check_in (ticket_segment_id, check_in_status_id, boarding_group_id, checked_in_by_user_id, checked_in_at)
SELECT ts.ticket_segment_id, cis.check_in_status_id, bg.boarding_group_id, ua.user_account_id, TIMESTAMPTZ '2025-04-14 07:00:00-05'
FROM ticket_segment ts
JOIN ticket t ON t.ticket_id = ts.ticket_id
JOIN check_in_status cis ON cis.status_code = 'COMPLETED'
JOIN boarding_group bg ON bg.group_code = 'A'
JOIN user_account ua ON ua.username = 'laura.gonzalez'
WHERE t.ticket_number = '220000000001'
ON CONFLICT (ticket_segment_id) DO NOTHING;

INSERT INTO boarding_pass (check_in_id, boarding_pass_code, barcode_value, issued_at)
SELECT ci.check_in_id, 'BP-20250414-0001', 'BARCODE-BP-20250414-0001', TIMESTAMPTZ '2025-04-14 07:01:00-05'
FROM check_in ci
JOIN ticket_segment ts ON ts.ticket_segment_id = ci.ticket_segment_id
JOIN ticket t ON t.ticket_id = ts.ticket_id
WHERE t.ticket_number = '220000000001'
ON CONFLICT (check_in_id) DO NOTHING;

INSERT INTO boarding_validation (boarding_pass_id, boarding_gate_id, validated_by_user_id, validated_at, validation_result, notes)
SELECT bp.boarding_pass_id, bg.boarding_gate_id, ua.user_account_id, TIMESTAMPTZ '2025-04-14 07:40:00-05', 'APPROVED', 'Validacion operativa correcta.'
FROM boarding_pass bp
JOIN check_in ci ON ci.check_in_id = bp.check_in_id
JOIN ticket_segment ts ON ts.ticket_segment_id = ci.ticket_segment_id
JOIN ticket t ON t.ticket_id = ts.ticket_id
JOIN boarding_gate bg ON bg.gate_code = 'A1'
JOIN user_account ua ON ua.username = 'laura.gonzalez'
WHERE t.ticket_number = '220000000001'
AND NOT EXISTS (
    SELECT 1 FROM boarding_validation WHERE boarding_pass_id = bp.boarding_pass_id
);

INSERT INTO payment (sale_id, payment_status_id, payment_method_id, currency_id, payment_reference, amount, authorized_at)
SELECT s.sale_id, ps.payment_status_id, pm.payment_method_id, cur.currency_id,
       'PAY-20250414-0001', 280000.00, TIMESTAMPTZ '2025-04-14 06:06:30-05'
FROM sale s
JOIN payment_status ps ON ps.status_code = 'APPROVED'
JOIN payment_method pm ON pm.method_code = 'CARD'
JOIN currency cur ON cur.iso_currency_code = 'COP'
WHERE s.sale_code = 'SALE-20250414-0001'
ON CONFLICT (payment_reference) DO NOTHING;

INSERT INTO payment_transaction (payment_id, transaction_reference, transaction_type, transaction_amount, processed_at, provider_message)
SELECT p.payment_id, 'TX-20250414-0001', 'CAPTURE', 280000.00, TIMESTAMPTZ '2025-04-14 06:06:35-05', 'Operacion aprobada por gateway de pruebas.'
FROM payment p
WHERE p.payment_reference = 'PAY-20250414-0001'
ON CONFLICT (transaction_reference) DO NOTHING;

INSERT INTO exchange_rate (from_currency_id, to_currency_id, effective_date, rate_value)
SELECT cf.currency_id, ct.currency_id, DATE '2025-04-14', 0.00025000
FROM currency cf
JOIN currency ct ON ct.iso_currency_code = 'USD'
WHERE cf.iso_currency_code = 'COP'
ON CONFLICT (from_currency_id, to_currency_id, effective_date) DO NOTHING;

INSERT INTO invoice (sale_id, invoice_status_id, currency_id, invoice_number, issued_at, due_at, notes)
SELECT s.sale_id, is2.invoice_status_id, cur.currency_id, 'FAC-20250414-0001',
       TIMESTAMPTZ '2025-04-14 06:07:00-05', TIMESTAMPTZ '2025-04-14 06:07:00-05', 'Factura emitida en fase supervisada.'
FROM sale s
JOIN invoice_status is2 ON is2.status_code = 'ISSUED'
JOIN currency cur ON cur.iso_currency_code = 'COP'
WHERE s.sale_code = 'SALE-20250414-0001'
ON CONFLICT (invoice_number) DO NOTHING;

INSERT INTO invoice_line (invoice_id, tax_id, line_number, line_description, quantity, unit_price)
SELECT i.invoice_id, NULL, 1, 'Tarifa base MDE-BOG', 1.00, 280000.00
FROM invoice i
WHERE i.invoice_number = 'FAC-20250414-0001'
ON CONFLICT (invoice_id, line_number) DO NOTHING;

INSERT INTO invoice_line (invoice_id, tax_id, line_number, line_description, quantity, unit_price)
SELECT i.invoice_id, t.tax_id, 2, 'IVA 19%', 1.00, 53200.00
FROM invoice i
JOIN tax t ON t.tax_code = 'VAT19'
WHERE i.invoice_number = 'FAC-20250414-0001'
ON CONFLICT (invoice_id, line_number) DO NOTHING;

COMMIT;
