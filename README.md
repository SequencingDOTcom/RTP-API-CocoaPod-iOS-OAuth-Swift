# CocoaPods plugin for quickly adding Sequencing.com's OAuth2 to iOS apps coded in Swift

=========================================
This repo contains CocoaPods plugin code for implementing Sequencing.com's OAuth2 authentication for your Swift iOS app so that your app can securely access [Sequencing.com's](https://sequencing.com/) API and app chains.

* oAuth flow is explained [here](https://github.com/SequencingDOTcom/OAuth2-code-with-demo)
* Example that uses this Pod is located [here](https://github.com/SequencingDOTcom/OAuth2-code-with-demo/tree/master/swift)

Contents
=========================================
* Cocoa Pod integration
* Resources
* Maintainers
* Contribute

Cocoa Pod integration
======================================

Please follow instruction below if you want to install and use OAuth logic in your existed or new project.

* **Create a new project in Xcode**

* **Install pod**

	* see [CocoaPods guides](https://guides.cocoapods.org/using/using-cocoapods.html)
	* create Podfile in your project directory: ```$ pod init```
	* don't forget to uncomment the row (as this is Swift pod) ```use_frameworks!```
	* specify "sequencing-oauth-api-swift" pod parameters:
	
		```pod 'sequencing-oauth-api-swift', '~> 2.5.0'```
		
	* install the dependency in your project: ```$ pod install```
	* always open the Xcode workspace instead of the project file: ```$ open *.xcworkspace```

* **Add Application Transport Security setting**
	* open project settings > Info tab
	* add ```App Transport Security Settings``` row parameter (as Dictionary)
	* add subrow to App Transport Security Settings parameter as ```Exception Domains``` dictionary parameter
	* add subrow to Exception Domains parameter with ```sequencing.com``` string value
	* add subrow to App Transport Security Settings parameter with ```Allow Arbitrary Loads``` boolean value
	* set ```Allow Arbitrary Loads``` boolean value as ```YES```
	
	![sample files](https://github.com/SequencingDOTcom/CocoaPod-iOS-OAuth-ObjectiveC/blob/master/Screenshots/authTransportSecuritySetting.png)


* **Register framework to use in Swift code**
	
	* first of all you need to create bridging header file. Select File > New > File > Header File > name it as
		```
		project-name-Bridging-Header.h
		```

	* add SQOAuthFramework class import in the bridging header file
		```
		#import <OAuth/SQOAuthFramework.h>
		```

	* register your bridging header file in the project settings.
		select your project > project target > Build Settings > Objective-C Bridging Header
		specify path for bridging header file
		```
		$(PROJECT_DIR)/project-name-Bridging-Header.h
		```
			
* **Register app parameters and delegate**

	* subscribe your class for Authorization protocol
		```
		SQAuthorizationProtocol
		```

	* have access to SQOAuth via ```shared instance``` method
		```
		SQOAuth.sharedInstance()
		```
		
	* register your app parameters and delegate
		```
		SQOAuth.sharedInstance().registerApplicationParametersCliendID(client_id,
                                                                       clientSecret: client_secret,
                                                                       redirectUri: redirect_uri,
                                                                       scope: scope,
                                                                       delegate: self)
    	```
    	
    	where:
    	```                                                            
		client_id - your app CLIENT_ID
		client_secret - your app CLIENT_SECRET
		redirect_uri - your app REDIRECT_URI
		scope - your app SCOPE
		delegate - UIViewController instance that conform to "SQAuthorizationProtocol" protocol
		```		


* **Use authorization method**			
		
	* implement methods from SQAuthorizationProtocol	
		```
		func userIsSuccessfullyAuthorized(_ token: SQToken) -> Void { }
    
    	func userIsNotAuthorized() -> Void { }
    
	    func userDidCancelAuthorization() -> Void { }
		```
	
	* you can authorize your user via ```authorizeUser``` method
		```
		SQOAuth.sharedInstance().authorizeUser()
		```
	
	* in method ```userIsSuccessfullyAuthorized``` you'll receive the SQToken object:		
		```	
		accessToken:	String
		expirationDate:	NSDate
		tokenType:		String
		scope:			String
		refreshToken:	String
		```			


* **Access to up-to-date token**
		
	* to receive up-to-date token use related method from SQOAuth API (it returns the updated token): 
		```
		SQOAuth.sharedInstance().token { (token) in
		}
		```


* **Register new account / Reset password methods**
    				
	* just call ```callRegisterResetAccountFlow``` method - it will open dialog popup
		```
		SQOAuth.sharedInstance().callRegisterResetAccountFlow()
		```




Resources
======================================
* [App chains](https://sequencing.com/app-chains)
* [File selector code](https://github.com/SequencingDOTcom/File-Selector-code)
* [Developer center](https://sequencing.com/developer-center)
* [Developer documentation](https://sequencing.com/developer-documentation/)

Maintainers
======================================
This repo is actively maintained by [Sequencing.com](https://sequencing.com/). Email the Sequencing.com bioinformatics team at gittaca@sequencing.com if you require any more information or just to say hola.

Contribute
======================================
We encourage you to passionately fork us. If interested in updating the master branch, please send us a pull request. If the changes contribute positively, we'll let it ride.
