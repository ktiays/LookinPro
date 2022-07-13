//
//  Created by ktiays on 2022/4/26.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Foundation

@objc(LKPObjcTranspiler)
public class ObjcTranspiler: NSObject {
    
    private let parser: ObjcParser = .init()
    
    private let globalObject: String = "ObjC"
    
    @objc
    public func jsExpression(from objcExpr: String) async throws -> String? {
        guard let astNode = try await parser.parse(expression: objcExpr) else { return nil }
        guard let children = astNode.inner else { return nil }
        
        children.forEach { node in
            if node.kind == .compoundStatement {
                var expression = ""
                if let children = node.inner {
                    for child in children {
                        if child.kind == .objcMessageExpression {
                            expression += handleObjcMessageExpression(child)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func handleObjcMessageExpression(_ node: ASTNode) -> String {
        assert(node.kind == .objcMessageExpression)
        var receiver: String = .init()
        guard let selector: String = node.selector else { return "" }
        guard let receiverKind = node.receiverKind else {
            return .init()
        }
        switch receiverKind {
        case .class:
            if let `class` = node.classType?.qualType {
                receiver = objcClass(from: `class`)
            }
        case .instance:
            break
        default:
            break
        }
        return "\(receiver).\(selector)"
    }
    
    func objcClass(from string: String) -> String {
        globalObject + ".classFromString(\"\(string)\")"
    }
    
}
