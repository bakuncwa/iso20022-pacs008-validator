-- ISO 20022 pacs.008 validator: relational schema (README ERD).
-- SQL Server / Azure SQL. In Azure the database is provisioned by infra/, so skip the first batch.
IF DB_ID(N'Iso20022') IS NULL CREATE DATABASE Iso20022;
GO
USE Iso20022;
GO

CREATE TABLE dbo.RUN (
    RunId          NVARCHAR(64)  NOT NULL PRIMARY KEY,
    StartedAt      DATETIME2     NOT NULL,
    Seed           INT           NULL,
    MessageCount   INT           NOT NULL,
    ConsumerCount  INT           NOT NULL,
    CodeVersion    NVARCHAR(64)  NOT NULL,
    DurationMs     INT           NULL
);

-- MessageId is a surrogate key. MsgId is the pacs.008 field and is deliberately not unique:
-- R-DUP-01 has to be able to store duplicates it detects.
CREATE TABLE dbo.MESSAGE (
    MessageId        NVARCHAR(64)  NOT NULL PRIMARY KEY,
    RunId            NVARCHAR(64)  NOT NULL REFERENCES dbo.RUN (RunId),
    MsgId            NVARCHAR(35)  NULL,
    UETR             NVARCHAR(36)  NULL,
    EndToEndId       NVARCHAR(35)  NULL,
    Currency         NCHAR(3)      NULL,
    Amount           DECIMAL(18,5) NULL,
    ChargeBearer     NVARCHAR(4)   NULL,
    PurposeCode      NVARCHAR(35)  NULL,
    DebtorBIC        NVARCHAR(11)  NULL,
    CreditorBIC      NVARCHAR(11)  NULL,
    MaskedDebtorIBAN NVARCHAR(34)  NULL
);
CREATE INDEX IX_MESSAGE_RunId ON dbo.MESSAGE (RunId);

CREATE TABLE dbo.REQUIREMENT (
    RequirementId NVARCHAR(16)  NOT NULL PRIMARY KEY,
    FrReference   NVARCHAR(32)  NOT NULL,
    PersonaId     NVARCHAR(8)   NOT NULL,
    UserStory     NVARCHAR(400) NOT NULL,
    Priority      NVARCHAR(16)  NOT NULL
);

CREATE TABLE dbo.RULE_DEFINITION (
    RuleId        NVARCHAR(16)  NOT NULL PRIMARY KEY,
    Name          NVARCHAR(200) NOT NULL,
    Category      NVARCHAR(16)  NOT NULL,
    Severity      NVARCHAR(16)  NOT NULL,
    RequirementId NVARCHAR(16)  NULL REFERENCES dbo.REQUIREMENT (RequirementId)
);

-- TargetRuleId is NULL for DefectType = 'ANOMALY', which targets no rule.
CREATE TABLE dbo.INJECTED_DEFECT (
    DefectId     NVARCHAR(64)  NOT NULL PRIMARY KEY,
    MessageId    NVARCHAR(64)  NOT NULL REFERENCES dbo.MESSAGE (MessageId),
    DefectType   NVARCHAR(32)  NOT NULL,
    TargetRuleId NVARCHAR(16)  NULL REFERENCES dbo.RULE_DEFINITION (RuleId),
    XPath        NVARCHAR(400) NULL
);
CREATE INDEX IX_INJECTED_DEFECT_MessageId ON dbo.INJECTED_DEFECT (MessageId);

CREATE TABLE dbo.VALIDATION_RESULT (
    ResultId  NVARCHAR(64)   NOT NULL PRIMARY KEY,
    MessageId NVARCHAR(64)   NOT NULL REFERENCES dbo.MESSAGE (MessageId),
    RuleId    NVARCHAR(16)   NULL REFERENCES dbo.RULE_DEFINITION (RuleId),
    Outcome   NVARCHAR(16)   NOT NULL,
    XPath     NVARCHAR(400)  NULL,
    Detail    NVARCHAR(1000) NULL
);
CREATE INDEX IX_VALIDATION_RESULT_MessageId ON dbo.VALIDATION_RESULT (MessageId);

CREATE TABLE dbo.ANOMALY_SCORE (
    ScoreId      NVARCHAR(64) NOT NULL PRIMARY KEY,
    MessageId    NVARCHAR(64) NOT NULL UNIQUE REFERENCES dbo.MESSAGE (MessageId),
    ModelVersion NVARCHAR(32) NOT NULL,
    Score        FLOAT        NOT NULL,
    Flagged      BIT          NOT NULL
);

CREATE TABLE dbo.TEST_CASE (
    TestCaseId    NVARCHAR(16) NOT NULL PRIMARY KEY,
    RequirementId NVARCHAR(16) NOT NULL REFERENCES dbo.REQUIREMENT (RequirementId),
    Type          NVARCHAR(32) NOT NULL,
    Priority      NVARCHAR(16) NOT NULL
);

CREATE TABLE dbo.TEST_EXECUTION (
    ExecutionId NVARCHAR(64) NOT NULL PRIMARY KEY,
    TestCaseId  NVARCHAR(16) NOT NULL REFERENCES dbo.TEST_CASE (TestCaseId),
    RunAt       DATETIME2    NOT NULL,
    Result      NVARCHAR(16) NOT NULL,
    BuildId     NVARCHAR(64) NULL
);

CREATE TABLE dbo.DEFECT (
    BugId       NVARCHAR(16)  NOT NULL PRIMARY KEY,
    TestCaseId  NVARCHAR(16)  NOT NULL REFERENCES dbo.TEST_CASE (TestCaseId),
    ExecutionId NVARCHAR(64)  NULL REFERENCES dbo.TEST_EXECUTION (ExecutionId),
    Severity    NVARCHAR(16)  NOT NULL,
    Status      NVARCHAR(16)  NOT NULL
);

CREATE TABLE dbo.LOAD_TEST_RESULT (
    LoadResultId      NVARCHAR(64) NOT NULL PRIMARY KEY,
    TestCaseId        NVARCHAR(16) NOT NULL REFERENCES dbo.TEST_CASE (TestCaseId),
    Scenario          NVARCHAR(64) NOT NULL,
    RequestsPerSecond FLOAT        NULL,
    P50Ms             FLOAT        NULL,
    P95Ms             FLOAT        NULL,
    P99Ms             FLOAT        NULL,
    ErrorRate         FLOAT        NULL
);

CREATE TABLE dbo.SECURITY_FINDING (
    FindingId     NVARCHAR(64)  NOT NULL PRIMARY KEY,
    TestCaseId    NVARCHAR(16)  NOT NULL REFERENCES dbo.TEST_CASE (TestCaseId),
    ScanDate      DATE          NOT NULL,
    OwaspCategory NVARCHAR(64)  NOT NULL,
    Severity      NVARCHAR(16)  NOT NULL,
    Endpoint      NVARCHAR(200) NULL,
    Status        NVARCHAR(16)  NOT NULL
);
GO
