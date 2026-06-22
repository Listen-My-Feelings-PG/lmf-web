-- Script para generar el usuario administrador base
-- Contraseña original encriptada con bcrypt (cost: 10): "root"

INSERT INTO public.usuarios (us_username, us_password, us_activo) 
VALUES ('admin', '$2b$10$Mmyh9k6cWb5EIOpzIby2IeMyy1xQNUDHwZbP4z8JJUAosjnomVosO', B'1');
