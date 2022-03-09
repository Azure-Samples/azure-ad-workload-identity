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
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.Azure.Cosmos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TodoApi.Models;
using Azure.Identity;
#endregion

namespace TodoApi.Services
{
    /// <summary>
    ///  This class is used to read, write, delete and update data from Cosmos DB using Document DB API. 
    /// </summary>
    public class CosmosDbRepositoryService<T> : IRepositoryService<T> where T : Entity, new()
    {
        #region Private Static Fields
        private static bool isInitialized;
        private static object initLock = new object();
        #endregion

        #region Private Instance Fields
        private readonly RepositoryServiceOptions _repositoryServiceOptions;
        private readonly CosmosClient _cosmosClient;
        private readonly ILogger<CosmosDbRepositoryService<T>> _logger;

        //Reusable instance of ItemClient which represents the connection to a Cosmos endpoint
        private Database database = null;
        private Container container = null;
        #endregion

        #region Public Constructor
        /// <summary>
        /// Creates a new instance of the ServiceBusNotificationService class
        /// </summary>
        public CosmosDbRepositoryService(IOptions<RepositoryServiceOptions> options,
                                         ILogger<CosmosDbRepositoryService<T>> logger)
        {
            if (options?.Value == null)
            {
                throw new ArgumentNullException(nameof(options), "No configuration is defined for the repository service.");
            }

            if (options.Value.CosmosDb == null)
            {
                throw new ArgumentNullException(nameof(options), "No CosmosDb element is defined in the configuration for the notification service.");
            }

            if (string.IsNullOrWhiteSpace(options.Value.CosmosDb.EndpointUri))
            {
                throw new ArgumentNullException(nameof(options), "No endpoint uri is defined in the configuration of the Cosmos DB notification service.");
            }

            if (string.IsNullOrWhiteSpace(options.Value.CosmosDb.DatabaseName))
            {
                throw new ArgumentNullException(nameof(options), "No database name is defined in the configuration of the Cosmos DB notification service.");
            }

            if (string.IsNullOrWhiteSpace(options.Value.CosmosDb.CollectionName))
            {
                throw new ArgumentNullException(nameof(options), "No collection name is defined in the configuration of the Cosmos DB notification service.");
            }

            _repositoryServiceOptions = options.Value;
            _logger = logger;

            if (!string.IsNullOrWhiteSpace(options.Value.CosmosDb.UseAzureCredential) && 
                string.Compare(options.Value.CosmosDb.UseAzureCredential, "true", true) == 0)
            {
                _cosmosClient = new CosmosClient(_repositoryServiceOptions.CosmosDb.EndpointUri, 
                                                 new DefaultAzureCredential(),
                                                 new CosmosClientOptions
                                                 {
                                                     RequestTimeout = TimeSpan.FromMinutes(5),
                                                     ConnectionMode = ConnectionMode.Gateway
                                                 });
            }
            else if (!string.IsNullOrWhiteSpace(options.Value.CosmosDb.PrimaryKey))
            {
                _cosmosClient = new CosmosClient(_repositoryServiceOptions.CosmosDb.EndpointUri,
                                            options.Value.CosmosDb.PrimaryKey,
                                            new CosmosClientOptions
                                            {
                                                RequestTimeout = TimeSpan.FromMinutes(5),
                                                ConnectionMode = ConnectionMode.Gateway
                                            });
            }
            else
            {
                throw new ArgumentNullException(nameof(options), "UseAzureCredential != true and no primary key is defined in the configuration of the Cosmos DB notification service.");
            }
            if (!isInitialized)
            {
                lock (initLock)
                {
                    if (!isInitialized)
                    {
                        CreateDatabaseAndContainerIfNotExistsAsync().Wait();
                        isInitialized = true;
                    }
                }
            }
            else
            {
                database = _cosmosClient.GetDatabase(_repositoryServiceOptions.CosmosDb.DatabaseName);
                container = database.GetContainer(_repositoryServiceOptions.CosmosDb.CollectionName);
            }
        }
        #endregion

        #region Public Methods
        /// <summary>
        /// Reads a Document from the Azure DocumentDB database service as an asynchronous operation.
        /// </summary>
        /// <param name="id">Document id</param>
        /// <returns>A Task that wraps the T entity retrieved.</returns>
        public async Task<T> GetByIdAsync(string id)
        {
            try
            {
                // Note that Reads require a partition key to be specified.
                ItemResponse<T> response = await container.ReadItemAsync<T>(
                    partitionKey: new PartitionKey(id),
                    id: id);

                // Log the diagnostics
                _logger.LogInformation($"Diagnostics for ReadItemAsync: {response.Diagnostics}");

                // You can measure the throughput consumed by any operation by inspecting the RequestCharge property
                _logger.LogInformation("Item read by Id {0}", response.Resource);
                _logger.LogInformation("Request Units Charge for reading a Item by Id {0}", response.RequestCharge);

                return response.Resource;
            }
            catch (CosmosException e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.GetItem,
                                 e,
                                 $"An error occurred: StatusCode=[{e.StatusCode}] Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
            catch (Exception e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.GetItem,
                                e,
                                $"An error occurred: Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
        }

        /// <summary>
        /// Reads all the documents in the document collection.
        /// </summary>
        /// <returns>A Task that wraps a collection of T entities.</returns>
        public async Task<IEnumerable<T>> GetAllAsync()
        {
            try
            {
                List<T> items = new List<T>();
                using (FeedIterator<T> resultSet = container.GetItemQueryIterator<T>(
                    queryDefinition: null,
                    requestOptions: new QueryRequestOptions()
                    {
                        MaxConcurrency = 1
                    }))
                {
                    while (resultSet.HasMoreResults)
                    {
                        FeedResponse<T> response = await resultSet.ReadNextAsync();
                        if (!response.Any())
                        {
                            break;
                        }
                        T sale = response.First();
                        
                        if (response.Diagnostics != null)
                        {
                            _logger.LogInformation($" Diagnostics {response.Diagnostics}");
                        }

                        items.AddRange(response);
                    }
                }

                return await Task.FromResult<IEnumerable<T>>(items);
            }
            catch (CosmosException e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.ListItems,
                                 e,
                                 $"An error occurred: StatusCode=[{e.StatusCode}] Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
            catch (Exception e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.ListItems,
                                e,
                                $"An error occurred: Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
        }

        /// <summary>
        /// Creates a Document as an asychronous operation in the Azure DocumentDB database service.
        /// </summary>
        /// <param name="entity">The entity to create</param>
        /// <returns>A task.</returns>
        public async Task CreateAsync(T entity)
        {
            try
            {
                if (entity == null)
                {
                    throw new ArgumentNullException(nameof(entity), "The entity cannot null.");
                }

                ItemResponse<T> response = await container.CreateItemAsync(
                    entity,
                    new PartitionKey(entity.Id),
                    new ItemRequestOptions()
                    {
                        // The response will have a null resource. This avoids the overhead of 
                        // sending the item back over the network and serializing it.
                        EnableContentResponseOnWrite = false
                    });
            }
            catch (CosmosException e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.GetItem,
                                 e,
                                 $"An error occurred: StatusCode=[{e.StatusCode}] Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
            catch (Exception e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.GetItem,
                                e,
                                $"An error occurred: Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
        }

        /// <summary>
        /// Updates a Document as an asychronous operation in the Azure DocumentDB database service.
        /// </summary>
        /// <param name="entity">The entity to update</param>
        /// <returns>A task.</returns>
        public async Task UpdateAsync(T entity)
        {
            try
            {
                if (entity == null)
                {
                    throw new ArgumentNullException(nameof(entity), "The entity cannot null.");
                }

               ItemResponse<T> response = await container.UpsertItemAsync(
                   partitionKey: new PartitionKey(entity.Id),
                   item: entity);
            }
            catch (CosmosException e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.GetItem,
                                 e,
                                 $"An error occurred: StatusCode=[{e.StatusCode}] Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
            catch (Exception e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.GetItem,
                                e,
                                $"An error occurred: Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
        }

        /// <summary>
        /// Deletes a Document from the Azure DocumentDB database service as an asynchronous operation.
        /// </summary>
        /// <param name="id">Document id</param>
        /// <returns>A Task that wraps the T entity retrieved.</returns>
        public async Task DeleteByIdAsync(string id)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(id))
                {
                    throw new ArgumentNullException(nameof(id), "The id cannot null or empty.");
                }
                ResponseMessage response = await container.DeleteItemStreamAsync(
                    partitionKey: new PartitionKey(id),
                    id: id);
            }
            catch (CosmosException e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.GetItem,
                                 e,
                                 $"An error occurred: StatusCode=[{e.StatusCode}] Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
            catch (Exception e)
            {
                var baseException = e.GetBaseException();
                _logger.LogError(LoggingEvents.GetItem,
                                e,
                                $"An error occurred: Message=[{e.Message}] BaseException=[{baseException?.Message ?? "NULL"}]");
                throw;
            }
        }
        #endregion

        #region Private Instance Fields
        private async Task CreateDatabaseAndContainerIfNotExistsAsync()
        {
            database = await _cosmosClient.CreateDatabaseIfNotExistsAsync(_repositoryServiceOptions.CosmosDb.DatabaseName);

            // We create a partitioned collection here which needs a partition key. Partitioned collections
            // can be created with very high values of provisioned throughput (up to Throughput = 250,000)
            // and used to store up to 250 GB of data. You can also skip specifying a partition key to create
            // single partition collections that store up to 10 GB of data.
            // For this demo, we create a collection to store SalesOrders. We set the partition key to the account
            // number so that we can retrieve all sales orders for an account efficiently from a single partition,
            // and perform transactions across multiple sales order for a single account number. 
            ContainerProperties containerProperties = new ContainerProperties(_repositoryServiceOptions.CosmosDb.CollectionName, partitionKeyPath: "/id");

            // Create with a throughput of 1000 RU/s
            container = await database.CreateContainerIfNotExistsAsync(
                containerProperties,
                throughput: 1000);
        }
        #endregion
    }
}
