CREATE INDEX idx_exchange_rate_from_to_date ON exchange_rate(from_currency_id, to_currency_id, effective_date);
CREATE INDEX idx_invoice_sale_id ON invoice(sale_id);
CREATE INDEX idx_invoice_status_id ON invoice(invoice_status_id);
CREATE INDEX idx_invoice_line_invoice_id ON invoice_line(invoice_id);
