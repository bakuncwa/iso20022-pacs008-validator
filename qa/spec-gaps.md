# Spec gaps found during project setup

The README is unchanged. Each item below is a conflict between it and the rapide source
(commit `d96f648`) or the pinned XSD, and needs a decision before the phase shown.

| ID | Phase | Gap | Affects | Recommendation |
|----|-------|-----|---------|----------------|
| GAP-1 | 1 | rapide has no seed. The CLI only takes `-n`, `-d`, `-o`, `-z`, and values come from `SecureRandom` and `Math.random`. | REQ-ISO-001, TC-002, FR13, `RUN.Seed` | Freeze a generated raw batch as the reproducible baseline, and apply the seed to the injector. Reword TC-002 to compare re-injected batches. |
| GAP-2 | 1 | Rules run only after the XSD passes, but the pinned CBPR+ XSD already enforces several of them (table below). | R-FMT-01, R-FMT-05, R-BUS-02, R-BUS-03, R-BUS-04 and their test cases | Pin the base ISO pacs.008.001.08 XSD if it passes on rapide output, which should restore `NbOfTxs` and `CtrlSum` (check its facets first). Then either run rules on schema-invalid but well-formed messages, or expect R-SCH-01 in the remaining test cases. |
| GAP-3 | 2 | Confirmed on real output: rapide never sets an IBAN or a debtor account (0 IBANs in 9 messages). | R-FMT-02, TC-009, TC-017, REQ-ISO-005, REQ-ISO-010, `MaskedDebtorIBAN` | Have the injector add synthetic, checksum-valid IBANs to clean messages. Without them, masking is never exercised. |
| GAP-4 | 2 | Confirmed on real output: configured purpose codes go to `CtgyPurp/Cd`. `Purp/Cd` is hard-coded to `COMC`, which is not in the configured list. | R-BUS-05 | Point R-BUS-05 at `CtgyPurp/Cd`, or add `COMC` to the list. |
| GAP-5 | 2 | rapide scales every amount to 2 decimals. Clean JPY cannot be generated now (GAP-7), so no false positives are expected, but R-FMT-04 gets its zero-decimal coverage only from injected defects. | R-FMT-04, TC-012 | Keep JPY as an injected case in TC-012. |
| GAP-7 | 1 | rapide has BICs only for US, TH, GB, CA, IE, IN and MX. With AE, PH and JP configured, a 50-message run produced 9 files and still exited 0. | README currency list (AED, PHP, JPY), anomaly corridors | Done: config now uses US, IE, GB, CA, MX, TH with USD, EUR, GBP, CAD, MXN, THB, and `run_rapide.sh` fails on a short batch. To keep AED, PHP or JPY, add BIC and LEI rows to a rapide fork. |
| GAP-8 | 2 | Each file wraps `AppHdr` and `Document` in a `RequestPayload` root, which the XSD rejects. With `Document` extracted, 9 of 9 pass. | Worker reader, API, TC-007 | Extract `Document` before XSD validation, in code shared by the worker and API. |
| GAP-9 | 2 | Only the instructing and instructed agents use the fictitious BICs. Other agents come from rapide's fake BIC list. Debtor and creditor names come from rapide's LEI data and look like real organisations. | README "fictitious identifiers only" and "all data is synthetic" claims | Add fictitious LEI rows in a rapide fork, or soften the README wording. |
| GAP-10 | 2 | Sampled amounts run from about 914 thousand to 9.25 billion (rapide draws 5,000 to 10 billion, whole units). | Anomaly scorer, ANOMALY injections | Set the "unusual amount" injection against this range, not real-world payment sizes. |
| GAP-6 | 2 | R-BUS-01, R-BUS-06 and R-BUS-07 map to no requirement, and have no test case alongside R-BUS-05. `RequirementId` is NULL for those three in `sql/02_seed.sql`. | OBJ-4 | Add a requirement and test cases for them. |

## GAP-2 detail: what the pinned XSD does to each test case

| Test case | README expects | Pinned XSD | Actual result |
|-----------|----------------|------------|---------------|
| TC-008, 9-character BIC | R-FMT-01 | `BICFIDec2014Identifier` pattern | R-SCH-01 |
| TC-010, version 1 UUID | R-FMT-05 | `UUIDv4Identifier` pattern | R-SCH-01 |
| TC-013, `NbOfTxs` = 2 | R-BUS-02 | `Max15NumericText_fixed`, enumeration `1` | R-SCH-01 |
| TC-014, `CtrlSum` changed | R-BUS-03 | `CtrlSum` is not in the schema | R-SCH-01 |
| TC-015, charge bearer `XXXX` | R-BUS-04 | Enumeration DEBT, CRED, SHAR | R-SCH-01 |

This also answers the README's open question on R-BUS-04: `SLEV` is not allowed by the pinned XSD.

## Minor README inconsistencies

- Phase 4 says "all five Power BI pages", but six are listed.
- The worker section says "four stages", but its table has five.
- NFR references appear as both `NFR-05` and `NFR5`.
