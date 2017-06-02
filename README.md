# How To
The project uses RxSwift Cocoapods.
Please navigate to FlickrBrowser folder and run the following command

    $> pod install



# Status
The app uses simple UI made of three screens:


 * main screen; table view displaying pictures loaded form the feed
 * details screen; displaying the picture zoomed in and two actions available: "open in external browser" and "share"
 * loading screen; UI feedback used when the app loads data from the server. 

There are three main layers in the app:

 * network service; covers HTTP communication
 * api service; encapsulates details of Flickr API
 * UI; utilises api service and uses the view model