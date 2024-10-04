# Profile

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**hash** | **String** | The SHA256 hash of the user&#39;s primary email address. | 
**displayName** | **String** | The user&#39;s display name. This is the name that is displayed on their profile. | 
**profileUrl** | **String** | The full URL for the user&#39;s profile. | 
**avatarUrl** | **String** | The URL for the user&#39;s avatar image if it has been set. | 
**avatarAltText** | **String** | The alt text for the user&#39;s avatar image if it has been set. | 
**location** | **String** | The user&#39;s location. | 
**description** | **String** | The about section on a user&#39;s profile. | 
**jobTitle** | **String** | The user&#39;s job title. | 
**company** | **String** | The user&#39;s current company&#39;s name. | 
**verifiedAccounts** | [VerifiedAccount] | A list of verified accounts the user has added to their profile. This is limited to a max of 4 in unauthenticated requests. | 
**pronunciation** | **String** | The phonetic pronunciation of the user&#39;s name. | 
**pronouns** | **String** | The pronouns the user uses. | 
**timezone** | **String** | The timezone the user has. This is only provided in authenticated API requests. | [optional] 
**languages** | [Language] | The languages the user knows. This is only provided in authenticated API requests. | [optional] 
**firstName** | **String** | User&#39;s first name. This is only provided in authenticated API requests. | [optional] 
**lastName** | **String** | User&#39;s last name. This is only provided in authenticated API requests. | [optional] 
**isOrganization** | **Bool** | Whether user is an organization. This is only provided in authenticated API requests. | [optional] 
**links** | [Link] | A list of links the user has added to their profile. This is only provided in authenticated API requests. | [optional] 
**interests** | [Interest] | A list of interests the user has added to their profile. This is only provided in authenticated API requests. | [optional] 
**payments** | [**ProfilePayments**](ProfilePayments.md) |  | [optional] 
**contactInfo** | [**ProfileContactInfo**](ProfileContactInfo.md) |  | [optional] 
**gallery** | [GalleryImage] | Additional images a user has uploaded. This is only provided in authenticated API requests. | [optional] 
**numberVerifiedAccounts** | **Int** | The number of verified accounts the user has added to their profile. This count includes verified accounts the user is hiding from their profile. This is only provided in authenticated API requests. | [optional] 
**lastProfileEdit** | **Date** | The date and time (UTC) the user last edited their profile. This is only provided in authenticated API requests. | [optional] 
**registrationDate** | **Date** | The date the user registered their account. This is only provided in authenticated API requests. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


