using System;
using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using AmbevTech.Keycloak.Client;
using AmbevTech.Keycloak.Client.Entities;

namespace ClientApi.Controllers;

[ApiController]
public class AuthController : ControllerBase
{
    private readonly ILogger<AuthController> _logger;
    private readonly IConfiguration _configuration;
    private readonly HttpClient _httpClient;
    private readonly ITokenManager _tokenManager;
    private readonly IMemoryCache _cache;

    public AuthController(
        ILogger<AuthController> logger,
        IConfiguration configuration,
        HttpClient httpClient,
        ITokenManager tokenManager,
        IMemoryCache cache
    )
    {
        _logger = logger;
        _configuration = configuration;
        _httpClient = httpClient;
        _tokenManager = tokenManager;
        _cache = cache;
    }

    // Standard flow (back-channel round trip)
    // Couldn't make this to work,
    // see "Authorization Flow" section in README for details.
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

    // Client credentials flow ("Api login").
    // See "Authorization Flow" section in README for details.
    [Route("token")]
    public async Task<string> GetToken()
    {
        var result = await _tokenManager.GetToken();
        return result;
    }

    // Currently we're only really logging out,
    // just removing token from the cache.
    [Route("logout")]
    public Task Logout()
    {
        // TODO Call the logout endpoint at Keycloak

        var clientId = _configuration["Keycloak:Resource"];
        var key = $"{SsoConstants.PrefixAuth}{clientId}";
        _cache.Remove(key);

        return Task.CompletedTask;
    }
}
