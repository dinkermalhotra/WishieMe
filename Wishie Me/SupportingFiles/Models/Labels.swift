import ObjectMapper

class Labels: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        birthdays <- map[WSResponseParams.WS_RESP_PARAM_BIRTHDAYS]
        birthdayCounts <- map[WSResponseParams.WS_RESP_PARAM_BIRTHDAY_COUNTS]
        labelName <- map[WSResponseParams.WS_RESP_PARAM_LABEL_NAME]
        labelColor <- map[WSResponseParams.WS_RESP_PARAM_LABEL_COLOR]
        createdBy <- map[WSResponseParams.WS_RESP_PARAM_CREATED_BY]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
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
    
    lazy var birthdays = [Birthdays]()
    lazy var birthdayCounts = Int()
    lazy var labelName = String()
    lazy var labelColor = String()
    lazy var createdBy = Int()
    lazy var id = Int()
}
