//
//  File.swift
//  Atp
//
//  Created by Kannupriya on 26/05/22.
//  Copyright © 2022 Microsoft. All rights reserved.
//

#if ATP_TESTS
import SwiftMonkeyPaws

class MonkeyPawsInitialisation {
    static func checkLaunchArgumentsForMonkeyPaws(_ window : UIWindow) {
        if CommandLine.arguments.contains("--MonkeyPaws") {
            print(CommandLine.arguments)
            MonkeyPawsToSwizzleMethods.swizzleMethods
            if CommandLine.arguments.contains("DoublePaws") {
                TestAppDelegate.paws = MonkeyPaws(view: window, tapUIApplication: false, configuration: Configuration(paws: Configuration.Paws(maxShown: 2)))
            } else {
                TestAppDelegate.paws = MonkeyPaws(view: window, tapUIApplication: false, configuration: Configuration(paws: Configuration.Paws(maxShown: 1)))
            }
        }
    }
}
#endif
