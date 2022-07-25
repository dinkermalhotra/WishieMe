import ObjectMapper

class Profile: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        bio <- map[WSResponseParams.WS_RESP_PARAM_BIO]
        dob <- map[WSResponseParams.WS_RESP_PARAM_DOB]
        email <- map[WSResponseParams.WS_RESP_PARAM_EMAIL]
        firstName <- map[WSResponseParams.WS_RESP_PARAM_FIRST_NAME]
        friendsCount <- map[WSResponseParams.WS_RESP_PARAM_FRIENDS_COUNT]
        headerImage <- map[WSResponseParams.WS_RESP_PARAM_HEADER_IMAGE]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
        lastName <- map[WSResponseParams.WS_RESP_PARAM_LAST_NAME]
        phone <- map[WSResponseParams.WS_RESP_PARAM_PHONE]
        profileImage <- map[WSResponseParams.WS_RESP_PARAM_PROFILE_IMAGE]
        username <- map[WSResponseParams.WS_RESP_PARAM_USERNAME]
        wishieReceived <- map[WSResponseParams.WS_RESP_PARAM_WISHIE_RECEIVED]
        wishieSent <- map[WSResponseParams.WS_RESP_PARAM_WISHIE_SENT]
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
    lazy var dob = String()
    lazy var email = String()
    lazy var firstName = String()
    lazy var friendsCount = Int()
    lazy var headerImage = String()
    lazy var id = Int()
    lazy var lastName = String()
    lazy var phone = String()
    lazy var profileImage = String()
    lazy var username = String()
    var wishieReceived: [Videos]?
    var wishieSent: [Videos]?
}

