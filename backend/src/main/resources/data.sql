INSERT INTO users (email, password, first_name, last_name, phone, role)
VALUES (
    'admin@autoparts.tn',
    '$2a$10$3KZ7MuC7l8gTHJk0gHPLBe7GTVJOq22kJMlfXmAOPm2dLMOoSXGRe',
    'Admin',
    'AutoParts',
    '+216 00 000 000',
    'ADMIN'
) ON CONFLICT (email) DO NOTHING;
