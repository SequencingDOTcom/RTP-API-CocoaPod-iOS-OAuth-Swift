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
	
		```pod 'sequencing-oauth-api-swift', '~> 2.0.0'```
		
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
	* **create View Controllers, e.g. for Login view and for SelectFile view**
	
	* **in your LoginViewController class:**
	
		* first of all you need to create bridging header file.
		Select File > New > File > Header File > name it as
		
			```
			project-name-Bridging-Header.h
			```

		* add AppChains class import in the bridging header file

			```
			#import <AppChainsLibrary/AppChains.h>
			```

		* register your bridging header file in the project settings.
			select your project > project target > Build Settings > Objective-C Bridging Header
			specify path for bridging header file

			```
			$(PROJECT_DIR)/project-name-Bridging-Header.h
			```
		
		* add property for SQOAuth class
		
			```
			let oauthApiHelper = SQOAuth()
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
			self.oauthApiHelper.authorizationDelegate = self
			```
		
		* add methods for SQAuthorizationProtocol
		
			```
			func userIsSuccessfullyAuthorized(_ token: SQToken) -> Void {
				DispatchQueue.main.async {
					print("user Is Successfully Authorized")
					// your code is here for successful user authorization
				}
    		}
    		
    		func userIsNotAuthorized() -> Void {
				DispatchQueue.main.async {
	    			print("user is not authorized")
	    			// your code is here for unsuccessful user authorization
	    		}
	    	}
	    	

			func userDidCancelAuthorization() -> Void {
				DispatchQueue.main.async {
					// your code is here for abandoned user authorization			
				}
			}
			```
		
		* you can authorize your user now (e.g. via "login" button). For authorization you can use ```authorizeUser``` method. You can get access via shared instance of SQOAuth class)
		
			```
			self.oauthApiHelper.authorizeUser()
			```
			
			Related method from SQAuthorizationProtocol will be called as a result
		
		* example of Login button (you can use ```@"button_signin_black"``` image that is included into the Pod within ```AuthImages.xcassets```)

			```			
    		// set up loginButton
	        let loginButton = UIButton(type: UIButtonType.custom)
    	    loginButton.setImage(UIImage(named: "button_signin_white_gradation"), for: UIControlState())
        	loginButton.addTarget(self, action: #selector(self.loginButtonPressed), for: UIControlEvents.touchUpInside)
	        loginButton.sizeToFit()
    	    loginButton.translatesAutoresizingMaskIntoConstraints = false
        	self.view.addSubview(loginButton)
	        self.view.bringSubview(toFront: loginButton)
        
	        // adding constraints for loginButton
    	    let xCenter = NSLayoutConstraint.init(item: loginButton,
        	                                      attribute: NSLayoutAttribute.centerX,
            	                                  relatedBy: NSLayoutRelation.equal,
                	                              toItem: self.view,
                    	                          attribute: NSLayoutAttribute.centerX,
                        	                      multiplier: 1,
                            	                  constant: 0)
	        let yCenter = NSLayoutConstraint.init(item: loginButton,
    	                                          attribute: NSLayoutAttribute.centerY,
        	                                      relatedBy: NSLayoutRelation.equal,
            	                                  toItem: self.view,
                	                              attribute: NSLayoutAttribute.centerY,
                    	                          multiplier: 1,
                        	                      constant: 0)
	        self.view.addConstraint(xCenter)
    	    self.view.addConstraint(yCenter)
    		```
    	
    	* example of ```loginButtonPressed``` method
    	 
    		```
    		func loginButtonPressed() {
     	   		self.view.isUserInteractionEnabled = false
	        	self.oauthApiHelper.authorizeUser()
    		}
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
		
		* add segue in Storyboard from LoginViewController to MainViewController with identifier ```SELECT_FILES```
		
		* add constant for segue id
			```let SELECT_FILES_CONTROLLER_SEGUE_ID = "SELECT_FILES"```
		
		* example of navigation methods when user is authorized (token object will be passed on to the SelectFileViewController)
		
			```
			func userIsSuccessfullyAuthorized(_ token: SQToken) -> Void {
		        DispatchQueue.main.async {
			        print("user Is Successfully Authorized")
    	        	self.view.isUserInteractionEnabled = true
	    	        self.performSegue(withIdentifier: self.SELECT_FILES_CONTROLLER_SEGUE_ID, sender: token)
		        }
		    }
			
			override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		        if segue.destination.isKind(of: SelectFileViewController.self) {
        		    if sender != nil {
                		let destinationVC = segue.destination as! SelectFileViewController
	        	        destinationVC.token = sender as! SQToken?
    		        }
		        }
		    }
			```

	* **in your SelectFileViewController class:**
						
		* subscribe your class for these protocols
		
			```
			SQTokenRefreshProtocol
			```
			
		* add property for handling Token object
		
			```
			var token: SQToken?
			```
		
		* add property for SQOAuth class
		
			```
			let oauthApiHelper = SQOAuth()
			```
			
		* subscribe your class as delegate for such protocols
		
			```
			self.oauthApiHelper.refreshTokenDelegate = self
			```
		
		* add method for SQTokenRefreshProtocol - it is called when token is refreshed
		
			```
			func tokenIsRefreshed(_ updatedToken: SQToken) -> Void {
				// your code is here to handle refreshed token    
    		}
			```
		
		* in method ```userIsSuccessfullyAuthorized``` and in method ```tokenIsRefreshed``` you'll receive the same SQToken object, that contains following 5 properties with clear titles for usage:
		
			```	
			accessToken:	String
			expirationDate:	NSDate
			tokenType:		String
			scope:			String
			refreshToken:	String
			```
		
			(!) DO NOT OVERRIDE ```refresh_token``` property for ```token``` object - it comes as ```nil``` after refresh token request.
	
	
	


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
