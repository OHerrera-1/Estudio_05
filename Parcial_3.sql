-- Nombre: Orlando Emmanuel Herrera Estrada
-- Carnet: 00084420

--Creacion de base de datos
CREATE DATABASE VeterinaryClinicDB;
GO

USE VeterinaryClinicDB;
GO

--Creacion de tablas

CREATE TABLE Owner (
    owner_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20),
    email NVARCHAR(100)
);

CREATE TABLE Pet (
    pet_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    species NVARCHAR(50),
    birth_date DATE NOT NULL,
    owner_id INT NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES Owner(owner_id)
);

CREATE TABLE Appointment (
    appointment_id INT PRIMARY KEY IDENTITY(1,1),
    pet_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    diagnosis NVARCHAR(255),
    FOREIGN KEY (pet_id) REFERENCES Pet(pet_id)
);

-- Funcion escalar 

GO
CREATE FUNCTION calculate_pet_age_months(@birth_date DATE)
RETURNS INT
AS
BEGIN
    DECLARE @months INT;
    SET @months = DATEDIFF(MONTH, @birth_date, GETDATE());
    RETURN @months;
END;
GO

--Creacion de Trigger
CREATE TRIGGER check_pet_age
ON Pet
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE dbo.calculate_pet_age_months(birth_date) < 2
    )
    BEGIN
        RAISERROR('La mascota debe tener al menos 2 meses de nacida.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO Pet (name, species, birth_date, owner_id)
    SELECT name, species, birth_date, owner_id FROM inserted;
END;
GO

-- Registro de mascotas
CREATE PROCEDURE register_pet
    @name NVARCHAR(100),
    @species NVARCHAR(50),
    @birth_date DATE,
    @owner_id INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Pet (name, species, birth_date, owner_id)
        VALUES (@name, @species, @birth_date, @owner_id);
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Insertar dueños
--5a

INSERT INTO Owner (name, phone, email)
VALUES ('Ana Pérez', '7777-1234', 'ana@example.com'),
       ('Carlos López', '7777-5678', 'carlos@example.com');

-- Insertar mascotas 
EXEC register_pet 'Firulais', 'Perro', '2023-12-01', 1;
EXEC register_pet 'Misu', 'Gato', '2024-01-15', 2;
EXEC register_pet 'Mini', 'Conejo', '2025-06-15', 1; -- esta mascota no se agregara ya que no tiene mas de 2 meses de nacida

-- Insertar consultas
INSERT INTO Appointment (pet_id, appointment_date, diagnosis)
VALUES (1, '2025-06-01', 'Vacunación anual'),
       (2, '2025-06-15', 'Revisión general');

-- Parte 5
-- 5b
go
CREATE VIEW RecentAppointmentsView AS
SELECT 
    p.name AS pet_name,
    o.name AS owner_name,
    a.appointment_date,
    a.diagnosis
FROM Appointment a
JOIN Pet p ON a.pet_id = p.pet_id
JOIN Owner o ON p.owner_id = o.owner_id;
GO

-- Parte 5
-- 6c
CREATE FUNCTION is_older_than(@age_months INT, @threshold INT)
RETURNS BIT
AS
BEGIN
    IF @age_months > @threshold
        RETURN 1;
    RETURN 0;
END;
GO

SELECT * FROM Owner;
SELECT * FROM Appointment;
SELECT * FROM Pet;
