using System.Net;
using Microsoft.AspNetCore.Mvc;

namespace ClientApi.Controllers;

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
    public Task<HttpStatusCode> GetContacts()
    {
        return Task.FromResult(HttpStatusCode.NoContent);
    }
}
