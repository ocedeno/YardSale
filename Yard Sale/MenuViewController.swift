//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit
import Firebase

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /**
     *  Array to display menu options
     */
    @IBOutlet var tblMenuOptions : UITableView!
    
    /**
     *  Transparent button to hide menu
     */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
     *  Array containing menu options
     */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
     *  Menu button which was tapped to display the menu
     */
    var btnMenu : UIButton!
    
    /**
     *  Delegate of the MenuVC
     */
    var delegate : SlideMenuDelegate?
    var profileImage = UIImage.greenGrassBackground()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblMenuOptions.tableFooterView = UIView()
        
        let blurredBackgroundView = BlurredBackgroundView(frame: .zero)
        tblMenuOptions.backgroundView = blurredBackgroundView
        tblMenuOptions.separatorEffect = UIVibrancyEffect(blurEffect: blurredBackgroundView.blurView.effect as! UIBlurEffect)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        populateProfileImage()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateProfileImage()
        updateArrayMenuOptions()
    }
    
    func updateArrayMenuOptions(){
        arrayMenuOptions.append(["title":(FIRAuth.auth()?.currentUser?.displayName)!, "icon":"HomeIcon"])
        arrayMenuOptions.append(["title":"Home", "icon":"HomeIcon"])
        arrayMenuOptions.append(["title":"Profile", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title": "Sign-Out", "icon": "PlayIcon"])
        
        tblMenuOptions.reloadData()
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        if indexPath.row != 0
        {
            imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
            lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        	lblTitle.textColor = UIColor.white
        }else
        {
            populateProfileImage()
            imgIcon.image = profileImage
            lblTitle.text = arrayMenuOptions[0]["title"]
            lblTitle.textColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        self.onCloseMenuClick(btn)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenuOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

class BlurredBackgroundView: UIView {
    let imageView: UIImageView
    let blurView: UIVisualEffectView
    
    override init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .light)
        blurView = UIVisualEffectView(effect: blurEffect)
        imageView = UIImageView(image: UIImage.greenGrassBackground())
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(blurView)
        sendSubview(toBack: blurView)
        sendSubview(toBack: imageView)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect.zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        blurView.frame = bounds
    }
}

extension MenuViewController
{
    func createProfileImageStorageReference() -> FIRStorageReference
    {
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("userProfile")
        let profileImageRef = imageRef.child((FIRAuth.auth()?.currentUser?.uid)!)
        
        return profileImageRef
    }
    
    func populateProfileImage()
    {
        let ref = self.createProfileImageStorageReference()
        ref.child("profileImage").data(withMaxSize: 3 * 1024 * 1024) { (data, error) in
            
            guard error == nil else { return }
            
            if let data = data
            {
                self.profileImage = UIImage(data: data)!
                self.tblMenuOptions.reloadData()
            }
        }
    }
    
    
}

