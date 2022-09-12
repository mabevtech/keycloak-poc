using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace ResourceServer.Controllers;

[ApiController]
public class ResourcesController : ControllerBase
{
    private readonly ILogger<ResourcesController> _logger;
    private readonly IConfiguration _configuration;
    private readonly HttpClient _httpClient;

    public ResourcesController(
        ILogger<ResourcesController> logger,
        IConfiguration configuration,
        HttpClient httpClient
    )
    {
        _logger = logger;
        _configuration = configuration;
        _httpClient = httpClient;
    }

    [HttpGet("contacts")]
    [Authorize(Roles = "read_contacts")]
    public Task<string[]> GetContacts()
    {
        return Task.FromResult(new string[] { "alice@domain.com", "bob@domain.com", "foo@bar.com" });
    }

    [HttpGet("ping")]
    [Authorize]
    public Task<string> Ping()
    {
        return Task.FromResult("pong");
    }
}
