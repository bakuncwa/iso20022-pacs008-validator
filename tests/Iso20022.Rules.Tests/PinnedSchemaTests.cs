using System.Xml;
using System.Xml.Schema;

namespace Iso20022.Rules.Tests;

public class PinnedSchemaTests
{
    [Fact]
    public void PinnedXsd_CompilesWithXmlSchemaSet()
    {
        var schemaDirectory = FindSchemaDirectory();
        var schemas = new XmlSchemaSet { XmlResolver = null };

        foreach (var path in Directory.EnumerateFiles(schemaDirectory, "*.xsd"))
        {
            using var reader = XmlReader.Create(path, new XmlReaderSettings { DtdProcessing = DtdProcessing.Prohibit });
            schemas.Add(null, reader);
        }

        schemas.Compile();

        Assert.True(schemas.IsCompiled);
        Assert.Single(schemas.Schemas("urn:iso:std:iso:20022:tech:xsd:pacs.008.001.08").Cast<XmlSchema>());
    }

    private static string FindSchemaDirectory()
    {
        for (var directory = new DirectoryInfo(AppContext.BaseDirectory); directory is not null; directory = directory.Parent)
        {
            var candidate = Path.Combine(directory.FullName, "schemas");
            if (Directory.Exists(candidate))
            {
                return candidate;
            }
        }

        throw new DirectoryNotFoundException("schemas/ not found above the test output directory.");
    }
}
