-- Active: 1700446865473@@127.0.0.1@1433@master
DROP DATABASE IF EXISTS streamoon;
CREATE DATABASE streamoon;

USE streamoon;


CREATE TABLE empresa
(
	idEmpresa int NOT NULL PRIMARY KEY  IDENTITY(484020, 1), 
	nome nvarchar(45) NULL DEFAULT NULL, 
	cnpj nchar(14) NULL DEFAULT NULL, 
	localidade nvarchar(45) NULL DEFAULT NULL
);

CREATE TABLE usuario (
    idUsuario INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    fkEmpresa INT NOT NULL,
    fkAdmin INT,
    nome VARCHAR(50) NOT NULL,
    senha VARCHAR(60) NOT NULL,
    cpf CHAR(11) NOT NULL,
    email VARCHAR(50) NOT NULL,
    CONSTRAINT fk_Usuario_Empresa FOREIGN KEY (fkEmpresa)
        REFERENCES empresa (idEmpresa)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_Usuario_Usuario1 FOREIGN KEY (fkAdmin)
        REFERENCES usuario (idUsuario)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);


CREATE TABLE locais (
    idLocais INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    fkEmpresa INT NOT NULL,
    cep VARCHAR(45) NULL,
    descricao VARCHAR(100) NULL,
    CONSTRAINT fk_Locais_Empresa1 FOREIGN KEY (fkEmpresa)
        REFERENCES empresa (idEmpresa)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);


CREATE TABLE servidor (
    idServidor INT NOT NULL PRIMARY KEY IDENTITY(2222,1),
    fkLocais INT NOT NULL,
    fkOrigem INT,
    CONSTRAINT fk_Servidor_Origem FOREIGN KEY (fkOrigem) REFERENCES servidor(idServidor) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_Servidor_Locais1 FOREIGN KEY (fkLocais) REFERENCES locais (idLocais) ON DELETE NO ACTION ON UPDATE NO ACTION
);


CREATE TABLE unidadeMedida (
    idUnidadeMedida INT NOT NULL IDENTITY(1,1),
    nomeMedida VARCHAR(35) NOT NULL,
    PRIMARY KEY (idUnidadeMedida)
);

CREATE TABLE componente (
    idComponente INT NOT NULL PRIMARY KEY IDENTITY(100,1),
    fkUnidadeMedida INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    CONSTRAINT fk_Componente_UnidadeMedida1 FOREIGN KEY (fkUnidadeMedida)
        REFERENCES unidadeMedida (idUnidadeMedida)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);


CREATE TABLE componenteServidor (
    idComponenteServidor INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    fkServidor INT NOT NULL,
    fkComponente INT NOT NULL,
    CONSTRAINT fk_Componente_has_Servidor_Servidor1 FOREIGN KEY (fkServidor)
        REFERENCES servidor (idServidor)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_ComponenteServidor_Componente1 FOREIGN KEY (fkComponente)
        REFERENCES componente (idComponente)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE registro (
    idRegistro INT NOT NULL PRIMARY KEY IDENTITY(100000,1),
    registro INT NULL,
    dtHora DATETIME NULL,
    fkComponenteServidor INT NOT NULL,
    CONSTRAINT fk_Registro_ComponenteServidor1 FOREIGN KEY (fkComponenteServidor)
        REFERENCES componenteServidor (idComponenteServidor)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE dadosec2 (
    idEc2 INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(20),
    vcpu INT,
    preco FLOAT,
    so VARCHAR(20),
    ram FLOAT,
    fkLocal INT,
    CONSTRAINT fk_local_ec2 FOREIGN KEY (fkLocal) REFERENCES locais(idLocais) ON DELETE NO ACTION ON UPDATE NO ACTION
);


-- Criando a view tabelaRegistros
CREATE VIEW tabelaRegistros AS
SELECT TOP 10000
    registro.idRegistro AS IdRegistro,
    registro.registro AS Registro,
    registro.dtHora AS MomentoRegistro,
    componente.nome AS Componente,
    unidadeMedida.nomeMedida AS Simbolo,
    componenteServidor.idComponenteServidor,
    servidor.idServidor AS idServidor
FROM registro
    JOIN componenteServidor ON registro.fkComponenteServidor = componenteServidor.idComponenteServidor
    JOIN servidor ON componenteServidor.fkServidor = servidor.idServidor
    JOIN componente ON componenteServidor.fkComponente = componente.idComponente
    JOIN unidadeMedida ON componente.fkUnidadeMedida = unidadeMedida.idUnidadeMedida
ORDER BY Registro, MomentoRegistro, Componente;

INSERT INTO
    empresa (
        nome,
        cnpj,
        localidade
    )
VALUES (
        'HBOMax',
        '12345678901234',
        'Centro de São Paulo'
    ), (
        'Netflix',
        '98765432101234',
        'São Jorge da Serra - Perdizes'
    ),(
        'AWS',
        '23412247000110',
        'global'
    );

-- Tabela usuario

INSERT INTO
    usuario (
        fkEmpresa,
        fkAdmin,
        nome,
        senha,
        cpf,
        email
    )
VALUES (
        484020,
        NULL,
        'Carl',
        '$2a$10$.jeLR4RKBa6ML96w0lmI5u8rUggbfyfq6IDeAhHtir10nyTasv5K2',
        '12345678901',
        'carl@gmail.com' -- 203457
    ), (
        484020,
        1,
        'suzy',
        '$2a$10$i4K5pWN.1cs/5/Z9lLJ9r.VkS1W8Z/pjK5E5TMAnqgfIfSyR1RU0a',
        '12345678902',
        'suzy@gmail.com' -- senha456293
    );

-- Tabela locais

INSERT INTO
    locais (
        fkEmpresa,
        cep,
        descricao
    )
VALUES (
        484020,
        '12345-678',
        'Local X, Andar 2'
    ), (
        484021,
        '98765-432',
        'Local Y, Andar 12'
    );

-- Tabela servidor

INSERT INTO
    servidor (fkLocais, fkOrigem)
VALUES (100, NULL), (101, 2222);

-- Tabela unidadeMedida

INSERT INTO
    unidadeMedida (nomeMedida)
VALUES ('GHZ'), ('GB'), ('Mbps'), ('%');

-- Tabela componente

INSERT INTO
    componente (
        fkUnidadeMedida,
        nome
    )
VALUES (4, 'CPU'), (1, 'FrequenciaCPU'),(4, 'Memoria'), (2, 'MemoriaUsada'), (2, 'MemoriaTotal'), (4, 'Disco'), (2, 'DiscoEntrada'), (2, 'DiscoSaida'), (3, 'Upload'), (3, 'Download');

INSERT INTO
    componenteServidor (
        fkServidor,
        fkComponente
    )
VALUES (2222, 100), (2222, 101), (2222, 102), (2222, 103), (2222, 104), (2222, 105), (2222, 106), (2222, 107), (2222, 108), (2222, 109)
,(2223, 100), (2223, 101), (2223, 102), (2223, 103), (2223, 104), (2223, 105), (2223, 106), (2223, 107), (2223, 108), (2223, 109);

-- Tabela registro


-- Criando a view infoServidor
CREATE VIEW infoServidor AS
SELECT
    servidor.idServidor,
    locais.cep,
    empresa.nome AS NomeEmpresa
FROM
    servidor
JOIN
    locais ON servidor.fkLocais = locais.idLocais
JOIN
    empresa ON locais.fkEmpresa = empresa.idEmpresa;


-- Criando a view infoUsuario
CREATE VIEW infoUsuario AS
SELECT
    u.nome AS 'Nome Usuário',
    u.email AS 'Email Usuário',
    empresa.nome AS 'Nome Empresa'
FROM
    usuario AS u
JOIN
    empresa ON u.fkEmpresa = empresa.idEmpresa;

-- Criando a view registroColunar
CREATE VIEW registroColunar AS
SELECT
    servidor.idServidor,
    registro.dtHora AS MomentoRegistro,
    MAX(
        CASE
            WHEN componente.nome = 'CPU' THEN registro.registro
        END
    ) AS CPU,
    MAX(
        CASE
            WHEN componente.nome = 'FrequenciaCPU' THEN registro.registro
        END
    ) AS FrequenciaCPU,
    MAX(
        CASE
            WHEN componente.nome = 'Memoria' THEN registro.registro
        END
    ) AS Memoria,
    MAX(
        CASE
            WHEN componente.nome = 'MemoriaUsada' THEN registro.registro
        END
    ) AS MemoriaUsada,
    MAX(
        CASE
            WHEN componente.nome = 'MemoriaTotal' THEN registro.registro
        END
    ) AS MemoriaTotal,
    MAX(
        CASE
            WHEN componente.nome = 'Disco' THEN registro.registro
        END
    ) AS Disco,
    MAX(
        CASE
            WHEN componente.nome = 'DiscoEntrada' THEN registro.registro
        END
    ) AS DiscoEntrada,
    MAX(
        CASE
            WHEN componente.nome = 'DiscoSaida' THEN registro.registro
        END
    ) AS DiscoSaida,
    MAX(
        CASE
            WHEN componente.nome = 'Upload' THEN registro.registro
        END
    ) AS Upload,
    MAX(
        CASE
            WHEN componente.nome = 'Download' THEN registro.registro
        END
    ) AS Download
FROM registro
INNER JOIN componenteServidor ON componenteServidor.idComponenteServidor = registro.fkComponenteServidor
INNER JOIN servidor ON componenteServidor.fkServidor = servidor.idServidor
INNER JOIN componente ON componente.idComponente = componenteServidor.fkComponente
GROUP BY servidor.idServidor, registro.dtHora;

-- Criando a view falhasColunas
CREATE VIEW falhasColunas AS
SELECT
    idServidor,
    MomentoRegistro,
    MAX(
        CASE
            WHEN CPU >= 90 THEN 2
            WHEN CPU >= 70 THEN 1
            ELSE NULL
        END
    ) AS nivelFalhaCPU,
    MAX(
        CASE
            WHEN Memoria >= 90 THEN 2
            WHEN Memoria >= 70 THEN 1
            ELSE NULL
        END
    ) AS nivelFalhaMemoria,
    MAX(
        CASE
            WHEN Disco >= 90 THEN 2
            WHEN Disco >= 70 THEN 1
            ELSE NULL
        END
    ) AS nivelFalhaDisco,
    MAX(
        CASE
            WHEN Upload >= 100 THEN 2
            WHEN Upload >= 80 THEN 1
            ELSE NULL
        END
    ) AS nivelFalhaUpload,
    MAX(
        CASE
            WHEN Download >= 1000 THEN 2
            WHEN Download >= 550 THEN 1
            ELSE NULL
        END
    ) AS nivelFalhaDownload,
    MAX(
        CASE
            WHEN FrequenciaCPU > 2100 THEN 2
            WHEN FrequenciaCPU > 1400 THEN 1
            ELSE NULL
        END
    ) AS nivelFalhaFreqCpu
FROM registroColunar
GROUP BY idServidor, MomentoRegistro;

-- Criando um login no SQL Server
CREATE LOGIN StreamoonUser WITH PASSWORD = 'Moon2023';

-- Criando um usu�rio associado ao login no banco de dados desejado
USE streamoon;
DROP USER StreamoonUser;
CREATE USER StreamoonUser FOR LOGIN StreamoonUser;

-- Concedendo permiss�es ao usu�rio no banco de dados
GRANT ALL PRIVILEGES TO StreamoonUser;