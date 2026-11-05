namespace Iso20022.Core;

/// <summary>A single failed rule. Detail must never contain an unmasked IBAN (SR1).</summary>
public sealed record RuleFailure(string RuleId, string? XPath, string Detail);
