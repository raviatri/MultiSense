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
    @IBOutlet weak var lblTitle: UILabel!
    let container: UIView               = UIView()
    let actInd: UIActivityIndicatorView     = UIActivityIndicatorView()

    var arrFbFriends:NSMutableArray     = NSMutableArray()
    var arrFakeFriends:NSMutableArray   = NSMutableArray()
    var dictResponse:NSDictionary   = NSDictionary()
    var fakeFriends                 = ["rahul","ashish","john","maria","swati","priya","ravi"]
    
    var arrSelectedFriends:NSMutableArray   = NSMutableArray()

    var arrFrineds: NSMutableArray  = NSMutableArray()
    let identifier = "FRIEND"
    let cell_width = Double((Int(UIScreen.main.bounds.width)-46)/3)
    
    var triedNuberOfTimes = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Multi Sense"
        // configure UI
        self.configureUI()
        
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            // Show Friends collection view.
            
            print(accessToken)
            myFacebookFriends()
        }
        else{
            self.fbLoginView.frame = CGRect(x: 50, y: (DEVICE_HEIGHT-380)/2, width: DEVICE_WIDTH-100, height: 380)
            self.fbLoginView.layer.cornerRadius = 10
            self.fbLoginView.isHidden = false
            // Add a facebook Logedin Button.
            
            let loginButton = LoginButton(readPermissions: [.publicProfile, .email, .userFriends])
            loginButton.frame = CGRect(x: 10, y:170, width: DEVICE_WIDTH-130, height: 40)
            loginButton.delegate = self
            //loginButton.center = view.center
            
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
            self.showActivityIndicatory(uiView: self.view)
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
        self.collectionView.frame = CGRect(x: 15, y: 60, width: DEVICE_WIDTH-20, height: DEVICE_HEIGHT-20)
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
                        for friendObject in friendObjects {
                            if let picture = friendObject["picture"] as? Dictionary<String, Any> {
                                if let data = picture["data"] as? Dictionary<String, Any> {
                                    if let url_str = data["url"] as? String {
                                        self.arrFbFriends.add(url_str)
                                    }
                                }
                            }
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
                            for dicItem in arr_Items {
                                if let url_str = (dicItem as AnyObject).object(forKey: KEY_LINK)
                                {
                                    self.arrFakeFriends.add(url_str)
                                }
                            }
                            self.arrFakeFriends = NSMutableArray.init(array: self.arrFakeFriends.shuffled())
                        }
                    }
                    
                    //Just shuffle the array and reload the friends view.
                    self.configureDisplayFriendsList()
                    
                    self.showAlertWith(message: "Select 3 of your friends.", action: "OK")

                    self.actInd.stopAnimating()
                    self.container.removeFromSuperview()
                }
                print("Validation Successful")
            case .failure(let error):
                print(error.localizedDescription)
                // create the alert
                let alert = UIAlertController(title: "MultiSense", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            }
        }
    }
    
    // Construt display friends list.
    func configureDisplayFriendsList()
    {
        // First empty the array.
        if self.arrFrineds.count > 0{
            self.arrFrineds.removeAllObjects()
        }
        // Shuffle facebook freinds.
        self.arrFbFriends = NSMutableArray.init(array: self.arrFbFriends.shuffled())
        // Fetch five facebook friends.
        for (index, friend) in self.arrFbFriends.enumerated(){
            print(index)
            guard index < 5 else {continue}
            self.arrFrineds.add(friend)
        }
        
        // Shuffle fake freinds.
        self.arrFakeFriends = NSMutableArray.init(array: self.arrFakeFriends.shuffled())
        // Fetch five fake friends.
        for (index, friend) in self.arrFakeFriends.enumerated(){
            print(index)
            guard index < 5 else {continue}
            self.arrFrineds.add(friend)
        }
        
        // Dispaly fake and facebook friends.
        self.shuffleAndReloadFreinds()
    }
    
    // Shuffle and reload the data.
    func shuffleAndReloadFreinds(){
        self.fbLoginView.isHidden = true
        // Empty selected friends array to play again.
        self.arrSelectedFriends.removeAllObjects()
        
        self.arrFrineds = NSMutableArray.init(array: self.arrFrineds.shuffled())
        self.collectionView.reloadData()
        self.collectionView.isHidden = false
    }
    
    // Show a Success or failure alert.
    func showAlertWith(message: String, action: String){
        let alert = UIAlertController(title: "Multi Sense", message: message, preferredStyle: UIAlertControllerStyle.alert)
        if action == "Try Again"{
            let alertAction: UIAlertAction = UIAlertAction(title: action, style: .cancel) { action -> Void in
                //Just shuffle the array and reload the friends view.
                self.configureDisplayFriendsList()
            }
            alert.addAction(alertAction)
        
        }
        else{
            let alertAction: UIAlertAction = UIAlertAction(title: action, style: .cancel) { action -> Void in
                //Just dismiss alert view.
            }
            alert.addAction(alertAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Check selected all freinds from facebook.
    func selectionOfFriendsIsRight() ->Bool{
        for friend in self.arrSelectedFriends{
            if self.arrFakeFriends.contains(friend){
                // Fake friend selected.
                return false
            }
        }
        return true
    }
    
    // MARK: Add loader when request happen
    func showActivityIndicatory(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }
    
    // UIColor from Hex.
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
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
        
        cell.imgVw_selected.isHidden = true
        cell.lbl_selected.isHidden = true
        
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
            lbl_header.textColor = UIColor.black
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
        guard self.arrSelectedFriends.count <= 3 else {return}
        
        let selectedFriend = self.arrFrineds.object(at: indexPath.item)
        
        if !self.arrSelectedFriends.contains(selectedFriend){
            // Add freind to selected friend collection.
            self.arrSelectedFriends.add(selectedFriend)
            
            // Makse freind selcted.
            if let selectedCell = collectionView.cellForItem(at: indexPath){
                (selectedCell  as! FriendCollectionViewCell).imgVw_selected.isHidden = false
                (selectedCell  as! FriendCollectionViewCell).lbl_selected.isHidden = false
            }
            if self.arrSelectedFriends.count == 3{
                self.triedNuberOfTimes += 1
                if self.selectionOfFriendsIsRight(){
                    self.showAlertWith(message: "Congratulation! you have selected right friends.", action: "Try Again")
                }
                else{
                    if self.triedNuberOfTimes > 2{
                        self.showAlertWith(message: "Failed! You failed to select your frinds.", action: "OK")
                        return
                    }
                    self.showAlertWith(message: "Sorry! selected friends are not yours. Better luck next time.", action: "Try Again")

                }
            }
        }
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
        return CGSize(width:self.view.frame.size.width, height: 40)
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
