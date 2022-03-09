#region Copyright
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
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.ApplicationInsights;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Azure.Extensions.AspNetCore.Configuration.Secrets;
#endregion

namespace TodoWeb
{
    public class Program
    {
        #region Private Static Fields
        private static string applicationInsightsInstrumentationKey = null;
        #endregion

        #region Public Methods
        public static void Main(string[] args)
        {
            CreateWebHostBuilder(args).Build().Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .CaptureStartupErrors(true)
                .UseSetting(WebHostDefaults.DetailedErrorsKey, "true")
                .UseStartup<Startup>()
                .ConfigureAppConfiguration(GetApplicationInsightsInstrumentationKey)
                .ConfigureLogging(
                    builder =>
                    {
                        // providing an instrumentation key here is required if you are using
                        // standalone package Microsoft.Extensions.Logging.ApplicationInsights
                        // or if you want to capture logs from early in the application startup 
                        // pipeline from Startup.cs or Program.cs itself.
                        builder.AddApplicationInsights(applicationInsightsInstrumentationKey);

                        // Adding the filter below to ensure logs of all severity from Program.cs
                        // is sent to ApplicationInsights.
                        // Replace YourAppName with the namespace of your application's Program.cs
                        builder.AddFilter<ApplicationInsightsLoggerProvider>("VotingWeb.Program", LogLevel.Trace);

                        // Adding the filter below to ensure logs of all severity from Startup.cs
                        // is sent to ApplicationInsights.
                        // Replace YourAppName with the namespace of your application's Startup.cs
                        builder.AddFilter<ApplicationInsightsLoggerProvider>("VotingWeb.Startup", LogLevel.Trace);
                    }
                );
        #endregion

        #region Private Methods
        private static void GetApplicationInsightsInstrumentationKey(WebHostBuilderContext context, IConfigurationBuilder configurationBuilder)
        {
            // Read from default configuration providers: config files and environment variables
            var builtConfig = configurationBuilder.Build();

            var keyVaultName = builtConfig["KeyVault:Name"];

            if (string.IsNullOrWhiteSpace(keyVaultName))
            {
                throw new ArgumentException($"Key Vault name parameter cannot be null or empty.");
            }

            // Configure Key Vault configuration provider
            var keyVaultUrl = $"https://{keyVaultName}.vault.azure.net/";
            var secretClient = new SecretClient(new Uri(keyVaultUrl), new DefaultAzureCredential());
            configurationBuilder.AddAzureKeyVault(secretClient, new KeyVaultSecretManager());

            // Read configuration from Key Vault
            builtConfig = configurationBuilder.Build();

            // Read the Application Insights Instrumentation Key stored in Key Vault
            applicationInsightsInstrumentationKey = builtConfig["ApplicationInsights:InstrumentationKey"];
        }
        #endregion
    }
}
