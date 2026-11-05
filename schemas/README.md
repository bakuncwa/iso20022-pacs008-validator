# Pinned schema

`CBPRPlus_pacs_008_001_08_20210413_0914.xsd` is the CBPR+ profile of pacs.008.001.08, copied from
[rapide](https://github.com/aws-samples/iso20022-message-generator) (MIT-0) at commit `d96f648`.
rapide validates its own output against this file, so clean messages should pass it.
This pin conflicts with several planned test cases: see `qa/spec-gaps.md` (GAP-2).
