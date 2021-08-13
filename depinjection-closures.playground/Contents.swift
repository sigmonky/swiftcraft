import UIKit
import XCTest

struct LoggedInUser {
    let name: String
}

class LoginViewController: UIViewController {
    var login: (((LoggedInUser) -> Void) -> Void)?
    var user: String?
    func didTapLoginButton() {
        guard let login = self.login else {
            user = nil
            return
        }
        login { [weak self] user in
            self?.user = user.name
        }
    }
    
    func showUser() {
        print(user ?? "unknown")
    }
}

let loginVC = LoginViewController()
let user = LoggedInUser(name: "randy")

loginVC.login = { completion in
    completion(user)
}
loginVC.didTapLoginButton()
loginVC.showUser()
XCTAssertTrue(loginVC.user == "randy", "user value has wrong setting")

loginVC.login = { completion in
    completion(LoggedInUser(name:"second user"))
}
loginVC.didTapLoginButton()
loginVC.showUser()
XCTAssertTrue(loginVC.user == "second user", "user value has wrong setting")

loginVC.login = nil
loginVC.didTapLoginButton()
loginVC.showUser()
XCTAssertTrue(loginVC.user == nil, "user value still set")


struct Person: CustomStringConvertible {
     let name: String
     
     var description: String {
        print("description request")
         return "Person name is \(name)"
     }
 }

 let isDebuggingEnabled: Bool = true

//func debugLog(_ message: String) {
//     /// You could replace this in projects with #if DEBUG
//     if isDebuggingEnabled {
//         print("[DEBUG] \(message)")
//     }
// }
//
// let person = Person(name: "Bernie")
//debugLog(person.description)
func debugLog(_ message: @autoclosure () -> String) {
     /// You could replace this in projects with #if DEBUG
     if isDebuggingEnabled {
         print("[DEBUG] \(message())")
     }
 }

let person: Person? = nil
debugLog(person?.description ?? "none")
