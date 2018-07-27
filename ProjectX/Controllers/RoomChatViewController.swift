//
//  RoomChatViewController.swift
//  ProjectX
//
//  Created by BrangerBriz Felipe on 2/05/18.
//  Copyright © 2018 BrangerBriz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RoomChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var user:User? = nil
    var prefixUser: String?
    var roomRefHandle: DatabaseHandle?
    lazy var ref: DatabaseReference = Database.database().reference().child("mychat")
    var rooms: [Room] = [Room]()
    
    @IBOutlet weak var uitableview: UITableView!
    @IBOutlet weak var nameRoomtextfield: UITextField!
    @IBOutlet weak var bienvenidoRoomtext: UILabel!
    
    
    override func viewDidLoad() {
       super.viewDidLoad()
       updateName()
       observeRooms()
    }
    
    func updateName() {
        if let anonym = user?.isAnonymous , anonym {
            bienvenidoRoomtext.text = "Welcome Anonymous"
            self.ref.child("users").child((user?.uid)!).setValue(["name": "anonymous"])
            prefixUser = "anonymous"
        } else if let phone = user?.phoneNumber{
            bienvenidoRoomtext.text = "Welcome \(String(describing: phone))"
            self.ref.child("users").child((user?.uid)!).setValue(["name": "phone"])
            prefixUser = "phone"
        }else if let name = user?.displayName{
            bienvenidoRoomtext.text = "Welcome \(String(describing: name))"
            self.ref.child("users").child((user?.uid)!).setValue(["name": name])
             prefixUser = name
        }else if let email = user?.isEmailVerified, email{
            bienvenidoRoomtext.text = "Welcome \(String(describing: user?.email))"
            self.ref.child("users").child((user?.uid)!).setValue(["name": user?.email])
            prefixUser = user?.email
        }
        
    }

    deinit {
        if let refHandle = roomRefHandle {
            ref.removeObserver(withHandle: refHandle)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBar.isHidden = false
        }
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    // MARK: Firebase related methods
    private func observeRooms() {
     
        roomRefHandle = ref.child("rooms").queryOrderedByKey().observe(DataEventType.value, with: { (snapshot) in
            self.rooms.removeAll()
            let roomData = snapshot.value as? [String : AnyObject] ?? [:]
            for (key, value) in roomData{
                
                if let dicroom = value as? [String : AnyObject], let name = dicroom["name"] as? String{
                    
                    self.rooms.append(Room(id: key, name: name))
                }
            }
            self.uitableview.reloadData()
        })
    }

    @IBAction func createRoom(_ sender: Any) {
        if let name = nameRoomtextfield.text , name.count > 0 {

            let newRoomRef = ref.child("rooms").childByAutoId()
            let roomItem = [
                "name": name
            ]
            newRoomRef.setValue(roomItem)
            nameRoomtextfield.text = ""
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "unwindToSocialViewcontrollerWithSegue", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }

}

extension RoomChatViewController{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "basicCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = rooms[(indexPath as NSIndexPath).row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
        let room = rooms[(indexPath as NSIndexPath).row]
        vc.room = room
        vc.user = user
        vc.prefixUser = prefixUser
        if let user = user{
           self.ref.child("users").child(user.uid).child("rooms").updateChildValues(["\(room.id)":true])
           self.ref.child("rooms").child(room.id).child("users").updateChildValues(["\(user.uid)": true])
        }
        navigationController?.pushViewController(vc,animated: true)
    }
    
}
