import ObjectMapper

class Videos: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        comments <- map[WSResponseParams.WS_RESP_PARAM_COMMENTS]
        commentCounts <- map[WSResponseParams.WS_RESP_PARAM_COMMENT_COUNT]
        didILike <- map[WSResponseParams.WS_RESP_PARAM_DID_I_LIKE]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
        isDraft <- map[WSResponseParams.WS_RESP_PARAM_IS_DRAFT]
        isFavourite <- map[WSResponseParams.WS_RESP_PARAM_IS_FAVOURITE]
        isPublished <- map[WSResponseParams.WS_RESP_PARAM_IS_PUBLISHED]
        likeCounts <- map[WSResponseParams.WS_RESP_PARAM_LIKE_COUNT]
        sharedWith <- map[WSResponseParams.WS_RESP_PARAM_SHARED_WITH]
        typeOfWishie <- map[WSResponseParams.WS_RESP_PARAM_TYPE_OF_WISHIE]
        userId <- map[WSResponseParams.WS_RESP_PARAM_USER_ID]
        video <- map[WSResponseParams.WS_RESP_PARAM_VIDEO]
        videoThumbnail <- map[WSResponseParams.WS_RESP_PARAM_VIDEO_THUMBNAIL]
        whoShared <- map[WSResponseParams.WS_RESP_PARAM_WHO_SHARED]
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
    
    var comments: [Comments]?
    lazy var commentCounts = Int()
    lazy var didILike = Bool()
    lazy var id = Int()
    lazy var isDraft = Int()
    lazy var isFavourite = Bool()
    lazy var isPublished = Int()
    lazy var likeCounts = Int()
    var sharedWith: UserProfile?
    lazy var typeOfWishie = String()
    lazy var userId = Int()
    lazy var video = String()
    lazy var videoThumbnail = String()
    var whoShared: UserProfile?
}

// MARK: - COMMENTS
class Comments: Mappable, CustomStringConvertible {
    
    required init?(map: Map) {}
    
    public init(){
        
    }
    
    func mapping(map: Map) {
        comment <- map[WSResponseParams.WS_RESP_PARAM_COMMENT]
        createdAt <- map[WSResponseParams.WS_RESP_PARAM_CREATED_AT]
        id <- map[WSResponseParams.WS_RESP_PARAM_ID]
        publisherId <- map[WSResponseParams.WS_RESP_PARAM_PUBLISHER_ID]
        updatedAt <- map[WSResponseParams.WS_RESP_PARAM_UPDATED_AT]
        userId <- map[WSResponseParams.WS_RESP_PARAM_USER_ID]
        videoId <- map[WSResponseParams.WS_RESP_PARAM_VIDEO_ID]
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
    
    lazy var comment = String()
    lazy var createdAt = String()
    lazy var id = Int()
    lazy var publisherId = Int()
    lazy var updatedAt = String()
    lazy var userId = Int()
    lazy var videoId = Int()
}
