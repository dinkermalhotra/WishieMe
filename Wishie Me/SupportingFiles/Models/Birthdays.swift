import ObjectMapper
import UIKit

class Birthdays: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        birthDate <- map[WSResponseParams.WS_RESP_PARAM_BIRTH_DATE]
        birthDay <- map[WSResponseParams.WS_RESP_PARAM_BIRTHDAY]
        daysLeft <- map[WSResponseParams.WS_RESP_PARAM_DAYS_LEFT]
        email <- map[WSResponseParams.WS_RESP_PARAM_EMAIL]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
        image <- map[WSResponseParams.WS_RESP_PARAM_IMAGE]
        isSelected = false
        firstName <- map[WSResponseParams.WS_RESP_PARAM_FIRST_NAME]
        friend <- map[WSResponseParams.WS_RESP_PARAM_FRIEND]
        label <- map[WSResponseParams.WS_RESP_PARAM_LABELS]
        lastName <- map[WSResponseParams.WS_RESP_PARAM_LAST_NAME]
        mobile <- map[WSResponseParams.WS_RESP_PARAM_MOBILE]
        note <- map[WSResponseParams.WS_RESP_PARAM_NOTE]
        turnedAge <- map[WSResponseParams.WS_RESP_PARAM_TURNED_AGE]
        type <- map[WSResponseParams.WS_RESP_PARAM_TYPE]
    }
    
    var description: String {
        get {
            return Mapper().toJSONString(self, prettyPrint: false)!
        }
    }
    
    let transform = TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
        // transform value from String? to Int?
        return Int(value!)
    }, toJSON: { (value: Int?) -> String? in
        // transform value from Int? to String?
        if let value = value {
            return String(value)
        }
        return nil
    })
    
    lazy var birthDate = String()
    lazy var birthDay = String()
    lazy var daysLeft = Int()
    lazy var email = String()
    lazy var firstName = String()
    var friend: UserProfile?
    lazy var id = Int()
    lazy var image = String()
    var isSelected = Bool()
    lazy var label = [Labels]()
    lazy var lastName = String()
    lazy var mobile = String()
    lazy var note = String()
    var turnedAge: Int?
    lazy var type = String()
}

// MARK: - RECENT
class RECENT: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        birthDate <- map[WSResponseParams.WS_RESP_PARAM_BIRTH_DATE]
        birthDay <- map[WSResponseParams.WS_RESP_PARAM_BIRTHDAY]
        daysLeft <- map[WSResponseParams.WS_RESP_PARAM_DAYS_LEFT]
        email <- map[WSResponseParams.WS_RESP_PARAM_EMAIL]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
        image <- map[WSResponseParams.WS_RESP_PARAM_IMAGE]
        isSelected = false
        firstName <- map[WSResponseParams.WS_RESP_PARAM_FIRST_NAME]
        friend <- map[WSResponseParams.WS_RESP_PARAM_FRIEND]
        label <- map[WSResponseParams.WS_RESP_PARAM_LABELS]
        lastName <- map[WSResponseParams.WS_RESP_PARAM_LAST_NAME]
        mobile <- map[WSResponseParams.WS_RESP_PARAM_MOBILE]
        note <- map[WSResponseParams.WS_RESP_PARAM_NOTE]
        turnedAge <- map[WSResponseParams.WS_RESP_PARAM_TURNED_AGE]
        type <- map[WSResponseParams.WS_RESP_PARAM_TYPE]
    }
    
    var description: String {
        get {
            return Mapper().toJSONString(self, prettyPrint: false)!
        }
    }
    
    let transform = TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
        // transform value from String? to Int?
        return Int(value!)
    }, toJSON: { (value: Int?) -> String? in
        // transform value from Int? to String?
        if let value = value {
            return String(value)
        }
        return nil
    })
    
    lazy var birthDate = String()
    lazy var birthDay = String()
    lazy var daysLeft = Int()
    lazy var email = String()
    lazy var firstName = String()
    var friend: UserProfile?
    lazy var id = Int()
    lazy var image = String()
    var isSelected = Bool()
    lazy var label = [Labels]()
    lazy var lastName = String()
    lazy var mobile = String()
    lazy var note = String()
    var turnedAge: Int?
    lazy var type = String()
}
