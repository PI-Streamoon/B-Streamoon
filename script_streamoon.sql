-- Active: 1698205327640@@127.0.0.1@3306@streamoon
DROP DATABASE IF EXISTS streamoon;

CREATE DATABASE streamoon;

USE streamoon;

CREATE TABLE IF NOT EXISTS empresa (
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

CREATE TABLE logMoonAssistant (
    idLog INT PRIMARY KEY AUTO_INCREMENT
    ,fkUsuario INT NOT NULL
    ,msg TEXT NOT NULL
    ,isBot BOOLEAN NOT NULL
    ,dtHora DATETIME DEFAULT CURRENT_TIMESTAMP
    ,CONSTRAINT `fk_logMoonAssistant_usuario` FOREIGN KEY (`fkUsuario`) REFERENCES usuario (`idUsuario`)
);

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
        enderecoMAC VARCHAR(20),
        PRIMARY KEY (idServidor),
        CONSTRAINT `fk_Servidor_Origem` FOREIGN KEY (`fkOrigem`) REFERENCES servidor(`idServidor`) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT `fk_Servidor_Locais1` FOREIGN KEY (`fkLocais`) REFERENCES locais (`idLocais`) ON DELETE NO ACTION ON UPDATE NO ACTION
) AUTO_INCREMENT = 2222;

CREATE TABLE
	IF NOT EXISTS terminal (
	idTerminal INT NOT NULL AUTO_INCREMENT,
	comando VARCHAR(255) NOT NULL,
	retorno TEXT,
	fkServidor INT,
	PRIMARY KEY(idTerminal),
	CONSTRAINT `fk_Terminal_Servidor` FOREIGN KEY (`idTerminal`) REFERENCES servidor(`idServidor`) ON DELETE NO ACTION ON UPDATE NO ACTION
	) AUTO_INCREMENT = 1;
        
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
    
-- Inserindo tabela para os chamados, Alteração feita por: Kevyn (07/11/2023)
CREATE TABLE
	IF NOT EXISTS chamado (
		idChamado int primary key auto_increment,
        fkServidor int,
        fkRegistro decimal(5,2),
        horarioAbertura datetime,
        tempLocal decimal(4,2),
        CONSTRAINT `fk_servidor_componenteServidor` FOREIGN KEY (`fkServidor`) REFERENCES registro(`fkComponenteServidor`) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT `fk_idhamado_idRegistro` FOREIGN KEY (`idChamado`) REFERENCES registro(`idRegistro`) ON DELETE NO ACTION ON UPDATE NO ACTION
        );
        
CREATE TABLE
    IF NOT EXISTS dadosec2 (
        idEc2 INT PRIMARY KEY AUTO_INCREMENT,
        tipo VARCHAR(20),
        `vcpu` INT,
        `preco` FLOAT,
        `so` VARCHAR(20),
        `ram` FLOAT,
        `fkLocal` INT,
        CONSTRAINT `fk_local_ec2` FOREIGN KEY (`fkLocal`) REFERENCES locais(`idLocais`) ON DELETE NO ACTION ON UPDATE NO ACTION
    );  

CREATE TABLE 
    IF NOT EXISTS metricas (
        `idMetrica` INT PRIMARY KEY AUTO_INCREMENT,
        `maxValorNormal` DOUBLE NULL,
        `maxValorAlerta` DOUBLE NULL,
        `fkComponenteServidor` INT,
        CONSTRAINT `fkComponenteServidor` FOREIGN KEY (`fkComponenteServidor`) REFERENCES componenteServidor(`idComponenteServidor`) ON DELETE NO ACTION ON UPDATE NO ACTION
    );

CREATE TABLE 
	IF NOT EXISTS alertasSlack(
    idAlerta int primary key auto_increment,
    descricao varchar(50),
    fkComponente int,
    isAnalista tinyint,
    constraint `fk_componente` foreign key (fkComponente) references componente(idComponente) ON DELETE NO ACTION ON UPDATE NO ACTION
    );

-- Criação das Views

SELECT * FROM registro;

SELECT * FROM chamado;

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
    ),(
        1,
        'AWS',
        '23412247000110',
        'global'
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
        'Carl',
        '$2a$10$.jeLR4RKBa6ML96w0lmI5u8rUggbfyfq6IDeAhHtir10nyTasv5K2',
        '12345678901',
        'carl@gmail.com' -- 203457
    ), (
        NULL,
        484019,
        1,
        'suzy',
        '$2a$10$i4K5pWN.1cs/5/Z9lLJ9r.VkS1W8Z/pjK5E5TMAnqgfIfSyR1RU0a',
        '12345678902',
        'suzy@gmail.com' -- senha456293
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
VALUES (NULL, 2222, 100), (NULL, 2222, 101), (NULL, 2222, 102), (NULL, 2222, 103), (NULL, 2222, 104), (NULL, 2222, 105), (NULL, 2222, 106), (NULL, 2222, 107), (NULL, 2222, 108), (NULL, 2222, 109)
,(NULL, 2223, 100), (NULL, 2223, 101), (NULL, 2223, 102), (NULL, 2223, 103), (NULL, 2223, 104), (NULL, 2223, 105), (NULL, 2223, 106), (NULL, 2223, 107), (NULL, 2223, 108), (NULL, 2223, 109);

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

-- Tabela metricas
INSERT INTO 
    metricas (
        maxValorNormal, 
        maxValorAlerta, 
        fkComponenteServidor
        ) 
    VALUES 
        (70, 90, 1),
        (1401, 2099, 2),
        (70, 90, 3),
        (70, 90, 6),
        (80, 100, 9),
        (550, 1000, 10);

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
            WHEN CPU >= 90 THEN 2 ELSE 
                CASE
                    WHEN CPU >= 70 THEN 1 ELSE NULL
                END
        END
    ) 'nivelFalhaCPU',
    MAX(
        CASE
            WHEN Memoria >= 90 THEN 2 ELSE 
                CASE
                    WHEN Memoria >= 70 THEN 1 ELSE NULL
                END
        END
    ) 'nivelFalhaMemoria',
    MAX(
        CASE
            WHEN Disco >= 90 THEN 2 ELSE 
                CASE
                    WHEN Disco >= 70 THEN 1 ELSE NULL
                END
        END
    ) 'nivelFalhaDisco',
    MAX(
        CASE
            WHEN Upload >= 100 THEN 2 ELSE 
                CASE
                    WHEN Upload >= 80 THEN 1 ELSE NULL
                END
        END
    ) 'nivelFalhaUpload',
    MAX(
        CASE
            WHEN Download >= 1000 THEN 2 ELSE 
                CASE
                    WHEN Download >= 550 THEN 1 ELSE NULL
                END
        END
    ) 'nivelFalhaDownload',
     MAX(
        CASE
            WHEN FrequenciaCPU > 2100 THEN 2 ELSE 
                CASE
                    WHEN FrequenciaCPU > 1400 THEN 1 ELSE NULL
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
    FROM falhasColunas
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
    FROM falhasColunas
    WHERE MomentoRegistro >= '2023-10-05 23:59:59' AND MomentoRegistro <= '2023-10-30 23:59:59' AND idServidor = 2222
GROUP BY idServidor, Dia;

SELECT COUNT(idServidor) FROM falhasColunas WHERE MomentoRegistro >= '2023-10-05 23:59:59' AND MomentoRegistro <= '2023-10-30 23:59:59' AND idServidor = 2222
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
    idServidor,
    MomentoRegistro,
    nivelFalhaCPU AS CPU,
    nivelFalhaMemoria AS Memoria,
    nivelFalhaDisco AS Disco,
    nivelFalhaUpload AS Upload,
    nivelFalhaDownload AS Download
FROM (
    SELECT
        idServidor,
        MomentoRegistro,
        nivelFalhaCPU,
        nivelFalhaMemoria,
        nivelFalhaDisco,
        nivelFalhaUpload,
        nivelFalhaDownload,
        ROW_NUMBER() OVER (PARTITION BY idServidor ORDER BY MomentoRegistro DESC) AS rn
    FROM falhasColunas
) AS ranked
WHERE rn = 1;


SELECT MAX(MomentoRegistro) AS MomentoRegistro FROM falhasColunas WHERE `idServidor` = 2222;

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

CREATE TABLE Chamados (
    idChamado INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(150),
    descricao VARCHAR(250),
    dataAbertura DATETIME,
    isAberto BOOLEAN,
    prioridade VARCHAR(20),
    responsavel VARCHAR(100)
) AUTO_INCREMENT = 1; 

INSERT INTO Chamados (titulo, descricao, dataAbertura, isAberto, prioridade, responsavel) 
VALUES 
('Problema na Rede', 'Não consigo acessar a internet', '2023-11-25 09:00:00', TRUE, 'Alta', 'Suzy'),
('Erro no Sistema', 'O aplicativo está travando constantemente', '2023-11-25 10:30:00', TRUE, 'Média', 'Carl'),
('Solicitação de Novo Software', 'Precisamos de uma nova ferramenta de gerenciamento', '2023-11-25 11:45:00', TRUE, 'Baixa', 'Carlos'),
('Problema com componente', 'O componente parou de funcionar', '2023-11-25 12:15:00', TRUE, 'Alta', 'Ana'),
('Atualização de Software', 'Solicito atualização para a última versão', '2023-11-25 13:30:00', TRUE, 'Média', 'Pedro'),
('Problema no Email', 'Não consigo enviar emails', '2023-11-25 14:45:00', TRUE, 'Alta', 'Luisa'),
('Solicitação de Treinamento', 'Precisamos de um treinamento em segurança cibernética', '2023-11-25 15:20:00', TRUE, 'Baixa', 'Fernanda'),
('Problema no Acesso ao Sistema', 'Não consigo fazer login no sistema', '2023-11-25 16:00:00', FALSE, 'Média', 'Rafael'),
('Solicitação de Acesso a Dados', 'Preciso de acesso aos dados do projeto', '2023-11-25 17:15:00', TRUE, 'Baixa', 'Gabriel'),
('Problema no Servidor', 'O servidor está lento', '2023-11-25 18:30:00', TRUE, 'Alta', 'Isabela'),
('Problema com Paginação do Site', 'Usuários estão relatando que as páginas do site não estão sendo exibidas corretamente. Isso afeta a experiência do usuário e requer atenção imediata.', '2023-11-25 20:32:00', TRUE, 'urgente', 'Equipe de Desenvolvimento Web'),
('Vazamento de Dados Identificado', 'Um vazamento de dados foi identificado. A equipe de segurança precisa tomar medidas imediatas para mitigar os riscos e investigar a origem.', '2023-11-25 07:54:21', TRUE, 'urgente', 'Equipe de Segurança'),
('Problema Crítico no Servidor de E-mail', 'Os usuários estão relatando falhas ao enviar e receber e-mails. Este é um problema urgente que precisa ser resolvido imediatamente.', '2023-11-25 15:29:45', TRUE, 'urgente', 'Equipe de TI');


SELECT 
    `idEc2` id,
    `tipo`,
    `so`,
    `vcpu`,
    `ram`,
    `preco`,
    `descricao`
     FROM dadosec2 JOIN locais 
     ON `idLocais` = `fkLocal` 
     WHERE `fkLocal` = 102 LIMIT 9999; 
-- DELETE FROM mysql.user WHERE user = 'StreamoonUser';

-- CASO DE PROBLEMA NA CRIAÇÃO DO USUÁRIO DESCOMENTAR A PROXIMA LINHA 
DROP USER 'StreamoonUser'@'%';

CREATE USER 'StreamoonUser'@'%' IDENTIFIED BY 'Moon2023';

GRANT ALL PRIVILEGES ON streamoon.* TO 'StreamoonUser'@'%';

FLUSH PRIVILEGES;
