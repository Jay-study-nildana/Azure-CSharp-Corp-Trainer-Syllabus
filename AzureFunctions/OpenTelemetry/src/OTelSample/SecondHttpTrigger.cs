using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace OTelSample;

public class SecondHttpTrigger
{
    private readonly ILogger<SecondHttpTrigger> _logger;

    public SecondHttpTrigger(ILogger<SecondHttpTrigger> logger)
    {
        _logger = logger;
    }

    [Function("second_http_function")]
    public MultiResponse Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
    {
        _logger.LogInformation("second_http_function function processed a request.");

        var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
        response.WriteStringAsync("Hello from second_http_function!");

        return new MultiResponse
        {
            Messages = new string[] { "Hello" },
            HttpResponse = response
        };
    }
}

public class MultiResponse
{
    [ServiceBusOutput("%ServiceBusQueueName%", Connection = "ServiceBusConnection")]
    public string[]? Messages { get; set; }

    [HttpResult]
    public HttpResponseData? HttpResponse { get; set; }
}