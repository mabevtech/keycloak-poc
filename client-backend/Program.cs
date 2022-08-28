using AmbevTech.Keycloak.Client;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddHttpClient();

// This register a type for Microsoft.Extensions.Caching.Memory.IMemoryCache
// which is required to construct a AmbevTech.Keycloak.Client.CacheInMemory
// which is used by AmbevTech.Keycloak.Client.AddClientKeycloak
builder.Services.AddMemoryCache();

builder.Services.AddClientKeycloak();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
