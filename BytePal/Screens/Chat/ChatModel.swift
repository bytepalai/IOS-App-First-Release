//
//  ChatModel.swift
//  BytePal
//
//  Created by Scott Hom on 8/4/20.
//  Copyright © 2020 BytePal-AI. All rights reserved.
//

import Foundation

// User information meta data
class UserInformation: ObservableObject {
    @Published var id: String = ""
    @Published var email: String = ""
    @Published var givenName: String = ""
    @Published var familyName: String = ""
    @Published var fullName: String = ""
    @Published var messagesLeft: Int = 0
    @Published var isLoggedIn: Bool = false
}
