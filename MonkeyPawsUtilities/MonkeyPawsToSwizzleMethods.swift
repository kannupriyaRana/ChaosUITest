//
//  MonkeyPawsToSwizzleMethods.swift
//  Atp
//
//  Created by Kannupriya on 26/05/22.
//  Copyright © 2022 Microsoft. All rights reserved.
//

import Foundation
import UIKit

#if ATP_TESTS
extension UIApplication {
    @objc
    func swizzledSendEventToDrawPawsAlongWithAction(_ event: UIEvent) {
        TestAppDelegate.paws!.append(event: event)
        if CommandLine.arguments.contains("shouldExecuteScreenEventActions") {
            self.swizzledSendEventToDrawPawsAlongWithAction(event)
        }
    }
}

//It will set accessibilityIdentifier for a viewController as : \(SCREENNAME)ViewControllerAsId
extension UIViewController {
    func provideAccessibilityIdentifier(_ screenName : String) {
        self.view.accessibilityIdentifier = "\(screenName)ViewControllerAsId"
    }
}

public class MonkeyPawsToSwizzleMethods {
     static let swizzleMethods: Bool = {
        let originalSelector = #selector(UIApplication.sendEvent(_:))
        let swizzledSelector = #selector(UIApplication.swizzledSendEventToDrawPawsAlongWithAction(_:))

        let originalMethod = class_getInstanceMethod(UIApplication.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(UIApplication.self, swizzledSelector)

        let didAddMethod = class_addMethod(UIApplication.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))

        if didAddMethod {
            class_replaceMethod(UIApplication.self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
        return true
    }()
}
#endif
