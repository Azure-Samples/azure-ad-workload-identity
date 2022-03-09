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

#region Using References
using System;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.ApplicationInsights.Extensibility;
using TodoApi.Models;
using TodoApi.Services;
using TodoApi.Helpers;
using Azure.Storage.Blobs;
using Azure.Identity;
#endregion

namespace TodoApi
{
    /// <summary>
    /// Startup class
    /// </summary>
    public class Startup
    {
        /// <summary>
        /// Creates an instance of the Startup class
        /// </summary>
        /// <param name="configuration">The configuration created by the CreateDefaultBuilder.</param>
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        /// <summary>
        /// Gets or sets the Configuration property.
        /// </summary>
        public IConfiguration Configuration { get; }

        /// <summary>
        /// Get or sets the CloudConfigurationManager
        /// </summary>
        public static object CloudConfigurationManager { get; private set; }

        /// <summary>
        /// This method gets called by the runtime. Use this method to add services to the container.
        /// </summary>
        /// <param name="services">The services collection.</param>
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddOptions();
            services.Configure<RepositoryServiceOptions>(Configuration.GetSection("RepositoryService"));
            services.Configure<NotificationServiceOptions>(Configuration.GetSection("NotificationService"));
            services.Configure<Models.DataProtectionOptions>(Configuration.GetSection("DataProtectionService"));
            services.AddDataProtection().PersistKeysToAzureBlobStorage(GetBlobClient());
            services.AddApplicationInsightsTelemetry(Configuration);
            services.AddSingleton<ITelemetryInitializer, CloudRoleNameTelemetryInitializer>();
            services.AddMvc();
            services.AddDbContext<TodoContext>(opt => opt.UseInMemoryDatabase("TodoList"));
            services.AddSingleton<INotificationService, ServiceBusNotificationService>();
            services.AddSingleton<IRepositoryService<TodoItem>, CosmosDbRepositoryService<TodoItem>>();

            // Register the Swagger generator, defining one or more Swagger documents
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Version = "v1",
                    Title = "ToDo API",
                    Description = "A simple example ASP.NET Core Web API",
                    TermsOfService = new Uri("https://www.apache.org/licenses/LICENSE-2.0"),
                    Contact = new OpenApiContact
                    {
                        Name = "Paolo Salvatori",
                        Email = "paolos@microsoft.com",
                        Url = new Uri("https://github.com/paolosalvatori")
                    },
                    License = new OpenApiLicense
                    {
                        Name = "Use under Apache License 2.0",
                        Url = new Uri("https://www.apache.org/licenses/LICENSE-2.0")
                    }
                });
            });
        }

        /// <summary>
        /// This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        /// </summary>
        /// <param name="applicationBuilder">ApplicationBuilder paremeter.</param>
        /// <param name="hostingEnvironment">HostingEnvironment parameter.</param>
        /// <param name="loggerFactory">loggerFactory parameter.</param>
        /// <param name="serviceProvider">serviceProvider parameter.</param>
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger();

            // Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.), specifying the Swagger JSON endpoint.
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "TodoList API V1");
                c.RoutePrefix = string.Empty;
            });

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
            return containerClient.GetBlobClient("todoapikey");
        }
    }
}
