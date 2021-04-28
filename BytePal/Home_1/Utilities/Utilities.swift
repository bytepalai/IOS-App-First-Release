//
//  Utilities.swift
//  BytePal
//
//  Created by Zain Haider on 14/02/2021.
//  Copyright © 2021 BytePal-AI. All rights reserved.
//

import UIKit


public class Utilities: NSObject {
    
    
    static func openLink(urlString: String) {
        guard let url  = URL(string: urlString) else {return}
        guard UIApplication.shared.canOpenURL(url) else {return}
        UIApplication.shared.open(url, options: [:])
    }
}


