var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// POST /validate and the /runs endpoints arrive in Phase 3, with authentication (SR2).
app.MapGet("/healthz", () => Results.Ok(new { status = "ok" }));

app.Run();

public partial class Program;
