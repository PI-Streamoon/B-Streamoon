-- Active: 1698205327640@@127.0.0.1@3306@streamoon

-- DROP USER 'StreamoonUser'@'%';

DELETE FROM mysql.user WHERE user = 'StreamoonUser';

CREATE USER 'StreamoonUser'@'%' IDENTIFIED BY 'Moon2023';

GRANT ALL PRIVILEGES ON streamoon.* TO 'StreamoonUser'@'%';

FLUSH PRIVILEGES;

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
VALUES (NULL, 4, 'CPU'), (NULL, 1, 'FrequenciaCPU'),(NULL, 4, 'Memoria'), (NULL, 2, 'MemoriaUsada'), (NULL, 2, 'MemoriaTotal'), (NULL, 4, 'Disco'), (NULL, 2, 'DiscoEntrada'), (NULL, 2, 'DiscoSaida'), (NULL, 3, 'Upload'), (NULL, 3, 'Download');

SELECT * FROM componente;

-- Tabela componenteServidor

INSERT INTO
    componenteServidor (
        idComponenteServidor,
        fkServidor,
        fkComponente
    )
VALUES (NULL, 2222, 100), (NULL, 2222, 101), (NULL, 2222, 102), (NULL, 2222, 103), (NULL, 2222, 104), (NULL, 2222, 105), (NULL, 2222, 106), (NULL, 2222, 107), (NULL, 2222, 108), (NULL, 2222, 109);

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

-- CÓDIGO DA CRIAÇÃO DA VIEW PARA VISUALIZAÇÃO DOS DADOS EM TABELA --------------------------------------------------------------------------------------------

SET @sql = NULL;

-- Criando uma variável para armazenar o comando

SELECT
    GROUP_CONCAT(
        DISTINCT CONCAT(
            'max(CASE WHEN Componente = ''',
            Componente,
            -- aqui vem o nome que você setou para os componentes na view!
            ''' THEN Registro END) ',
            Componente -- aqui vem o nome que você setou para os componentes na view!
        )
    ) INTO @sql
FROM tabelaRegistros;

-- Aqui vem o nome da sua view!

-- MAX(CASE WHEN Componente = 'Componente1' THEN Registro END) Componente1,

-- MAX(CASE WHEN Componente = 'Componente2' THEN Registro END) Componente2, .....

SELECT @sql;

SET
    @sql = CONCAT(
        'SELECT idServidor, MomentoRegistro, ',
        @sql,
        '
                 
FROM tabelaRegistros
                   
GROUP BY idServidor, MomentoRegistro'
    );

-- Lembra de trocar AS informações (idServidor, MomentoRegistro, tabelaRegistros) pelos nomes que você usou na VIEW

SELECT @sql;

PREPARE stmt FROM @sql;

-- Prepara um statement para executar o comando guardado na variável @sql

EXECUTE stmt;

-- Executa o statement

DEALLOCATE PREPARE stmt;

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
            WHEN nome = 'DiscoEntrada' THEN Registro
        END
    ) 'DiscoEntrada',
     MAX(
        CASE
            WHEN nome = 'DiscoSaida' THEN Registro
        END
    ) 'DiscoSaida',
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


CREATE VIEW falhasColunas AS
SELECT idServidor, MomentoRegistro,
    MAX(
        CASE
            WHEN CPU >= 90 THEN 1 ELSE 
                CASE
                    WHEN CPU >= 70 THEN 2 ELSE 0
                END
        END
    ) 'nivelFalhaCPU',
    MAX(
        CASE
            WHEN Memoria >= 90 THEN 1 ELSE 
                CASE
                    WHEN Memoria >= 70 THEN 2 ELSE 0
                END
        END
    ) 'nivelFalhaMemoria',
    MAX(
        CASE
            WHEN Disco >= 90 THEN 1 ELSE 
                CASE
                    WHEN Disco >= 70 THEN 2 ELSE 0
                END
        END
    ) 'nivelFalhaDisco',
    MAX(
        CASE
            WHEN Upload >= 100 THEN 1 ELSE 
                CASE
                    WHEN Upload >= 80 THEN 2 ELSE 0
                END
        END
    ) 'nivelFalhaUpload',
    MAX(
        CASE
            WHEN Download >= 400 THEN 1 ELSE 
                CASE
                    WHEN Download >= 350 THEN 2 ELSE 0
                END
        END
    ) 'nivelFalhaDownload',
     MAX(
        CASE
            WHEN FrequenciaCPU > 2100 THEN 1 ELSE 
                CASE
                    WHEN FrequenciaCPU > 1400 THEN 2 ELSE 0
                END
        END
    ) 'nivelFalhaFreqCpu'
FROM registroColunar
GROUP BY idServidor, MomentoRegistro;


-- FIM DO CÓDIGO PARA VIEW-------------------------------------------------------------------------------------------------------------------------------------------

-- Selects de Teste

-- FALHAS AGRUPADOS POR SEMANA
SELECT idServidor,
    SUM((nivelFalhaCPU = 1) + (nivelFalhaMemoria = 1) + (nivelFalhaDisco = 1) + (nivelFalhaUpload = 1) + (nivelFalhaDownload = 1) + (nivelFalhaFreqCpu = 1)) AS TotalFalhas,
    SUM((nivelFalhaCPU = 2) + (nivelFalhaMemoria = 2) + (nivelFalhaDisco = 2) + (nivelFalhaUpload = 2) + (nivelFalhaDownload = 2) + (nivelFalhaFreqCpu = 2)) AS TotalFalhasCriticas
    FROM falhascolunas
WHERE MomentoRegistro >= '2023-10-23 23:59:59' AND MomentoRegistro <= '2023-10-30 23:59:59'
GROUP BY idServidor;

-- CRITICOS AGRUPADOS POR SEMANA
SELECT `idServidor`, 
    DATE(MomentoRegistro), 
    SUM(nivelFalhaCPU = 2) AS QuantFalhasCPU,
    SUM(nivelFalhaMemoria = 2) AS QuantFalhasMemoria,
    SUM(nivelFalhaDisco = 2) AS QuantFalhasDisco,
    SUM(nivelFalhaUpload = 2) AS QuantFalhasUpload,
    SUM(nivelFalhaDownload = 2) AS QuantFalhasDownload
FROM falhasColunas
WHERE MomentoRegistro >= '1990-05-20' AND MomentoRegistro <= '2023-10-31'
GROUP BY `idServidor`, DATE(MomentoRegistro);

SELECT idServidor,
    DATE_FORMAT(DATE(MomentoRegistro), "%d/%m/%Y") AS Dia,
    SUM((nivelFalhaCPU = 1) + (nivelFalhaMemoria = 1) + (nivelFalhaDisco = 1) + (nivelFalhaUpload = 1) + (nivelFalhaDownload = 1) + (nivelFalhaFreqCpu = 1)) AS TotalFalhas,
    SUM((nivelFalhaCPU = 2) + (nivelFalhaMemoria = 2) + (nivelFalhaDisco = 2) + (nivelFalhaUpload = 2) + (nivelFalhaDownload = 2) + (nivelFalhaFreqCpu = 2)) AS TotalFalhasCriticas
    FROM falhascolunas
    WHERE MomentoRegistro >= '2023-10-05 23:59:59' AND MomentoRegistro <= '2023-10-30 23:59:59' AND idServidor = ${idServidor}
GROUP BY idServidor, Dia;

SELECT COUNT(idServidor) FROM falhascolunas WHERE MomentoRegistro >= '2023-10-05 23:59:59' AND MomentoRegistro <= '2023-10-30 23:59:59' AND idServidor = 2222
AND `nivelFalhaFreqCpu` = 1;

 SELECT idServidor,
    DATE_FORMAT(DATE(MomentoRegistro), "%d/%m/%Y") AS Dia,
    SUM(nivelFalhaCPU = 1) AS QuantFalhasCPU,
    SUM(nivelFalhaMemoria = 1) AS QuantFalhasMemoria,
    SUM(nivelFalhaDisco = 1) AS QuantFalhasDisco
    FROM falhasColunas
    WHERE MomentoRegistro >= '2023-10-21 23:59:59' AND MomentoRegistro <= '2023-10-28 23:59:59' AND idServidor = 2222
    GROUP BY Dia;

SELECT
    MomentoRegistro,
    Registro,
    Componente
FROM tabelaRegistros
GROUP BY
    MomentoRegistro,
    Registro,
    Componente
ORDER BY MomentoRegistro;

SELECT * FROM registro;

SELECT * FROM componenteServidor;

SELECT
    r.registro,
    r.dtHora,
    c.nome,
    um.nomeMedida
FROM registro r
    JOIN componenteServidor cs ON r.fkComponenteServidor = cs.idComponenteServidor
    JOIN componente c ON cs.fkComponente = c.idComponente
    JOIN unidadeMedida um ON c.fkUnidadeMedida = um.idUnidadeMedida;

-- SELECT PARA SELEÇÃO DE TODOS OS REGISTROS DOS COMPONENTES COM SUA UNIDADE DE MEDIDA DE CADA SERVIDOR DE CADA LOCAL DE CADA EMPRESA

SELECT
    empresa.nome,
    locais.idLocais,
    servidor.idServidor,
    componenteServidor.idComponenteServidor,
    componente.idComponente,
    unidadeMedida.nomeMedida,
    registro.registro,
    registro.dtHora
FROM registro
    JOIN componenteServidor ON idComponenteServidor = fkComponenteServidor
    JOIN componente ON idComponente = fkComponente
    JOIN unidadeMedida ON idUnidadeMedida = fkUnidadeMedida
    JOIN servidor ON idServidor = fkServidor
    JOIN locais ON idLocais = fkLocais
    JOIN empresa ON idEmpresa = fkEmpresa;

SELECT
    r.registro,
    r.dtHora,
    c.nome AS nomeComponente,
    um.nomeMedida
FROM registro r
    LEFT JOIN componenteServidor cs ON r.fkComponenteServidor = cs.idComponenteServidor
    LEFT JOIN componente c ON cs.fkComponente = c.idComponente
    LEFT JOIN unidadeMedida um ON c.fkUnidadeMedida = um.idUnidadeMedida
ORDER BY
    um.nomeMedida,
    c.nome;
    
select * from registro 
	join componenteServidor on fkComponenteServidor = idComponenteServidor
    join componente 
    join unidadeMedida
    where fkUnidadeMedida = 3;
    

select * from registroColunar;

CREATE VIEW situacaoServidor AS
SELECT idServidor,
    MomentoRegistro,
    CASE 
        WHEN nivelFalhaCPU = 1 OR nivelFalhaDisco = 1 THEN "Alerta" ELSE
        CASE 
            WHEN nivelFalhaCPU = 2 OR nivelFalhaDisco = 2 THEN "Critico"  ELSE "Normal"
        END
    END AS 'Status'
    FROM falhasColunas;

SELECT * FROM situacaoServidor;
