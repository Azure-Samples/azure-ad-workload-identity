﻿#region Copyright
//=======================================================================================
// Microsoft 
//
// This sample is supplemental to the technical guidance published on my personal
// blog at https://github.com/paolosalvatori. 
// 
// Author: Paolo Salvatori
//=======================================================================================
// Copyright (c) Microsoft Corporation. All rights reserved.
// 
// LICENSED UNDER THE APACHE LICENSE, VERSION 2.0 (THE "LICENSE"); YOU MAY NOT USE THESE 
// FILES EXCEPT IN COMPLIANCE WITH THE LICENSE. YOU MAY OBTAIN A COPY OF THE LICENSE AT 
// http://www.apache.org/licenses/LICENSE-2.0
// UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING, SOFTWARE DISTRIBUTED UNDER THE 
// LICENSE IS DISTRIBUTED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
// KIND, EITHER EXPRESS OR IMPLIED. SEE THE LICENSE FOR THE SPECIFIC LANGUAGE GOVERNING 
// PERMISSIONS AND LIMITATIONS UNDER THE LICENSE.
//=======================================================================================
#endregion

#region Using Directives
using System;
using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Options;
using System.Threading.Tasks;
using TodoApi.Models;
using Newtonsoft.Json;
using System.Text;
using Microsoft.Extensions.Logging;
using System.Diagnostics; /**/
using Azure.Identity;
#endregion

namespace TodoApi.Services
{
    /// <summary>
    /// This class is used to send notifications to a Service Bus queue.
    /// </summary>
    public class ServiceBusNotificationService : NotificationService
    {
        #region Private Instance Fields
        private readonly NotificationServiceOptions _options;
        private readonly ServiceBusClient _serviceBusClient;
        private readonly ServiceBusSender _serviceBusSender;
        private readonly ILogger<NotificationService> _logger;
        #endregion

        #region Public Constructor
        /// <summary>
        /// Creates a new instance of the ServiceBusNotificationService class
        /// </summary>
        public ServiceBusNotificationService(IOptions<NotificationServiceOptions> options,
                                             ILogger<ServiceBusNotificationService> logger)
        {
            if (options?.Value == null)
            {
                throw new ArgumentNullException(nameof(options), "No configuration is defined for the notification service.");
            }

            if (options.Value.ServiceBus == null)
            {
                throw new ArgumentNullException(nameof(options), "No ServiceBus element is defined in the configuration for the notification service.");
            }

            if (string.IsNullOrWhiteSpace(options.Value.ServiceBus.QueueName))
            {
                throw new ArgumentNullException(nameof(options), "No queue name is defined in the configuration of the Service Bus notification service.");
            }

            _options = options.Value;
            _logger = logger;

            if (!string.IsNullOrWhiteSpace(options.Value.ServiceBus.UseAzureCredential) &&
                string.Compare(options.Value.ServiceBus.UseAzureCredential, "true", true) == 0)
            {
                if (!string.IsNullOrWhiteSpace(_options.ServiceBus.Namespace))
                {
                    _serviceBusClient = new ServiceBusClient($"{_options.ServiceBus.Namespace}.servicebus.windows.net", new DefaultAzureCredential());
                }
                else
                {
                    throw new ArgumentNullException(nameof(options), "The name of the Service Bus mamespace is not defined in the configuration of the Service Bus notification service.");
                }
            }
            else if (!string.IsNullOrWhiteSpace(_options.ServiceBus.ConnectionString))
            {
                _serviceBusClient = new ServiceBusClient(_options.ServiceBus.ConnectionString);
            }
            else
            {
                throw new ArgumentNullException(nameof(options), "The connection string of the Service Bus mamespace is not defined in the configuration of the Service Bus notification service.");
            }
            _serviceBusSender = _serviceBusClient.CreateSender(_options.ServiceBus.QueueName);
            _logger.LogInformation(LoggingEvents.Configuration, "ConnectionString = {connectionstring}", _options.ServiceBus.ConnectionString);
            _logger.LogInformation(LoggingEvents.Configuration, "QueueName = {queuename}", _options.ServiceBus.QueueName);

        }
        #endregion

        #region Public Overridden Methods
        /// <summary>
        /// Send to a notification to a given queue
        /// </summary>
        /// <param name="notification"></param>
        /// <returns></returns>
        public override async Task SendNotificationAsync(Notification notification)
        {
            if (notification == null)
            {
                throw new ArgumentNullException(nameof(notification));
            }

            var stopwatch = new Stopwatch();
            stopwatch.Start();


            var message = new ServiceBusMessage(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(notification)))
            {
                MessageId = notification.Id
            };
            message.ApplicationProperties.Add("source", "TodoApi");
            await _serviceBusSender.SendMessageAsync(message);

            stopwatch.Stop();
            _logger.LogInformation($"Notification sent to {_options.ServiceBus.QueueName} queue in {stopwatch.ElapsedMilliseconds} ms.");
        } 
        #endregion
    }
}
