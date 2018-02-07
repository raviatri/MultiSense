//
//  Keys.swift
//  MultiSense
//
//  Created by RAVI SHARMA on 05/02/18.
//  Copyright © 2018 RAVI SHARMA. All rights reserved.
//

import Foundation
import UIKit

var DEVICE_WIDTH:            CGFloat{return UIScreen.main.bounds.width}
var DEVICE_HEIGHT:           CGFloat{return UIScreen.main.bounds.height}
var CORNER_RADIUS:           CGFloat{return 4.0}
var storyBoard:              UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
var REQUEST_URL:             NSString{return"https://www.googleapis.com/customsearch/v1?cx=012627040779741890965%3Awsq_xsxrtnc&searchType=image&key=AIzaSyBMcch-v9mgtiKkL48jHxEBeow0D85KHyQ"}

/*
 * IMAGES USED IN THE APP
 */
var IMAGE_PLACEHOLDER =       UIImage(named: "placeholder")


/*
 * ALl Keys to parse Data
 */
var KEY_ITEMS:                NSString{return "items"}
var KEY_LINK:                 NSString{return "link"}
var KEY_TITLE:                NSString{return "title"}
var KEY_IMAGE_DATA:           NSString{return "image"}
var KEY_IMAGE_BYTE_SIZE:      NSString{return "byteSize"}
var KEY_IMAGE_HEIGHT:         NSString{return "height"}
var KEY_IMAGE_WIDTH:          NSString{return "width"}
var KEY_QUERIES:              NSString{return "queries"}
var KEY_NEXT_PAGE:            NSString{return "nextPage"}
var KEY_START_INDEX:          NSString{return "startIndex"}
var KEY_TOTAL_RESULTS:        NSString{return "totalResults"}



		
