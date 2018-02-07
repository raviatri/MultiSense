//
//  ViewController.swift
//  MultiSense
//
//  Created by RAVI SHARMA on 05/02/18.
//  Copyright © 2018 ravisharma. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import Alamofire
import SDWebImage

class ViewController: UIViewController, LoginButtonDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fbLoginView: UIView!

    var arrFbFriends:NSMutableArray     = NSMutableArray()
    var arrFakeFriends:NSMutableArray   = NSMutableArray()
    var dictResponse:NSDictionary   = NSDictionary()
    var fakeFriends                 = ["rahul","ashish","john","maria","swati","priya","ravi"]
    
    var arrSelectedFriends:NSMutableArray   = NSMutableArray()

    var arrFrineds: NSMutableArray  = NSMutableArray()
    let identifier = "FRIEND"
    let cell_width = Double((Int(UIScreen.main.bounds.width)-46)/3)

    let width_view = UIScreen.main.bounds.width
    let height_view = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // configure UI
        self.configureUI()
        
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            // Show Friends collection view.
            
            print(accessToken)
            myFacebookFriends()
        }
        else{
            self.fbLoginView.frame = CGRect(x: 50, y: (height_view-380)/2, width: width_view-100, height: 380)
            self.fbLoginView.layer.cornerRadius = 10
            self.fbLoginView.isHidden = false
            // Add a facebook Logedin Button.
            let loginButton = LoginButton(readPermissions: [.publicProfile, .email, .userFriends])
            loginButton.delegate = self
            loginButton.center = view.center
            
            self.fbLoginView.addSubview(loginButton)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }

    // MARK: LoginButtonDelegate Methods.
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(let grantedPermissions, _, let accessToken):
            print("Loged in by facebook successfully \(grantedPermissions).")
            print(accessToken.authenticationToken)
            myFacebookFriends()
            break
        case .cancelled:
            print("facebook cancelled")
            break
            
        case .failed(let error):
            print("facebook error: \(error)")
            break
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }
    
    // Congigure UI Elements.
    func configureUI(){
        self.collectionView.frame = CGRect(x: 0, y: 0, width: width_view, height: height_view)
    }
    
    // MARK: Get Facebook Friends list.
    func myFacebookFriends(){
        
        let params = ["fields": "id, first_name, name, picture"]
        
        let graphRequest = GraphRequest(graphPath: "/me/taggable_friends", parameters: params)
        graphRequest.start {
            (urlResponse, requestResult) in
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    
                    if let friendObjects = responseDictionary["data"] as? [NSDictionary] {
                        var fbFriendsToAdd = 0
                        for friendObject in friendObjects {
                            guard fbFriendsToAdd<5 else{continue}

                            //let friend = NSMutableDictionary()

                            /*
                            if let name = friendObject["name"]{
                                print("My Frinde \(name).")
                                friend.setValue(name, forKey: "name")
                            }
                             */
                            if let picture = friendObject["picture"] as? Dictionary<String, Any> {
                                if let data = picture["data"] as? Dictionary<String, Any> {
                                    if let url_str = data["url"] as? String {
                                        self.arrFrineds.add(url_str)
                                    }
                                }
                            }
                            fbFriendsToAdd += 1
                        }
                    }
                }
                
                self.callGoogleCustomSearchAPI(strSearchText: "profilepic")
            }
        }
    }
    
    //MARK: Call Google search API to get 5 fake Friends.
    func callGoogleCustomSearchAPI(strSearchText: String) {
        // Query string to fetch fake friends from Google Search API.
        let requestString = String(format: "%@&q=%@&start=1&imgSize=small",REQUEST_URL,strSearchText)
        
        Alamofire.request(requestString).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    self.dictResponse = JSON as! NSDictionary
                    if let arr_Items = self.dictResponse.object(forKey: KEY_ITEMS) as? Array<Any>{
                        if arr_Items.count>1
                        {
                            var fakeFriendsToAdd = 0
                            for dicItem in arr_Items {
                                guard fakeFriendsToAdd<5 else{continue}
                                //let friend = NSMutableDictionary()
                                if let url_str = (dicItem as AnyObject).object(forKey: KEY_LINK)
                                {
                                    //let url = URL(string: url_str as! String)
                                    self.arrFrineds.add(url_str)

                                    //friend.setValue(url, forKey: "thumbnail")
                                }
                                /*
                                if let strName = (dicItem as AnyObject).object(forKey: KEY_TITLE)
                                {
                                    friend.setValue(strName, forKey: "name")
                                }
                                 */
                                //self.arrFrineds.add(friend)
                                fakeFriendsToAdd += 1
                            }
                        }
                    }
                   
                    //self.arrItems = NSMutableArray(array:self.dictResponse.object(forKey: KEY_ITEMS) as! NSArray)
                    print("Items ARRAY:\(self.arrFrineds)")
                    self.arrFrineds = NSMutableArray.init(array: self.arrFrineds.shuffled())
                    
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    
                    //self.actInd.stopAnimating()
                    //self.container.removeFromSuperview()
                }
                print("Validation Successful")
            case .failure(let error):
                print(error.localizedDescription)
                // create the alert
                let alert = UIAlertController(title: "MultiSense", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
               // self.present(alert, animated: true, completion: nil)
//                self.actInd.stopAnimating()
//                self.container.removeFromSuperview()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK:- UICollectionView DataSource

extension ViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrFrineds.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,for:indexPath) as! FriendCollectionViewCell
        cell.backgroundColor = UIColor.clear
        
        //let dic_friend  = self.arrFrineds.object(at: indexPath.item)
        let url_Img = self.arrFrineds.object(at: indexPath.item)
            let url = URL(string: url_Img as! String)
            //cell.imgVw_friend.frame = CGRect(x: 0, y: 0, width: cell_width, height: cell_width)
            cell.imgVw_friend.sd_setImage(with: url, placeholderImage: IMAGE_PLACEHOLDER, options:SDWebImageOptions.retryFailed){(image, error, cacheType, imageURL) -> Void in
                // completion code here
                if (error != nil){
                    print(error!)
                }
                //print("\(NSDate())>>> \(#function) indexPath:[\(indexPath.row)]>>>>>> imagedownloaded <<<<<<<<")
                if image != nil{
                    //cell.imgVw_friend.image = image
                }
            }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            headerView.backgroundColor = UIColor.clear;
            let lbl_header = UILabel()
            lbl_header.frame = CGRect(x: 0, y: 20, width: cell_width*3, height: 20.0)
            lbl_header.backgroundColor = UIColor.clear
            lbl_header.textColor = UIColor.lightGray
            lbl_header.text = "FRIENDS"
           
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            footerView.frame = CGRect.zero
            footerView.isHidden = true
            return footerView
        }
    }
}

// MARK:- UICollectionViewDelegate Methods
extension ViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.arrFrineds.count>indexPath.item else{return}
        
        // Add freind to selected friend collection.
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //highlightCell(indexPath, flag: false)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    // MARK:- UICollectioViewDelegateFlowLayout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: cell_width,height: cell_width);
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width:self.view.frame.size.width, height: 45)
    }
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
