/*
 Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at

 http://aws.amazon.com/apache2.0

 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */
 

import Foundation
import AWSCore

 
public class DTToken : AWSModel {
    
    /** Grant Type (authorization_code) */
    var grantType: String!
    /** Client ID */
    var clientId: String!
    /** Client Secret */
    var clientSecret: String!
    /** Redirect Callback */
    var redirectUri: String!
    /** Access Code from authorization */
    var code: String!
    
   	public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]!{
		var params:[AnyHashable : Any] = [:]
		params["grantType"] = "grant_type"
		params["clientId"] = "client_id"
		params["clientSecret"] = "client_secret"
		params["redirectUri"] = "redirect_uri"
		params["code"] = "code"
		
        return params
	}
}
