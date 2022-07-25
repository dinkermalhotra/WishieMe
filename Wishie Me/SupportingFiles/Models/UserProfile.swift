import ObjectMapper

class UserProfile: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        bio <- map[WSResponseParams.WS_RESP_PARAM_BIO]
        userBirthday <- map[WSResponseParams.WS_RESP_PARAM_BIRTHDAY]
        dob <- map[WSResponseParams.WS_RESP_PARAM_DOB]
        email <- map[WSResponseParams.WS_RESP_PARAM_EMAIL]
        firstName <- map[WSResponseParams.WS_RESP_PARAM_FIRST_NAME]
        friendsCount <- map[WSResponseParams.WS_RESP_PARAM_FRIENDS_COUNT]
        headerImage <- map[WSResponseParams.WS_RESP_PARAM_HEADER_IMAGE]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
        isBlocked <- map[WSResponseParams.WS_RESP_PARAM_IS_BLOCKED]
        isMyFriend <- map[WSResponseParams.WS_RESP_PARAM_IS_MY_FRIEND]
        isFriendRequestReceived <- map[WSResponseParams.WS_RESP_PARAM_IS_FRIEND_REQUEST_RECEIVED]
        isFriendRequestSent <- map[WSResponseParams.WS_RESP_PARAM_IS_FRIEND_REQUEST_SENT]
        isSelected = false
        label <- map[WSResponseParams.WS_RESP_PARAM_LABELS]
        lastName <- map[WSResponseParams.WS_RESP_PARAM_LAST_NAME]
        note <- map[WSResponseParams.WS_RESP_PARAM_NOTE]
        phone <- map[WSResponseParams.WS_RESP_PARAM_PHONE]
        profileImage <- map[WSResponseParams.WS_RESP_PARAM_PROFILE_IMAGE]
        username <- map[WSResponseParams.WS_RESP_PARAM_USERNAME]
        wishieReceived <- map[WSResponseParams.WS_RESP_PARAM_WISHIE_RECEIVED]
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
    
    lazy var bio = String()
    lazy var userBirthday = Birthdays()
    lazy var dob = String()
    lazy var email = String()
    lazy var firstName = String()
    lazy var friendsCount = Int()
    lazy var headerImage = String()
    lazy var id = Int()
    lazy var isBlocked = Bool()
    lazy var isMyFriend = Bool()
    lazy var isFriendRequestReceived = Bool()
    lazy var isFriendRequestSent = Bool()
    var isSelected = Bool()
    lazy var label = [Labels]()
    lazy var lastName = String()
    lazy var note = String()
    lazy var phone = String()
    lazy var profileImage = String()
    lazy var username = String()
    var wishieReceived: [Videos]?
}


