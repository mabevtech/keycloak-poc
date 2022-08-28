using System.Net;
using Microsoft.AspNetCore.Mvc;
using AmbevTech.Keycloak.Client;

namespace ClientApi.Controllers;

[ApiController]
public class AuthController : ControllerBase
{
    private readonly ILogger<AuthController> _logger;
    private readonly IConfiguration _configuration;
    private readonly HttpClient _httpClient;
    private readonly ITokenManager _tokenManager;

    public AuthController(
        ILogger<AuthController> logger,
        IConfiguration configuration,
        HttpClient httpClient,
        ITokenManager tokenManager
    )
    {
        _logger = logger;
        _configuration = configuration;
        _httpClient = httpClient;
        _tokenManager = tokenManager;
    }

    // Client credentials flow
    [Route("token")]
    public Task<string> GetToken()
    {
        return _tokenManager.GetToken();
    }
}
