using AmbevTech.Keycloak.JWT;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddJwtKeycloak(builder.Configuration);

var CORS_POLICY = "client_origin";
builder.Services.AddCors(options => 
    options.AddPolicy(
        name: CORS_POLICY, 
        policy => policy
            .WithOrigins(
                builder.Configuration["CLIENT_URL"],
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
