CREATE INDEX idx_aircraft_airline_id ON aircraft(airline_id);
CREATE INDEX idx_aircraft_model_id ON aircraft(aircraft_model_id);
CREATE INDEX idx_aircraft_cabin_aircraft_id ON aircraft_cabin(aircraft_id);
CREATE INDEX idx_aircraft_seat_cabin_id ON aircraft_seat(aircraft_cabin_id);
CREATE INDEX idx_maintenance_event_aircraft_id ON maintenance_event(aircraft_id);
