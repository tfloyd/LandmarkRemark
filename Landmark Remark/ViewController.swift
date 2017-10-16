//
//  ViewController.swift
//  Landmark Remark
//
//  Created by Jeff Tabios on 13/10/2017.
//  Copyright © 2017 Jeff Tabios. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController,CLLocationManagerDelegate,UISearchBarDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var keyword: String?
    var username: String? = "JeffreyT"
    var currentLocation: CLLocationCoordinate2D?
    var userNote: String?
    
    var usernameText: UITextField?
    var noteText: UITextField?
    
    var refNotes: FIRDatabaseReference!
    
    
    //========================================================================
    /* On Start */
    //========================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Instantiate location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Ask for a username
        showUsernameAlert()
        
        FIRApp.configure()
        
        refNotes = FIRDatabase.database().reference().child("notes")
        
        searchNotes()
    }
    
    //========================================================================
    /* Username Functions */
    //========================================================================
    
    func showUsernameAlert(){
        
        //Create alert view to ask for user name
        let usernameAlert = UIAlertController(title: "Enter Username", message: "Letters and numbers only", preferredStyle: .alert)
        
        //Add text field to alert
        usernameAlert.addTextField(configurationHandler: setUsernameField)
        
        //Delegate after adding field to alert box to get field events
        usernameText?.delegate=self
        
        //Add ok action
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: self.okUsernameHandler)
        
        usernameAlert.addAction(okAction)
        
        //Show alert box
        present(usernameAlert, animated: true)
        
    }
    
    func setUsernameField(textfield: UITextField!){
        usernameText = textfield
        usernameText?.placeholder = "Enter Username"
    }
    
    func okUsernameHandler(alert: UIAlertAction){
        
        username =  usernameText?.text
        
        //Force ask username
        if username != "" {
            
            self.dismiss(animated: true, completion: nil)
            
            //Find current location
            showCurrentLocation()
            
        }else{
            
            //If no username then keep asking for one
            showUsernameAlert()
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterSet = CharacterSet.alphanumerics
        
        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        return true
        
    }
    
    //========================================================================
    /* User Location Functions */
    //========================================================================
    
    @IBAction func showUserLocation(_ sender: Any) {
        
        //Trigger user location update
        
        showCurrentLocation()
    }
    
    func showCurrentLocation()
    {
        if currentLocation != nil{
            
            //Zoom in to users current region
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1,0.1)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(currentLocation!, span)
            mapView.setRegion(region,animated:true)
            
            //Display blue dot
            self.mapView.showsUserLocation = true
            
            //Remove any search keyword filters
            keyword = nil
            
            //Refresh annotations
            searchNotes()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locations = locations[0]
        
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locations.coordinate.latitude,locations.coordinate.longitude)
        
        //Update users current location
        currentLocation = location
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed:" + error.localizedDescription)
    }
    
    
    //========================================================================
    /* Place Note Annotation Function */
    //========================================================================
    
    func placeNote( username:String, note: String, location: CLLocationCoordinate2D ){
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location
        annotation.title = username
        annotation.subtitle  = note
        mapView.addAnnotation(annotation)
        
    }
    
    func clearNotes(){
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations(annotations)
    }
    
    //========================================================================
    /* Search Notes Functions  */
    //========================================================================
    
    @IBAction func searchButton(_ sender: Any) {
        
        //Show search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController,animated: true,completion: nil)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Show Activity Indicator
        activityIndicator.startAnimating()
        
        //Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Search for notes with the keyword
        keyword = searchBar.text
        searchNotes()
        
    }
    
    func searchNotes()
    {
        
        //Get notes from database
        refNotes.observe(.value, with: { (snapshot) in
            if(snapshot.childrenCount>0){
                
                var keywordFoundOnce = false
                
                //Remove all annotations
                self.clearNotes()
                
                //for each note create annotation
                for note in (snapshot.children.allObjects as?[FIRDataSnapshot])!
                {
                    let noteObject = note.value as? [String: AnyObject]
                    
                    let username = noteObject?["username"]! as! String
                    let usernote = noteObject?["usernote"]! as! String
                    let latitude = Double(noteObject?["latitude"]! as! String)
                    let longitude = Double(noteObject?["longitude"]! as! String)
                    
                    //let noteid = noteObject?["id"]
                    
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                    
                    //If a keyword is set then find matching items (case-insensitive)
                    var keywordFound = false
                    if (self.keyword != nil ){
                        if(username.lowercased().range(of: self.keyword!.lowercased()) != nil || usernote.lowercased().range(of: self.keyword!.lowercased()) != nil ){
                            keywordFound = true
                            keywordFoundOnce = true
                        }
                    }
                    
                    //Place item
                    if (self.keyword == nil || self.keyword == "" || keywordFound) {
                        self.placeNote(username: username, note: usernote, location: location)
                    }
                    
                }
                
                //Zoom into found results
                if(keywordFoundOnce){
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                }
                
                //print(self.keyword!)
                
            }
            
            //hide activityIndicator
            self.activityIndicator.stopAnimating()
        })
        
    }
    
    
    //========================================================================
    /* Add Note Functions  */
    //========================================================================
    
    @IBAction func showNotePrompt(_ sender: Any) {
        showCurrentLocation()
        showNoteAlert()
    }
    
    func showNoteAlert(){
        //Create alert view to ask for user note
        let noteAlert = UIAlertController(title: "Leave A Note", message: "Leave a short note on your current location", preferredStyle: .alert)
        
        //Add text field to alert
        noteAlert.addTextField(configurationHandler: setNoteField)
        
        //Add ok and cancel action
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: self.okNoteHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        noteAlert.addAction(okAction)
        noteAlert.addAction(cancelAction)
        
        //Show alert box
        present(noteAlert, animated: true)
    }
    
    func setNoteField(textfield: UITextField!){
        noteText = textfield
        noteText?.placeholder = "Type short note here"
    }
    
    func okNoteHandler(alert: UIAlertAction){
        
        userNote = noteText!.text!
        
        if userNote != "" {
            
            //Zoom to users current location to see the note
            placeNote(username: username!, note: userNote!, location: currentLocation!)
            
            //Save note to DB
            saveNote()
            
            //Remove any search keyword filters
            keyword = nil
            
        }
        
    }
    
    func saveNote()
    {
        let key = refNotes.childByAutoId().key
        
        let latitude = String(describing: currentLocation!.latitude)
        let longitude = String(describing:currentLocation!.longitude)
        
        let note = ["id": key,
                    "username":username,
                    "usernote":userNote,
                    "latitude":latitude,
                    "longitude":longitude
        ]
        
        //Save to Firebase
        refNotes.child(key).setValue(note)
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

