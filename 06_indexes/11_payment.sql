CREATE INDEX idx_payment_sale_id ON payment(sale_id);
CREATE INDEX idx_payment_status_id ON payment(payment_status_id);
CREATE INDEX idx_payment_transaction_payment_id ON payment_transaction(payment_id);
CREATE INDEX idx_refund_payment_id ON refund(payment_id);
