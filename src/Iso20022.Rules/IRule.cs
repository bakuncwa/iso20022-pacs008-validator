using System.Xml.Linq;
using Iso20022.Core;

namespace Iso20022.Rules;

/// <summary>One rule from the README catalog. Each rule is its own class, shared by worker and API.</summary>
public interface IRule
{
    string RuleId { get; }

    IEnumerable<RuleFailure> Evaluate(XDocument message);
}
