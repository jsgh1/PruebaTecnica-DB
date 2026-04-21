CREATE INDEX idx_customer_person_id ON customer(person_id);
CREATE INDEX idx_loyalty_program_airline_id ON loyalty_program(airline_id);
CREATE INDEX idx_loyalty_account_customer_id ON loyalty_account(customer_id);
CREATE INDEX idx_loyalty_account_tier_account_id ON loyalty_account_tier(loyalty_account_id);
CREATE INDEX idx_miles_transaction_account_id ON miles_transaction(loyalty_account_id);
