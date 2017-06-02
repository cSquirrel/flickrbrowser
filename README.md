# How To
The project uses RxSwift Cocoapods.
Please navigate to FlickrBrowser folder and run the following command

    $> pod install



# Status

Implementation decisions:

* the app is limited to displaying the feed and few details about each picture and enables "open in browser" and "share" actions
* the app covers "happy path" scenario with minimal error handling. If there's any problem with loading the feed data an alert is displayed to the user
* there's no complex image cache implemented. Just in-memory storage is used in this version. ImagesProvider allows for easy extension of the caching policy and using filesystem for cache storage 


The app uses simple UI made of three screens:

 * main screen; table view displaying pictures loaded form the feed
 * details screen; displaying the picture zoomed in and two actions available: "open in external browser" and "share"
 * loading screen; UI feedback used when the app loads data from the server. 

There are three main layers in the app:

 * network service; covers HTTP communication
 * api service; encapsulates details of Flickr API
 * UI; utilises api service and uses the view model