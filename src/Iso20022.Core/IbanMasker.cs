namespace Iso20022.Core;

public static class IbanMasker
{
    private const int VisibleCharacters = 4;

    /// <summary>Masks all but the last four characters (FR10). Anything shorter is masked fully.</summary>
    public static string Mask(string iban)
    {
        ArgumentNullException.ThrowIfNull(iban);

        return iban.Length <= VisibleCharacters
            ? new string('*', iban.Length)
            : string.Concat(new string('*', iban.Length - VisibleCharacters), iban.AsSpan(iban.Length - VisibleCharacters));
    }
}
