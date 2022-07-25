import ObjectMapper

class Reminders: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        birthdayCounts <- map[WSResponseParams.WS_RESP_PARAM_BIRTHDAY_COUNTS]
        labelName <- map[WSResponseParams.WS_RESP_PARAM_LABEL_NAME]
        labelColor <- map[WSResponseParams.WS_RESP_PARAM_LABEL_COLOR]
        createdBy <- map[WSResponseParams.WS_RESP_PARAM_CREATED_BY]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
        reminders <- map[WSResponseParams.WS_RESP_PARAM_REMINDERS]
        totalCounts <- map[WSResponseParams.WS_RESP_PARAM_TOTAL_COUNTS]
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
    
    lazy var birthdayCounts = Int()
    lazy var labelName = String()
    lazy var labelColor = String()
    lazy var createdBy = Int()
    lazy var id = Int()
    lazy var reminders = [Reminder]()
    lazy var totalCounts = Int()
}

class Reminder: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        daysBefore <- map[WSResponseParams.WS_RESP_PARAM_DAYS_BEFORE]
        labelId <- map[WSResponseParams.WS_RESP_PARAM_LABEL_ID]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
        isEnable <- map[WSResponseParams.WS_RESP_PARAM_IS_ENABLE]
        time <- map[WSResponseParams.WS_RESP_PARAM_TIME]
        title <- map[WSResponseParams.WS_RESP_PARAM_TITLE]
        tone <- map[WSResponseParams.WS_RESP_PARAM_TONE]
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
    
    lazy var daysBefore = String()
    lazy var labelId = Int()
    lazy var id = Int()
    lazy var isEnable = Int()
    lazy var time = String()
    lazy var title = String()
    lazy var tone = String()
}
