# AvatarsAPI

All URIs are relative to *https://api.gravatar.com/v3*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAvatars**](AvatarsAPI.md#getavatars) | **GET** /me/avatars | List avatars
[**setEmailAvatar**](AvatarsAPI.md#setemailavatar) | **POST** /me/avatars/{imageId}/email | Set avatar for the hashed email
[**uploadAvatar**](AvatarsAPI.md#uploadavatar) | **POST** /me/avatars | Upload new avatar image


# **getAvatars**
```swift
    open class func getAvatars(selectedEmailHash: String? = nil, completion: @escaping (_ data: [Avatar]?, _ error: Error?) -> Void)
```

List avatars

Retrieves a list of available avatars for the authenticated user.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import GravatarOpenAPIClient

let selectedEmailHash = "selectedEmailHash_example" // String | The sha256 hash of the email address used to determine which avatar is selected. The 'selected' attribute in the avatar list will be set to 'true' for the avatar associated with this email. (optional) (default to "null")

// List avatars
AvatarsAPI.getAvatars(selectedEmailHash: selectedEmailHash) { (response, error) in
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
 **selectedEmailHash** | **String** | The sha256 hash of the email address used to determine which avatar is selected. The &#39;selected&#39; attribute in the avatar list will be set to &#39;true&#39; for the avatar associated with this email. | [optional] [default to &quot;null&quot;]

### Return type

[**[Avatar]**](Avatar.md)

### Authorization

[oauth](../README.md#oauth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setEmailAvatar**
```swift
    open class func setEmailAvatar(imageId: String, setEmailAvatarRequest: SetEmailAvatarRequest, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Set avatar for the hashed email

Sets the avatar for the provided email hash.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import GravatarOpenAPIClient

let imageId = "imageId_example" // String | Image ID of the avatar to set as the provided hashed email avatar.
let setEmailAvatarRequest = setEmailAvatar_request(emailHash: "emailHash_example") // SetEmailAvatarRequest | Avatar selection details

// Set avatar for the hashed email
AvatarsAPI.setEmailAvatar(imageId: imageId, setEmailAvatarRequest: setEmailAvatarRequest) { (response, error) in
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
 **imageId** | **String** | Image ID of the avatar to set as the provided hashed email avatar. | 
 **setEmailAvatarRequest** | [**SetEmailAvatarRequest**](SetEmailAvatarRequest.md) | Avatar selection details | 

### Return type

Void (empty response body)

### Authorization

[oauth](../README.md#oauth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadAvatar**
```swift
    open class func uploadAvatar(data: URL, completion: @escaping (_ data: Avatar?, _ error: Error?) -> Void)
```

Upload new avatar image

Uploads a new avatar image for the authenticated user.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import GravatarOpenAPIClient

let data = URL(string: "https://example.com")! // URL | The avatar image file

// Upload new avatar image
AvatarsAPI.uploadAvatar(data: data) { (response, error) in
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
 **data** | **URL** | The avatar image file | 

### Return type

[**Avatar**](Avatar.md)

### Authorization

[oauth](../README.md#oauth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

