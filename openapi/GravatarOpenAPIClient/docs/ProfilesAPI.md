# ProfilesAPI

All URIs are relative to *https://api.gravatar.com/v3*

Method | HTTP request | Description
------------- | ------------- | -------------
[**associatedEmail**](ProfilesAPI.md#associatedemail) | **GET** /me/associated-email | Check if the email is associated with the authenticated user
[**getProfileById**](ProfilesAPI.md#getprofilebyid) | **GET** /profiles/{profileIdentifier} | Get profile by identifier


# **associatedEmail**
```swift
    open class func associatedEmail(emailHash: String, completion: @escaping (_ data: AssociatedResponse?, _ error: Error?) -> Void)
```

Check if the email is associated with the authenticated user

Checks if the provided email address is associated with the authenticated user.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let emailHash = "emailHash_example" // String | The hash of the email address to check.

// Check if the email is associated with the authenticated user
ProfilesAPI.associatedEmail(emailHash: emailHash) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **emailHash** | **String** | The hash of the email address to check. | 

### Return type

[**AssociatedResponse**](AssociatedResponse.md)

### Authorization

[oauth](../README.md#oauth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getProfileById**
```swift
    open class func getProfileById(profileIdentifier: String, completion: @escaping (_ data: Profile?, _ error: Error?) -> Void)
```

Get profile by identifier

Returns a profile by the given identifier.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let profileIdentifier = "profileIdentifier_example" // String | This can either be an SHA256 hash of an email address or profile URL slug.

// Get profile by identifier
ProfilesAPI.getProfileById(profileIdentifier: profileIdentifier) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileIdentifier** | **String** | This can either be an SHA256 hash of an email address or profile URL slug. | 

### Return type

[**Profile**](Profile.md)

### Authorization

[apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

