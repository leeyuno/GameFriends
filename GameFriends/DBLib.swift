//
//  DBLib.swift
//  GameFriends
//
//  Created by leeyuno on 2017. 9. 13..
//  Copyright © 2017년 Sface. All rights reserved.
//

import UIKit

class DBLib: NSObject {
    
    static let coreDataLIB = DBLib()
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

}
