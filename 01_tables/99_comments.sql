COMMENT ON TABLE reservation IS 'Entidad raiz del flujo comercial y de booking del sistema.';
COMMENT ON TABLE ticket_segment IS 'Tabla puente entre ticket y segmentos de vuelo para soportar itinerarios con escalas.';
COMMENT ON TABLE seat_assignment IS 'Asignacion de asiento normalizada por ticket_segment con control de unicidad por segmento y asiento.';
COMMENT ON TABLE loyalty_account_tier IS 'Historial de asignacion de nivel para evitar dependencia transitiva en loyalty_account.';
COMMENT ON TABLE invoice_line IS 'Detalle facturable sin totales derivados persistidos, para preservar 3FN.';
