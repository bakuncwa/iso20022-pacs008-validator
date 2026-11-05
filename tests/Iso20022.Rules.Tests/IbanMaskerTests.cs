using Iso20022.Core;

namespace Iso20022.Rules.Tests;

public class IbanMaskerTests
{
    [Theory]
    [InlineData("GB82WEST12345698765432", "******************5432")]
    [InlineData("12345", "*2345")]
    [InlineData("1234", "****")]
    [InlineData("", "")]
    public void Mask_ShowsOnlyTheLastFourCharacters(string iban, string expected)
    {
        Assert.Equal(expected, IbanMasker.Mask(iban));
    }
}
