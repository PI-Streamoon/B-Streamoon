-- Active: 1693362679120@@127.0.0.1@3306@streamoon
DROP DATABASE IF EXISTS streamoon;

CREATE DATABASE streamoon;

USE streamoon;

CREATE TABLE
    IF NOT EXISTS empresa (
        idEmpresa INT NOT NULL AUTO_INCREMENT,
        nome VARCHAR(45) NULL,
        cnpj CHAR(14) NULL,
        localidade VARCHAR(45) NULL,
        PRIMARY KEY (idEmpresa)
    ) AUTO_INCREMENT = 484018;

CREATE TABLE
    IF NOT EXISTS usuario (
        idUsuario INT NOT NULL AUTO_INCREMENT,
        fkEmpresa INT NOT NULL,
        fkAdmin INT,
        nome VARCHAR(50) NOT NULL,
        senha VARCHAR(100) NOT NULL,
        cpf CHAR(11) NOT NULL,
        email VARCHAR(50) NOT NULL,
        PRIMARY KEY (`idUsuario`, `fkEmpresa`),
        CONSTRAINT `fk_Usuario_Empresa` FOREIGN KEY (`fkEmpresa`) REFERENCES empresa (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT `fk_Usuario_Usuario1` FOREIGN KEY (`fkAdmin`) REFERENCES usuario (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION
    ) AUTO_INCREMENT = 1;

CREATE TABLE
    IF NOT EXISTS locais (
        idLocais INT NOT NULL AUTO_INCREMENT,
        fkEmpresa INT NOT NULL,
        cep VARCHAR(45) NULL,
        descricao VARCHAR(100) NULL,
        PRIMARY KEY (`idLocais`),
        CONSTRAINT `fk_Locais_Empresa1` FOREIGN KEY (`fkEmpresa`) REFERENCES empresa (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION
    ) AUTO_INCREMENT = 100;

CREATE TABLE
    IF NOT EXISTS servidor (
        idServidor INT NOT NULL AUTO_INCREMENT,
        fkLocais INT NOT NULL,
        fkOrigem INT,
        PRIMARY KEY (idServidor),
        CONSTRAINT `fk_Servidor_Origem` FOREIGN KEY (`fkOrigem`) REFERENCES servidor(`idServidor`) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT `fk_Servidor_Locais1` FOREIGN KEY (`fkLocais`) REFERENCES locais (`idLocais`) ON DELETE NO ACTION ON UPDATE NO ACTION
    ) AUTO_INCREMENT = 2222;

CREATE TABLE
    IF NOT EXISTS unidadeMedida (
        idUnidadeMedida INT NOT NULL AUTO_INCREMENT,
        nomeMedida VARCHAR(35) NOT NULL,
        PRIMARY KEY (`idUnidadeMedida`)
    ) AUTO_INCREMENT = 1;

CREATE TABLE
    IF NOT EXISTS componente (
        idComponente INT NOT NULL AUTO_INCREMENT,
        fkUnidadeMedida INT NOT NULL,
        nome VARCHAR(50) NOT NULL,
        PRIMARY KEY (
            `idComponente`,
            `fkUnidadeMedida`
        ),
        CONSTRAINT `fk_Componente_UnidadeMedida1` FOREIGN KEY (`fkUnidadeMedida`) REFERENCES unidadeMedida (`idUnidadeMedida`) ON DELETE NO ACTION ON UPDATE NO ACTION
    ) AUTO_INCREMENT = 100;

CREATE TABLE
    IF NOT EXISTS componenteServidor (
        `idComponenteServidor` INT NOT NULL AUTO_INCREMENT,
        `fkServidor` INT NOT NULL,
        `fkComponente` INT NOT NULL,
        PRIMARY KEY (
            `idComponenteServidor`,
            `fkServidor`,
            `fkComponente`
        ),
        CONSTRAINT `fk_Componente_has_Servidor_Servidor1` FOREIGN KEY (`fkServidor`) REFERENCES servidor (`idServidor`) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT `fk_ComponenteServidor_Componente1` FOREIGN KEY (`fkComponente`) REFERENCES componente (`idComponente`) ON DELETE NO ACTION ON UPDATE NO ACTION
    ) AUTO_INCREMENT = 1;

CREATE TABLE
    IF NOT EXISTS registro (
        `idRegistro` INT NOT NULL AUTO_INCREMENT,
        `registro` DOUBLE NULL,
        `dtHora` DATETIME NULL,
        `fkComponenteServidor` INT NOT NULL,
        PRIMARY KEY (
            `idRegistro`,
            `fkComponenteServidor`
        ),
        CONSTRAINT `fk_Registro_ComponenteServidor1` FOREIGN KEY (`fkComponenteServidor`) REFERENCES componenteServidor (`idComponenteServidor`) ON DELETE NO ACTION ON UPDATE NO ACTION
    ) AUTO_INCREMENT = 100000;

-- Criação das Views

SELECT * FROM registro;

CREATE VIEW
    tabelaRegistros AS
SELECT
    registro.idRegistro AS 'IdRegistro',
    registro.registro AS 'Registro',
    registro.dtHora AS 'MomentoRegistro',
    componente.nome AS 'Componente',
    unidadeMedida.nomeMedida AS 'Símbolo',
    componenteServidor.idComponenteServidor,
    servidor.idServidor AS 'idServidor'
FROM registro
    JOIN componenteServidor ON fkComponenteServidor = idComponenteServidor
    JOIN servidor ON fkServidor = idServidor
    JOIN componente ON fkComponente = idComponente
    JOIN unidadeMedida ON fkUnidadeMedida = idUnidadeMedida
ORDER BY 2 AND 3 AND 4
LIMIT 10000;

CREATE VIEW infoServidor AS
SELECT
    servidor.idServidor,
    locais.cep,
    empresa.nome
FROM servidor
    JOIN locais ON fkLocais = idLocais
    JOIN empresa ON fkEmpresa = idEmpresa;

CREATE VIEW
    infoUsuario AS
SELECT
    u.nome AS 'Nome Usuário',
    u.email AS 'Email Usuário',
    empresa.nome AS 'Nome Empresa'
FROM usuario AS u
    JOIN empresa ON fkEmpresa = idEmpresa;

SELECT * FROM infoUsuario;

-- Inserção de dados

-- Tabela empresa

INSERT INTO
    empresa (
        idEmpresa,
        nome,
        cnpj,
        localidade
    )
VALUES (
        NULL,
        'HBOMax',
        '12345678901234',
        'Centro de São Paulo'
    ), (
        NULL,
        'Netflix',
        '98765432101234',
        'São Jorge da Serra - Perdizes'
    );

-- Tabela usuario

INSERT INTO
    usuario (
        idUsuario,
        fkEmpresa,
        fkAdmin,
        nome,
        senha,
        cpf,
        email
    )
VALUES (
        NULL,
        484018,
        NULL,
        'Fernando Brandão',
        '$2a$10$.jeLR4RKBa6ML96w0lmI5u8rUggbfyfq6IDeAhHtir10nyTasv5K2',
        '12345678901',
        'brandao@gmail.com'
    ), (
        NULL,
        484019,
        1,
        'Marise',
        '$2a$10$i4K5pWN.1cs/5/Z9lLJ9r.VkS1W8Z/pjK5E5TMAnqgfIfSyR1RU0a',
        '12345678902',
        'marise@gmail.com'
    );

-- Tabela locais

INSERT INTO
    locais (
        idLocais,
        fkEmpresa,
        cep,
        descricao
    )
VALUES (
        NULL,
        484018,
        '12345-678',
        'Local X, Andar 2'
    ), (
        NULL,
        484019,
        '98765-432',
        'Local Y, Andar 12'
    );

-- Tabela servidor

INSERT INTO
    servidor (fkLocais, fkOrigem)
VALUES (100, NULL), (101, 2222);

-- Tabela unidadeMedida

INSERT INTO
    unidadeMedida (idUnidadeMedida, nomeMedida)
VALUES (NULL, 'GHZ'), (NULL, 'GB'), (NULL, 'Mbps'), (NULL, '%');

-- Tabela componente

INSERT INTO
    componente (
        idComponente,
        fkUnidadeMedida,
        nome
    )
VALUES (NULL, 4, 'CPU'), (NULL, 1, 'FrequenciaCPU'),(NULL, 4, 'Memoria'), (NULL, 2, 'MemoriaUsada'), (NULL, 2, 'MemoriaTotal'), (NULL, 4, 'Disco'), (NULL, 3, 'Upload'), (NULL, 3, 'Download');

SELECT * FROM componente;

-- Tabela componenteServidor

INSERT INTO
    componenteServidor (
        idComponenteServidor,
        fkServidor,
        fkComponente
    )
VALUES (NULL, 2222, 100), (NULL, 2222, 101), (NULL, 2222, 102), (NULL, 2222, 103), (NULL, 2222, 104), (NULL, 2222, 105), (NULL, 2222, 106), (NULL, 2222, 107);

-- Tabela registro

INSERT INTO
    registro (
        idRegistro,
        registro,
        dtHora,
        fkComponenteServidor
    )
VALUES (
        NULL,
        20348034,
        '2023-08-01 10:00:00',
        1
    ), (
        NULL,
        02475092,
        '2023-08-02 15:30:00',
        2
    );


CREATE VIEW registroColunar AS
SELECT
    idServidor,
    dtHora AS MomentoRegistro,
    MAX(
        CASE
            WHEN nome = 'CPU' THEN Registro
        END
    ) 'CPU',
    MAX(
        CASE
            WHEN nome = 'FrequenciaCPU' THEN Registro
        END
    ) 'FrequenciaCPU',
    MAX(
        CASE
            WHEN nome = 'Memoria' THEN Registro
        END
    ) 'Memoria',
    MAX(
        CASE
            WHEN nome = 'MemoriaUsada' THEN Registro
        END
    ) 'MemoriaUsada',
    MAX(
        CASE
            WHEN nome = 'MemoriaTotal' THEN Registro
        END
    ) 'MemoriaTotal',
    MAX(
        CASE
            WHEN nome = 'Disco' THEN Registro
        END
    ) 'Disco',
    MAX(
        CASE
            WHEN nome = 'Upload' THEN Registro
        END
    ) 'Upload',
    MAX(
        CASE
            WHEN nome = 'Download' THEN Registro
        END
    ) 'Download'
FROM registro
INNER JOIN componenteServidor ON componenteServidor.`idComponenteServidor` = registro.`fkComponenteServidor`
INNER JOIN servidor ON componenteServidor.`fkServidor` = servidor.`idServidor`
INNER JOIN componente ON componente.`idComponente` = componenteServidor.`fkComponente`
GROUP BY idServidor, MomentoRegistro;

DELETE FROM mysql.user WHERE user = 'StreamoonUser';

CREATE USER 'StreamoonUser'@'%' IDENTIFIED BY 'Moon2023';

GRANT ALL PRIVILEGES ON streamoon.* TO 'StreamoonUser'@'%';

FLUSH PRIVILEGES;
