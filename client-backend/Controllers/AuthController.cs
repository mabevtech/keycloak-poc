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
    // This is not working, see "Flow" section in README
    [Route("auth")]
    public Task Auth(
        [FromQuery(Name = "state")] string state,
        [FromQuery(Name = "session_state")] string session_state,
        [FromQuery(Name = "auth_code")] string authCode
    )
    {
        var secret = _configuration["Keycloak:Secret"];
        // TODO exchange code for tokens with Keycloak
        return Task.CompletedTask;
    }

    // Client credentials flow.
    // Client should be confidential and have this flow enabled for this to work.
    // "Client authentication" and "Service account roles" are the respective toggles
    // in the Keycloak UI.
    [Route("token")]
    public Task<string> GetToken()
    {
        return _tokenManager.GetToken();
    }
}
