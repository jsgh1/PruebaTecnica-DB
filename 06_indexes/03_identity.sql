CREATE INDEX idx_person_person_type_id ON person(person_type_id);
CREATE INDEX idx_person_nationality_country_id ON person(nationality_country_id);
CREATE INDEX idx_person_document_person_id ON person_document(person_id);
CREATE INDEX idx_person_document_number ON person_document(document_number);
CREATE INDEX idx_person_contact_person_id ON person_contact(person_id);
CREATE INDEX idx_person_contact_value ON person_contact(contact_value);
