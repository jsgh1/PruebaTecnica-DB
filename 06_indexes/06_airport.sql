CREATE INDEX idx_airport_address_id ON airport(address_id);
CREATE INDEX idx_terminal_airport_id ON terminal(airport_id);
CREATE INDEX idx_boarding_gate_terminal_id ON boarding_gate(terminal_id);
CREATE INDEX idx_runway_airport_id ON runway(airport_id);
