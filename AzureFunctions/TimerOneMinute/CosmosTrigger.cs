using System;
using System.Collections.Generic;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Company.Function
{
    public class HeartbeatLogger
    {
        private readonly ILogger<HeartbeatLogger> _logger;
        public HeartbeatLogger(ILogger<HeartbeatLogger> logger)
        {
            _logger = logger;
        }

        [Function("HeartbeatLogger")]
        public void Run([TimerTrigger("0 * * * * *")] TimerInfo timer)
        {
            var indiaTimeZone = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
            var indiaTime = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, indiaTimeZone);
            _logger.LogInformation($"Function HeartbeatLogger heartbeat at IST: {indiaTime}");
        }
    }
}
