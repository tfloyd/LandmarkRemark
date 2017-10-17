Landmark Remark
by Jeffrey Tabios

This iOS app allows the user to leave notes on their current location, search for notes in the world map and view their current location as well as notes from other users. 

Usage:
- On start of app, you may be asked for app permission to use your location, choose “Allow”
- Create a username and press Ok
- The app automatically zooms in to your current location
- Choose the “My Location” button whenever you wish to go to your current location

Leaving notes:
- To leave a note, tap “Leave a Note” button
- The app automatically zooms in to your current location and opens an pop-up with a field
- Type in your short note and choose Ok
- A pin annotation is added on the location with the short message

Searching for notes:
- Choose the magnifying glass on the top right and the search bar appears
- Type the keyword you would like to search for
- If found, the screen zooms in to show all pins (notes) that match the keyword

How To Run in Xcode (Mac):
- Download a copy from this repository
- Open terminal and go to the app directory
- Run ‘pod install’ to install all dependencies
- Open the .xcworkspace file that is created and run

Teck Stack:
Frameworks used is MapKit, CoreLocation and Firebase (by Google)
Firebase is used for data persistence and comply with the implicit requirements
Development time is 8-9hours total

About the code:
All codes are added into the ViewController.swift file.
Codes are well commented and are clearly divided into 6 categories via boxed comments namely:
- On Start
- Username Functions
- User Location Functions
- Note Placement Annotation Functions
- Search Notes Functions
- Add Note Functions

Known issues:
- A warning may appear regarding Firebase library.
- This app uses up battery-life faster as it is retrieves location from GPS or Wifi which ever is available
