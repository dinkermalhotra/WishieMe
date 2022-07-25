import ObjectMapper

struct NotificationResponse: Mappable {

    init?(map: Map) {}

    var results: [String: [Notifications]]?
    
    mutating func mapping(map: Map) {
        results <- map[WSResponseParams.WS_RESP_PARAM_NOTIFICATIONS]
    }
}

class Notifications: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        fromUser <- map[WSResponseParams.WS_RESP_PARAM_FROM_USER]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
        isRead <- map[WSResponseParams.WS_RESP_PARAM_IS_READ]
        notification <- map[WSResponseParams.WS_RESP_PARAM_NOTIFICATION]
        notifyDate <- map[WSResponseParams.WS_RESP_PARAM_NOTIFY_DATE]
        toUserId <- map[WSResponseParams.WS_RESP_PARAM_TO_USER_ID]
        user <- map[WSResponseParams.WS_RESP_PARAM_BIRTHDAY]
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
    
    var fromUser: UserProfile?
    var id: Int?
    var isRead: Int?
    var notification: String?
    var notifyDate: String??
    var toUserId: Int?
    var user: Birthdays?
}

