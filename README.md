## CreDA Protocol

#CreDA API Description
Request address 
https://contracts-elamain.creda.app/api/public/home/token/generate

#Request method 
GET

#Request parameters 

|Header Parameter|Data Type|Required|Description|
| ------ | ------ | ------ | ------ |
|access_token|string|yes||
|Query Parameter|Data Type|Required|Description|
| ------ | ------ | ------ | ------ |
|address|string|yes|address informatin|

#Return parameters

|Parameter Name|Data Type|Description|
| ------ | ------ | ------ |
| code | integer | Return code 200 is success |
| message | string | "success" or reason for failure |
| data | Object | Data Object |


data Object
| Parameter Name | Data Type | Description |
| ------ | ------ | ------ |
| score | Array | socre object |
| timestamp | string | score timestamp |

score array item description
| Attribute Name | Data Type | Description |
| ------ | ------ | ------ |
| itemName | string | name of score item |
| value | string | score value |


#Example Return Value

     {
        "code": 200,
        "message": "SUCCESS",
        "data": {
        "score":[
                {
                    "itemName":"assets",
                    "value":100
                },
                {
                    "itemName":"activities",
                    "value":100
                },
                {
                    "itemName":"risk",
                    "value":100
                },
                {
                    "itemName":"credit",
                    "value":100
                }
            ]
        }
    }










