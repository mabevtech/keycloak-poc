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

    // Standard flow (back-channel round trip)
    [Route("auth")]
    public Task Auth(
        [FromQuery(Name = "auth_code")] string authCode,
        [FromQuery(Name = "redirect_uri")] string redirectUri
    )
    {
        var secret = _configuration["Keycloak:Secret"];
        // send http request to keycloak
        return Task.CompletedTask;
    }

    // Client credentials flow.
    // Client should be confidential and have the this flow enabled for this to work.
    // "Client authentication" and "Service account roles" are the respective options
    // in the Keycloak UI.
    [Route("token")]
    public Task<string> GetToken()
    {
        return _tokenManager.GetToken();
    }
}
