CREATE INDEX idx_country_continent_id ON country(continent_id);
CREATE INDEX idx_state_country_id ON state_province(country_id);
CREATE INDEX idx_city_state_id ON city(state_province_id);
CREATE INDEX idx_district_city_id ON district(city_id);
CREATE INDEX idx_address_district_id ON address(district_id);
