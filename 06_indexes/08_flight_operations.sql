CREATE INDEX idx_flight_aircraft_id ON flight(aircraft_id);
CREATE INDEX idx_flight_service_date ON flight(service_date);
CREATE INDEX idx_flight_segment_flight_id ON flight_segment(flight_id);
CREATE INDEX idx_flight_segment_origin_airport_id ON flight_segment(origin_airport_id);
CREATE INDEX idx_flight_segment_destination_airport_id ON flight_segment(destination_airport_id);
CREATE INDEX idx_flight_delay_segment_id ON flight_delay(flight_segment_id);
