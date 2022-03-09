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

namespace TodoApi.Models
{
    /// <summary>
    /// This class contains the configuration for the Service Bus
    /// </summary>
    public class ServiceBus
    {
        /// <summary>
        /// Gets or sets the fully qualified name of the Service Bus namespace.
        /// </summary>
        public string Namespace { get; set; }

        /// <summary>
        /// Gets or sets the value of the connection string of the Service Bus namespace.
        /// </summary>
        public string ConnectionString {get; set;}

        /// <summary>
        /// Gets or sets the name of the queue used for notifications.
        /// </summary>
        public string QueueName { get; set; }

        /// <summary>
        /// Gets or sets a value that indicate whether use Azure Identity to authenticate with Cosmos DB.
        /// </summary>
        public string UseAzureCredential { get; set; }
    }
}
