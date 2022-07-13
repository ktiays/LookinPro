//
//  Created by ktiays on 2022/4/23.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import AppKit
import System
import AuxiliaryExecute

class ObjcParser {
    
    private var clangPath: String? {
        get async {
            if let path = _clangPath { return path }
            _clangPath = await findClang()
            return _clangPath
        }
    }
    private var _clangPath: String?
    
    private var iPhoneOSSDKPath: String? {
        get async {
            if let sdkPath = _iPhoneOSSDKPath { return sdkPath }
            _iPhoneOSSDKPath = await findiPhoneOSSDK()
            return _iPhoneOSSDKPath
        }
    }
    private var _iPhoneOSSDKPath: String?
    
    private func findClang() async -> String? {
        await withCheckedContinuation { continuation in
            let _ = AuxiliaryExecute.local.shell(command: "xcrun", args: ["--find", "clang"], stdoutBlock: { out in
                continuation.resume(returning: out.contains("error") ? nil : out.trimmingCharacters(in: .whitespacesAndNewlines))
            })
        }
    }
    
    private var variables = Set<Variable>()
    
    private func findiPhoneOSSDK() async -> String? {
        await withCheckedContinuation{ continuation in
            let _ = AuxiliaryExecute.local.shell(command: "xcrun", args: ["--sdk", "iphoneos", "--show-sdk-path"], stdoutBlock: { out in
                continuation.resume(returning: out.contains("error") ? nil : out.trimmingCharacters(in: .whitespacesAndNewlines))
            })
        }
    }
    
    private let publicFrameworks: [String] = [
        "UIKit", "QuartzCore"
    ]
    private lazy var includes: String =
        publicFrameworks.reduce("") { partialResult, framework in
            partialResult + "#import <\(framework)/\(framework).h>\n"
        }
    
    func parse(expression: String) async throws -> ASTNode? {
        #if DEBUG
        variables = [.init(name: "view", type: "UIView *")]
        #endif
        guard let clangPath = await clangPath else { return nil }
        guard let sdkPath = await iPhoneOSSDKPath else { return nil }
        let tmpFilePath = FilePath(NSTemporaryDirectory()).appending("ojs_objc_decorate.m")
        try (includes + variables.map { $0.objcDescription }.joined(separator: "\n") + "\nvoid __ojs_objc_decorate(void) { \(expression); }")
            .write(
                toFile: tmpFilePath.string,
                atomically: true,
                encoding: .utf8
            )
        var ast: String = .init()
        await AuxiliaryExecute.spawnAsync(
            command: clangPath,
            args: [
                "-isysroot", sdkPath,
                "-fmodules",
                "-fsyntax-only",
                "-Xclang",
                "-ast-dump=json",
                tmpFilePath.string],
            stdoutBlock: { slice in
                ast.append(contentsOf: slice.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        )
        ast = ast.replacingOccurrences(of: "\n", with: "")
        #if DEBUG
        try ast.write(toFile: FilePath(NSHomeDirectory()).appending("/Desktop/AST.json").string,
                      atomically: true,
                      encoding: .utf8)
        #endif
        
        return try? JSONDecoder().decode(ASTNode.self, from: ast.data(using: .utf8)!).firstFunctionDeclarationNode
    }
    
}

extension ASTNode {
    
    var firstFunctionDeclarationNode: ASTNode? {
        if kind == .functionDeclaration {
            return self
        }
        return inner?.first { $0.kind == .functionDeclaration }
    }
    
}

struct Variable: Hashable {
    
    var name: String
    var type: String
    
    var objcDescription: String {
        "\(type) \(name);"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
    
}
