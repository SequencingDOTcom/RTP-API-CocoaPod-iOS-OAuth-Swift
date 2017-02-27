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
	
		```pod 'sequencing-oauth-api-swift', '~> 2.1.0'```
		
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


* **Use authorization method**
	
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
			
	* for authorization you need to specify your application parameters in String format (BEFORE using authorization methods)
		```
		let CLIENT_ID: String		= "your CLIENT_ID here"
		let CLIENT_SECRET: String	= "your CLIENT_SECRET here"
		let REDIRECT_URI: String    = "REDIRECT_URI here"
		let SCOPE: String           = "SCOPE here"
		```		
		
	* register these parameters into OAuth module instance
		```
		self.oauthApiHelper.registrateApplicationParametersCliendID(CLIENT_ID,
													clientSecret:CLIENT_SECRET,
													redirectUri:REDIRECT_URI,
													scope:SCOPE)
		```
			
	* subscribe your class for Authorization protocol	
		```
		SQAuthorizationProtocol
		```
		
	* subscribe your class as delegate for such protocol	
		```
		SQOAuth.sharedInstance().authorizationDelegate = self
		```
		
	* implement methods for SQAuthorizationProtocol	
		```
		func userIsSuccessfullyAuthorized(_ token: SQToken) -> Void { }
    
    	func userIsNotAuthorized() -> Void { }
    
	    func userDidCancelAuthorization() -> Void { }
		```
	
	* in method ```userIsSuccessfullyAuthorized``` you'll receive the SQToken object:		
			```	
			accessToken:	String
			expirationDate:	NSDate
			tokenType:		String
			scope:			String
			refreshToken:	String
			```
		
	* you can authorize your user now (e.g. via "login" button). For authorization you can use ```authorizeUser``` method. You can get access via shared instance of SQOAuth class)	
		Related method from SQAuthorizationProtocol will be called as a result
		```
		SQOAuth.sharedInstance().authorizeUser()
		```		
    		
    * if you want to use original sequencing icon for login button add ```Assets.xcassets``` into ```Copy Bundle Resources``` in project settings
    	- select project name
    	- select project target
    	- open ```Build Phases``` tab
    	- expand ```Copy Bundle Resources``` phase
    	- click ```Add Items``` button (plus icon)
    	- click ```Add Other``` button
    	- open your project folder
    	- open ```Pods``` subfolder
    	- open ```sequencing-oauth-api-swift``` subfolder
    	- open ```Resources``` subfolder
    	- select ```Assets.xcassets``` file



* **Access to up-to-date token**
		
	* to receive up-to-date token use related method from SQOAuth API (it returns the updated token): 
		```
		SQOAuth.sharedInstance().token { (token) in
			// your code
        }
		```

    		
* **Create account methods**
			
	* subscribe your class for SignUp protocol
		```
		SQSignUpProtocol
		```
	
	* subscribe your class as delegate for such protocol
		```
		SQOAuth.sharedInstance().signUpDelegate = self
		```
		
	* implement methods for successful account registration and failed registration
		```
		func emailIsRegisteredSuccessfully() { }
    
	    func emailIsNotRegistered(_ errorMessage: String!) { }
		```
		
	* registrate new account with email address
		```
		SQOAuth.sharedInstance().registrateNewAccount(forEmailAddress: "yourEmailAddress")
		```


* **Reset password methods**
			
	* subscribe your class for Reset password protocol
		```
		SQResetPasswordProtocol
		```
	
	* subscribe your class as delegate for such protocol
		```
		SQOAuth.sharedInstance().resetPasswordDelegate = self
		```
		
	* implement methods for successful reset password request and failed request
		```
		func applicationForPasswordResetIsAccepted() { }
    
	    func application(forPasswordResetIsNotAccepted errorMessage: String!) { }
		```
		
	* send request for password reset with email address
		```
		SQOAuth.sharedInstance().resetPassword(forEmailAddress: "email")
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
