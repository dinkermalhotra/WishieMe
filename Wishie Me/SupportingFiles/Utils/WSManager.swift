import Foundation
import Alamofire
import ObjectMapper

class WSManager {
        
    static var _settings: SettingsManager?
    
    static var settings: SettingsManagerProtocol?
    {
        if let _ = WSManager._settings {
        }
        else {
            WSManager._settings = SettingsManager()
        }

        return WSManager._settings
    }
    
    static let header = ["Accept": "application/json"]
    static var authorizationHeader: HTTPHeaders = ["Authorization": "Bearer \(settings?.accessToken ?? "")", "Accept": "application/json"]
    
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    // MARK: - LABELS
    class func wsCallCreateLabels(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String, _ arrLabels: [Labels]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.createLabels, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let result = responseValue[WSResponseParams.WS_RESP_PARAM_LABEL] as? [[String: Any]] {
                        if let labels = Mapper<Labels>().mapArray(JSONArray: result) as [Labels]? {
                            completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", labels)
                        } else {
                            completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                        }
                    }
                    else {
                        if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                            if let label = error[WSResponseParams.WS_RESP_PARAM_LABEL] {
                                completion(false, label.firstObject as? String ?? "", [])
                            }
                            else {
                                completion(false, "", [])
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil)
        }
    }
    
    class func wsCallDeleteLabels(_ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.createLabels)/\(requestValue)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallEditLabels(_ requestParams: [String: AnyObject], _ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.createLabels)/\(requestValue)", method: .put, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallEmptylabel(_ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.emptyLabel)/\(requestValue)", method: .put, parameters: nil, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallGetBirthdays(completion:@escaping (_ isSuccess: Bool, _ message: String, _ arrBirthdays: [Birthdays]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.getBirthdays, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let result = responseValue[WSResponseParams.WS_RESP_PARAM_BIRTHDAYS] as? [[String: Any]] {
                        if let birthdays = Mapper<Birthdays>().mapArray(JSONArray: result) as [Birthdays]? {
                            completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", birthdays)
                        } else {
                            completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                        }
                    }
                    else {
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil)
        }
    }
    
    class func wsCallGetLabels(completion:@escaping (_ isSuccess: Bool, _ message: String, _ arrLabels: [Labels]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.createLabels, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let result = responseValue[WSResponseParams.WS_RESP_PARAM_LABELS] as? [[String: Any]] {
                        if let labels = Mapper<Labels>().mapArray(JSONArray: result) as [Labels]? {
                            completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", labels)
                        } else {
                            completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                        }
                    }
                    else {
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil)
        }
    }
    
    class func wsCallMoveBirthdays(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.moveBirthday, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    // MARK: - LOGIN SIGNUP
    class func wsCallLogin(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.login, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let user = responseValue[WSResponseParams.WS_RESP_PARAM_USER] as? [String: AnyObject] {
                        UserData.clear()
                        if let accessToken = responseValue[WSResponseParams.WS_RESP_PARAM_ACCESS_TOKEN] as? String {
                            self.settings?.accessToken = accessToken
                            
                            self.authorizationHeader = ["Authorization": "Bearer \(settings?.accessToken ?? "")", "Accept": "application/json"]
                        }
                        
                        if let email = user[WSResponseParams.WS_RESP_PARAM_EMAIL] as? String {
                            self.settings?.email = email
                        }
                        
                        if let firstName = user[WSResponseParams.WS_RESP_PARAM_FIRST_NAME] as? String {
                            self.settings?.firstName = firstName
                        }
                        
                        if let lastName = user[WSResponseParams.WS_RESP_PARAM_LAST_NAME] as? String {
                            self.settings?.lastName = lastName
                        }
                        
                        if let phone = user[WSResponseParams.WS_RESP_PARAM_PHONE] as? String {
                            self.settings?.phone = phone
                        }
                        
                        if let profileImage = user[WSResponseParams.WS_RESP_PARAM_PROFILE_IMAGE] as? String {
                            self.settings?.profileImage = profileImage
                        }

                        if let userId = user[WSResponseParams.WS_RESP_PARAM_ID] as? Int {
                            self.settings?.userId = userId
                        }
                        
                        if let username = user[WSResponseParams.WS_RESP_PARAM_USERNAME] as? String {
                            self.settings?.username = username
                        }
                        
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                            if let phone = error[WSResponseParams.WS_RESP_PARAM_PHONE] {
                                completion(false, phone.firstObject as? String ?? "")
                            }
                            else if let username = error[WSResponseParams.WS_RESP_PARAM_USERNAME] {
                                completion(false, username.firstObject as? String ?? "")
                            }
                            else if let password = error[WSResponseParams.WS_RESP_PARAM_PASSWORD] {
                                completion(false, password.firstObject as? String ?? "")
                            }
                            else if let image = error[WSResponseParams.WS_RESP_PARAM_PROFILE_IMAGE] {
                                completion(false, image.firstObject as? String ?? "")
                            }
                            else {
                                completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallRegister(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.register, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let user = responseValue[WSResponseParams.WS_RESP_PARAM_USER] as? [String: AnyObject] {
                        UserData.clear()
                        if let accessToken = responseValue[WSResponseParams.WS_RESP_PARAM_ACCESS_TOKEN] as? String {
                            self.settings?.accessToken = accessToken
                            
                            self.authorizationHeader = ["Authorization": "Bearer \(settings?.accessToken ?? "")", "Accept": "application/json"]
                        }
                        
                        if let email = user[WSResponseParams.WS_RESP_PARAM_EMAIL] as? String {
                            self.settings?.email = email
                        }
                        
                        if let firstName = user[WSResponseParams.WS_RESP_PARAM_FIRST_NAME] as? String {
                            self.settings?.firstName = firstName
                        }
                        
                        if let lastName = user[WSResponseParams.WS_RESP_PARAM_LAST_NAME] as? String {
                            self.settings?.lastName = lastName
                        }
                        
                        if let phone = user[WSResponseParams.WS_RESP_PARAM_PHONE] as? String {
                            self.settings?.phone = phone
                        }
                        
                        if let profileImage = user[WSResponseParams.WS_RESP_PARAM_PROFILE_IMAGE] as? String {
                            self.settings?.profileImage = profileImage
                        }

                        if let userId = user[WSResponseParams.WS_RESP_PARAM_ID] as? Int {
                            self.settings?.userId = userId
                        }
                        
                        if let username = user[WSResponseParams.WS_RESP_PARAM_USERNAME] as? String {
                            self.settings?.username = username
                        }
                        
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                            if let phone = error[WSResponseParams.WS_RESP_PARAM_PHONE] {
                                completion(false, phone.firstObject as? String ?? "")
                            }
                            else if let username = error[WSResponseParams.WS_RESP_PARAM_USERNAME] {
                                completion(false, username.firstObject as? String ?? "")
                            }
                            else if let password = error[WSResponseParams.WS_RESP_PARAM_PASSWORD] {
                                completion(false, password.firstObject as? String ?? "")
                            }
                            else if let image = error[WSResponseParams.WS_RESP_PARAM_PROFILE_IMAGE] {
                                completion(false, image.firstObject as? String ?? "")
                            }
                            else {
                                completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallRefreshToken(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.refreshToken, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallSocialAuth(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.socialAuth, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let user = responseValue[WSResponseParams.WS_RESP_PARAM_USER] as? [String: AnyObject] {
                        UserData.clear()
                        if let accessToken = responseValue[WSResponseParams.WS_RESP_PARAM_ACCESS_TOKEN] as? String {
                            self.settings?.accessToken = accessToken
                            
                            self.authorizationHeader = ["Authorization": "Bearer \(settings?.accessToken ?? "")", "Accept": "application/json"]
                        }
                        
                        if let email = user[WSResponseParams.WS_RESP_PARAM_EMAIL] as? String {
                            self.settings?.email = email
                        }
                        
                        if let firstName = user[WSResponseParams.WS_RESP_PARAM_FIRST_NAME] as? String {
                            self.settings?.firstName = firstName
                        }
                        
                        if let lastName = user[WSResponseParams.WS_RESP_PARAM_LAST_NAME] as? String {
                            self.settings?.lastName = lastName
                        }
                        
                        if let phone = user[WSResponseParams.WS_RESP_PARAM_PHONE] as? String {
                            self.settings?.phone = phone
                        }
                        
                        if let profileImage = user[WSResponseParams.WS_RESP_PARAM_PROFILE_IMAGE] as? String {
                            self.settings?.profileImage = profileImage
                        }

                        if let userId = user[WSResponseParams.WS_RESP_PARAM_ID] as? Int {
                            self.settings?.userId = userId
                        }
                        
                        if let username = user[WSResponseParams.WS_RESP_PARAM_USERNAME] as? String {
                            self.settings?.username = username
                        }
                        
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                            if let phone = error[WSResponseParams.WS_RESP_PARAM_PHONE] {
                                completion(false, phone.firstObject as? String ?? "")
                            }
                            else if let username = error[WSResponseParams.WS_RESP_PARAM_USERNAME] {
                                completion(false, username.firstObject as? String ?? "")
                            }
                            else if let password = error[WSResponseParams.WS_RESP_PARAM_PASSWORD] {
                                completion(false, password.firstObject as? String ?? "")
                            }
                            else if let image = error[WSResponseParams.WS_RESP_PARAM_PROFILE_IMAGE] {
                                completion(false, image.firstObject as? String ?? "")
                            }
                            else {
                                completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallSocialLogin(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.socialLogin, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let user = responseValue[WSResponseParams.WS_RESP_PARAM_USER] as? [String: AnyObject] {
                        UserData.clear()
                        if let accessToken = responseValue[WSResponseParams.WS_RESP_PARAM_ACCESS_TOKEN] as? String {
                            self.settings?.accessToken = accessToken
                            
                            self.authorizationHeader = ["Authorization": "Bearer \(settings?.accessToken ?? "")", "Accept": "application/json"]
                        }
                        
                        if let email = user[WSResponseParams.WS_RESP_PARAM_EMAIL] as? String {
                            self.settings?.email = email
                        }
                        
                        if let firstName = user[WSResponseParams.WS_RESP_PARAM_FIRST_NAME] as? String {
                            self.settings?.firstName = firstName
                        }
                        
                        if let lastName = user[WSResponseParams.WS_RESP_PARAM_LAST_NAME] as? String {
                            self.settings?.lastName = lastName
                        }
                        
                        if let phone = user[WSResponseParams.WS_RESP_PARAM_PHONE] as? String {
                            self.settings?.phone = phone
                        }
                        
                        if let profileImage = user[WSResponseParams.WS_RESP_PARAM_PROFILE_IMAGE] as? String {
                            self.settings?.profileImage = profileImage
                        }

                        if let userId = user[WSResponseParams.WS_RESP_PARAM_ID] as? Int {
                            self.settings?.userId = userId
                        }
                        
                        if let username = user[WSResponseParams.WS_RESP_PARAM_USERNAME] as? String {
                            self.settings?.username = username
                        }
                        
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallUsername(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.username, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallValidatePhone(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.validatePhone, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    // MARK: - BIRTHDAY
    class func wsCallCreateBirthday(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.createBirthday, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallGetBirthday(completion:@escaping (_ isSuccess: Bool, _ message: String, _ recents: [RECENT]?, _ birthdays: [Birthdays]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.dashboard, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in

                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    var recent = [[String: Any]]()
                    var birthday = [[String: Any]]()

                    if let recents = responseValue[WSResponseParams.WS_RESP_PARAM_RECENT] as? [[String: Any]] {
                        recent = recents
                    }
                    if let birthdays = responseValue[WSResponseParams.WS_RESP_PARAM_BIRTHDAYS] as? [[String: Any]] {
                        birthday = birthdays
                    }

                    completion(true, "", Mapper<RECENT>().mapArray(JSONArray: recent), Mapper<Birthdays>().mapArray(JSONArray: birthday))
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil, nil)
        }
    }
    
    class func wsCallDeleteBirthday(_ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.deleteBirthday)/\(requestValue)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallEditBirthday(_ requestParams: [String: AnyObject], _ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.editBirthday)/\(requestValue)", method: .put, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    // MARK: - NOTIFICATIONS
    class func wsCallGetNotifications(completion:@escaping (_ isSuccess: Bool, _ message: String, _ notifications: [String: [Notifications]]?, _ jsonData: Data?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.notifications, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: responseValue, options: .prettyPrinted)
                        
                        if let notifications = NotificationResponse.init(JSON: responseValue), let result = notifications.results {
                            completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", result, jsonData)
                        }
                        else {
                            completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil, nil)
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil, nil)
        }
    }
    
    // MARK: - PROFILE
    class func wsCallGetProfile(completion:@escaping (_ isSuccess: Bool, _ message: String, _ profile: Profile?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.profile, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let result = responseValue[WSResponseParams.WS_RESP_PARAM_USER_DETAILS] as? [String: Any] {
                        if let profile = Mapper<Profile>().map(JSON: result) as Profile? {
                            completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", profile)
                        } else {
                            completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                        }
                    }
                    else {
                        if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                            if let label = error[WSResponseParams.WS_RESP_PARAM_LABEL] {
                                completion(false, label.firstObject as? String ?? "", nil)
                            }
                            else {
                                completion(false, "", nil)
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil)
        }
    }
    
    class func wsCallEditProfile(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String, _ profile: Profile?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.profile, method: .put, parameters: requestParams, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let result = responseValue[WSResponseParams.WS_RESP_PARAM_USER] as? [String: Any] {
                        if let profile = Mapper<Profile>().map(JSON: result) as Profile? {
                            completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", profile)
                        } else {
                            completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                        }
                    }
                    else {
                        if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                            if let label = error[WSResponseParams.WS_RESP_PARAM_LABEL] {
                                completion(false, label.firstObject as? String ?? "", nil)
                            }
                            else {
                                completion(false, "", nil)
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil)
        }
    }
    
    // MARK: - REMINDERS
    class func wsCallCreateBirthdayReminder(_ requestValue: Int, _ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.editBirthdayReminders)/\(requestValue)", method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallCreateReminder(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.createReminder, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallDeleteBirthdayReminder(_ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.editBirthdayReminders)/\(requestValue)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallDeleteReminder(_ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.createReminder)/\(requestValue)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallEditBirthdayReminder(_ requestParams: [String: AnyObject], _ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.editBirthdayReminders)/\(requestValue)", method: .put, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallEditReminder(_ requestParams: [String: AnyObject], _ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.createReminder)/\(requestValue)", method: .put, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallEnableDisableReminder(_ requestValue: Int, _ isEnable: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.createReminder)/\(requestValue)/\(isEnable)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallEnableDisableBirthdayReminder(_ requestValue: Int, _ requestparams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.enableDisableReminder)/\(requestValue)", method: .put, parameters: requestparams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallGetBirthdayReminders(_ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String, _ arrReminders: [Reminder]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.birthdayReminders)/\(requestValue)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in

                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let result = responseValue[WSResponseParams.WS_RESP_PARAM_REMINDERS] as? [[String: Any]] {
                        if let reminders = Mapper<Reminder>().mapArray(JSONArray: result) as [Reminder]? {
                            completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", reminders)
                        } else {
                            completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                        }
                    }
                    else {
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil)
        }
    }
    
    class func wsCallGetReminders(completion:@escaping (_ isSuccess: Bool, _ message: String, _ arrReminders: [Reminders]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.getReminders, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let result = responseValue[WSResponseParams.WS_RESP_PARAM_REMINDERS] as? [[String: Any]] {
                        if let reminders = Mapper<Reminders>().mapArray(JSONArray: result) as [Reminders]? {
                            completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", reminders)
                        } else {
                            completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                        }
                    }
                    else {
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil)
        }
    }
    
    class func wsCallResetReminder(completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.remindersReset, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    // MARK: - ADD FRIEND REQUEST
    class func wsCallSearchUser(_ searchText: String, completion:@escaping (_ isSuccess: Bool, _ message: String, _ response: [UserProfile]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.searchUser)/\(searchText)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", [])
                    }
                    else {
                        if let users = responseValue[WSResponseParams.WS_RESP_PARAM_USERS] as? [[String: Any]] {
                            if let profile = Mapper<UserProfile>().mapArray(JSONArray: users) as [UserProfile]? {
                                completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", profile)
                            } else {
                                completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, [])
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, [])
        }
    }
    
    class func wsCallFriends(_ searchText: String, completion:@escaping (_ isSuccess: Bool, _ message: String, _ response: [UserProfile]?)->()) {
        if isConnectedToInternet() {
            var request = ""
            if searchText.isEmpty {
                request = WebService.friends
            }
            else {
                request = "\(WebService.friends)/\(searchText)"
            }
            Alamofire.request(request, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", [])
                    }
                    else {
                        if let users = responseValue[WSResponseParams.WS_RESP_PARAM_USERS] as? [[String: Any]] {
                            if let profile = Mapper<UserProfile>().mapArray(JSONArray: users) as [UserProfile]? {
                                completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", profile)
                            } else {
                                completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, [])
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, [])
        }
    }
    
    class func wsCallGetFriendRequest(completion:@escaping (_ isSuccess: Bool, _ message: String, _ sendByMe: [UserProfile]?, _ sendToMe: [UserProfile]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.friendRequests, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", [], [])
                    }
                    else {
                        var sentToMes = [[String: Any]]()
                        var sendByMes = [[String: Any]]()

                        if let sendByMe = responseValue[WSResponseParams.WS_RESP_PARAM_SEND_BY_ME] as? [[String: Any]] {
                            sendByMes = sendByMe
                        }
                        if let sentToMe = responseValue[WSResponseParams.WS_RESP_PARAM_SENT_TO_ME] as? [[String: Any]] {
                            sentToMes = sentToMe
                        }

                        completion(true, "", Mapper<UserProfile>().mapArray(JSONArray: sendByMes), Mapper<UserProfile>().mapArray(JSONArray: sentToMes))
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, [], [])
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, [], [])
        }
    }
    
    class func wsCallSendFriendRequest(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.sendFriendRequest, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallAcceptRejectRequest(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.acceptRejectRequest, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallCancelFriendRequest(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.cancelFriendRequest, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallUnfriendUser(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.unfriend, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    // MARK: - VIDEO
    class func wsCallUploadVideo(_ data: Data, _ imageString: String, _ typeOfWishie: String, completion:@escaping (_ isSuccess: Bool, _ response: String, _ videoId: Int, _ message: String)->()) {
        if isConnectedToInternet() {
            let timestamp = NSDate().timeIntervalSince1970 // just for some random name.
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data, withName: "video", fileName: "\(timestamp).mp4", mimeType: "video/mp4")
                multipartFormData.append(imageString.data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data(), withName: "thumbnail")
                multipartFormData.append(typeOfWishie.data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data(), withName: "type_of_wishie")
            }, to: WebService.uploadVideo, method: .post, headers: authorizationHeader) { (encodingResult) in
                
                switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { responseData in
                            if let responseValue = responseData.result.value as? [String: AnyObject] {
                                if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                                    print(errors)
                                    completion(false, "", 0, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                                }
                                else {
                                    completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_VIDEO] as? String ?? "", responseValue[WSResponseParams.WS_RESP_PARAM_VIDEO_ID] as? Int ?? 0, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                                }
                            }
                            else {
                                completion(false, "", 0, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                            }
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        completion(false, "", 0, encodingError.localizedDescription)
                }
            }
        }
        else {
            completion(false, "", 0, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallSaveVideo(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.saveVideo, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallShareVideo(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.shareVideo, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallGetSavedWishies(completion:@escaping (_ isSuccess: Bool, _ message: String, _ drafts: [Videos]?, _ received: [Videos]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.videos, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", [], [])
                    }
                    else {
                        var drafts = [[String: Any]]()
                        var receiveds = [[String: Any]]()

                        if let draft = responseValue[WSResponseParams.WS_RESP_PARAM_DRAFTED_VIDEOS] as? [[String: Any]] {
                            drafts = draft
                        }
                        if let received = responseValue[WSResponseParams.WS_RESP_PARAM_SAVED_VIDEOS] as? [[String: Any]] {
                            receiveds = received
                        }

                        completion(true, "", Mapper<Videos>().mapArray(JSONArray: drafts), Mapper<Videos>().mapArray(JSONArray: receiveds))
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, [], [])
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, [], [])
        }
    }
    
    class func wsCallGetFeeds(completion:@escaping (_ isSuccess: Bool, _ message: String, _ drafts: [Videos]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.feeds, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", [])
                    }
                    else {
                        if let feeds = responseValue[WSResponseParams.WS_RESP_PARAM_FEEDS] as? [[String: Any]] {
                            if let profile = Mapper<Videos>().mapArray(JSONArray: feeds) as [Videos]? {
                                completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", profile)
                            } else {
                                completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, [])
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, [])
        }
    }
    
    class func wsCallLikeVideo(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.likeVideo, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallPostComment(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String, _ comment: Comments?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.postComment, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                    }
                    else {
                        if let comment = responseValue[WSResponseParams.WS_RESP_PARAM_COMMENT] as? [String: AnyObject] {
                            if let comment = Mapper<Comments>().map(JSON: comment) as Comments? {
                                completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", comment)
                            }
                        }
                        else {
                            completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, nil)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, nil)
        }
    }
    
    class func wsCallDeleteComment(_ requestValue: Int, completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request("\(WebService.deleteComment)/\(requestValue)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    // MARK: - BLOCK/UNBLOCK
    class func wsCallBlockUnblockUser(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.blockUnblockUser, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
    
    class func wsCallBlockList(completion:@escaping (_ isSuccess: Bool, _ message: String, _ response: [UserProfile]?)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.blockedFriends, method: .get, parameters: nil, encoding: URLEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let error = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(error)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", [])
                    }
                    else {
                        if let users = responseValue[WSResponseParams.WS_RESP_PARAM_USERS] as? [[String: Any]] {
                            if let profile = Mapper<UserProfile>().mapArray(JSONArray: users) as [UserProfile]? {
                                completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", profile)
                            } else {
                                completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "", nil)
                            }
                        }
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT, [])
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET, [])
        }
    }
    
    class func wsCallReportUser(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        if isConnectedToInternet() {
            Alamofire.request(WebService.reportUser, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: authorizationHeader).responseJSON(completionHandler: {(responseData) -> Void in
                
                print(responseData.result)
                if let responseValue = responseData.result.value as? [String: AnyObject] {
                    if let errors = responseValue[WSResponseParams.WS_RESP_PARAM_ERRORS] as? [String: AnyObject] {
                        print(errors)
                        completion(false, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                    else {
                        completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                    }
                }
                else {
                    completion(false, responseData.result.error?.localizedDescription ?? AlertMessages.INCORRECT_DATA_FORMAT)
                }
            })
        }
        else {
            completion(false, AlertMessages.NO_INTERNET)
        }
    }
}
