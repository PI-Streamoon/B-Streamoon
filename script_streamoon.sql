-- Active: 1693362679120@@127.0.0.1@3306@streamoon

DROP USER 'StreamoonUser'@'%';

-- DELETE FROM mysql.user WHERE user = 'StreamoonUser';

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
        `registro` FLOAT NULL,
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
        'senha456293',
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
        484018,
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
VALUES (NULL, 4, 'CPU'), (NULL, 4, 'Memoria'), (NULL, 2, 'MemoriaUsada'), (NULL, 2, 'MemoriaTotal'), (NULL, 4, 'Disco'), (NULL, 3, 'Upload'), (NULL, 3, 'Download');

SELECT * FROM componente;

-- Tabela componenteServidor

INSERT INTO
    componenteServidor (
        idComponenteServidor,
        fkServidor,
        fkComponente
    )
VALUES (NULL, 2222, 100), (NULL, 2222, 101), (NULL, 2222, 102), (NULL, 2222, 103), (NULL, 2222, 104), (NULL, 2222, 105), (NULL, 2222, 106);

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
    MomentoRegistro,
    MAX(
        CASE
            WHEN Componente = 'CPU' THEN Registro
        END
    ) 'CPU',
    MAX(
        CASE
            WHEN Componente = 'Memoria' THEN Registro
        END
    ) 'Memória',
    MAX(
        CASE
            WHEN Componente = 'MemoriaTotal' THEN Registro
        END
    ) 'Memória Total',
    MAX(
        CASE
            WHEN Componente = 'MemoriaUsada' THEN Registro
        END
    ) 'Memória Usada'
FROM tabelaRegistros
GROUP BY MomentoRegistro;

-- FIM DO CÓDIGO PARA VIEW-------------------------------------------------------------------------------------------------------------------------------------------

-- Selects de Teste

SELECT * FROM tabelaRegistros;

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