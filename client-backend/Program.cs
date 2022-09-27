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

var CORS_POLICY = "client_origin";
var clientUrl = builder.Configuration["CLIENT_URL"];
builder.Services.AddCors(options =>
    options.AddPolicy(
        name: CORS_POLICY,
        policy => policy
            .WithOrigins(
                clientUrl,
                "http://localhost:3000"
                )
            .AllowAnyMethod()
            .AllowAnyHeader()
    )
);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors(CORS_POLICY);

app.UseAuthorization();

app.MapControllers();

app.Run();
