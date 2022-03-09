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
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.ApplicationInsights.Extensibility;
using TodoWeb.Helpers;
using TodoWeb.Models;
using TodoWeb.Services;
using Azure.Storage.Blobs;
using Azure.Identity;
#endregion

namespace TodoWeb
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddOptions();
            services.Configure<TodoApiServiceOptions>(Configuration.GetSection("TodoApiService"));
            services.Configure<Models.DataProtectionOptions>(Configuration.GetSection("DataProtectionService"));
            services.AddDataProtection().PersistKeysToAzureBlobStorage(GetBlobClient());
            services.AddApplicationInsightsTelemetry(Configuration);
            services.AddSingleton<ITelemetryInitializer, CloudRoleNameTelemetryInitializer>();
            services.AddMvc();
            services.AddDbContext<TodoContext>(opt => opt.UseInMemoryDatabase("TodoList"));
            services.AddSingleton<ITodoApiService, TodoApiService>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();
            app.UseRouting();
            app.UseAuthorization();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapRazorPages();
                endpoints.MapControllers();
            });
        }

        /// <summary>
        /// Get a reference to the blob client where to store the data protection key
        /// </summary>
        /// <returns>blob used for the data protection key</returns>
        private BlobClient GetBlobClient()
        {
            // Validation
            var containerName = Configuration["DataProtection:BlobStorage:ContainerName"];

            if (string.IsNullOrWhiteSpace(containerName))
            {
                throw new ArgumentNullException("No container name is defined in the configuration of the Data Protection service.");
            }

            var useAzureCredential = Configuration["DataProtection:BlobStorage:UseAzureCredential"];
            BlobContainerClient containerClient;

            if (!string.IsNullOrWhiteSpace(useAzureCredential) &&
                string.Compare(useAzureCredential, "true", true) == 0)
            {
                var accountName = Configuration["DataProtection:BlobStorage:AccountName"];

                if (string.IsNullOrWhiteSpace(accountName))
                {
                    throw new ArgumentNullException("No acount name is defined in the configuration of the Data Protection service.");
                }

                // Construct the blob container endpoint from the arguments.
                string containerEndpoint = string.Format("https://{0}.blob.core.windows.net/{1}",
                                                        accountName,
                                                        containerName);
                // Get a credential and create a service client object for the blob container.
                containerClient = new BlobContainerClient(new Uri(containerEndpoint),
                                                          new DefaultAzureCredential());
            }
            else
            {
                var connectionString = Configuration["DataProtection:BlobStorage:ConnectionString"];

                if (string.IsNullOrWhiteSpace(connectionString))
                {
                    throw new ArgumentNullException("No connection string is defined in the configuration of the Data Protection service.");
                }

                // Use the storage account connection string
                containerClient = new BlobContainerClient(connectionString, containerName);
            }

            // Get the blob client object.
            return containerClient.GetBlobClient("todowebkey");
        }
    }
}
