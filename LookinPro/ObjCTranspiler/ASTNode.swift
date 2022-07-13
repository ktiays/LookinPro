//
//  Created by ktiays on 2022/4/26.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Foundation

struct ASTNode: Codable, Identifiable {
    
    enum Kind: String, Codable {
        case typedefDeclaration = "TypedefDecl"
        case functionDeclaration = "FunctionDecl"
        case importDeclaration = "ImportDecl"
        case compoundStatement = "CompoundStmt"
        case implicitCast = "ImplicitCastExpr"
        
        case objcMessageExpression = "ObjCMessageExpr"
        case objcBoolLiteralExpression = "ObjCBoolLiteralExpr"
        
        case unknown
        
        init(from decoder: Decoder) throws {
            let rawValue = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: rawValue) ?? .unknown
        }
    }
    
    enum ReceiverKind: String, Codable {
        case `class` = "class"
        case instance = "instance"
        
        case unknown
        
        init(from decoder: Decoder) throws {
            let rawValue = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: rawValue) ?? .unknown
        }
    }
    
    var id: String
    var kind: Kind
    
    var type: ASTNodeType?
    var classType: ASTNodeType?
    var callReturnType: ASTNodeType?
    
    var value: String?
    
    var name: String?
    var mangledName: String?
    
    var selector: String?
    var receiverKind: ReceiverKind?
    
    var inner: [ASTNode]?
    
}

struct ASTNodeType: Codable {
    
    var qualType: String
    var desugaredQualType: String?
    
}

enum ObjcBoolValue {
    static let NO = "__objc_no"
    static let YES = "__objc_yes"
}
