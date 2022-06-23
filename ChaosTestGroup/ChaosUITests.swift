//
//  ChaosUITests.swift
//  AtpUITests
//
//  Created by Kannupriya on 26/05/22.
//  Copyright © 2022 Microsoft. All rights reserved.
//

import Foundation
import XCTest
import SwiftMonkeyPaws

//disabled automatically generated screenshots in atp scheme

class ChaosUITests: CustomUITestBase {

    override func setUp() {
        addUIInterruptionMonitor(withDescription: "MS Defender would like to send you notifications" ) { _ -> Bool in
            return false
        }
    }

    var gestureNumberForScreenshotOfActualGesture = 0
    var gestureHandler = ChaosGestureCreationAndExecution()
    let numberOfGesturesToBeExecuted: UInt = 5
    let screens : [String] = [
        "SignInFailedScreen",
        "VPNScreen",
        "TrustedNetworkListScreen",
        "InvalidLicenseScreen",
        "UnexpectedErrorScreen",
        "AdminDisabledScreen",
        "PrivacyNoticeScreeen",
        "GibraltarConsentScreen",
        "EulaScreenConsumerTest",
        "AboutPageViewController"
    ]

    func appendRequiredArguments(_ screenName : String) {
        app.launchArguments.append("--MonkeyPaws")
        app.launchArguments.append("-ScreenUnderTest")
        app.launchArguments.append(screenName)
    }

    func checkForAlerts() {
        if app.alerts.element.collectionViews.buttons["Allow"].exists {
            app.alerts.element.collectionViews.buttons["Allow"].tap()
        } else if app.alerts.element.collectionViews.buttons["Ok"].exists {
            app.alerts.element.collectionViews.buttons["Ok"].tap()
        } else if app.alerts.element.collectionViews.buttons["Cancel"].exists {
            app.alerts.element.collectionViews.buttons["Cancel"].tap()
        } else if app.alerts.element.collectionViews.buttons["Yes"].exists {
            app.alerts.element.collectionViews.buttons["Yes"].tap()
        }
    }

    func takeScreenshot(_ gestureNumber : Int) {
        let mainScreenScreenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: mainScreenScreenshot)
        attachment.name = "gesture\(gestureNumber)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func removeLaunchArgumentIfExist(_ app : XCUIApplication, _ arg : String) {
        let possibleIndexOfLaunchArgumentWhichExecutes : Int? = app.launchArguments.firstIndex(of: arg)
        if possibleIndexOfLaunchArgumentWhichExecutes != nil {
            app.launchArguments.remove(at: possibleIndexOfLaunchArgumentWhichExecutes!)
        }
    }

    func executeMockGesturesUntilOnSameScreen(_ mockGesturesExecutedSoFar : inout Int, _ accessibilityIdentifier : String, _ seriesOfGestures : inout [GestureInfo], _ gestureNumberForScreenshotOfMockGesture : inout Int, _ app : XCUIApplication) {
        if mockGesturesExecutedSoFar < numberOfGesturesToBeExecuted {
            launchAppWithTime()
        }
        while mockGesturesExecutedSoFar < numberOfGesturesToBeExecuted {
            if app.state != .runningForeground || app.otherElements[accessibilityIdentifier].waitForExistence(timeout: 2) == false {
                app.terminate()
                break
            }
            if app.state == .runningForeground {
                checkForAlerts()
                gestureHandler.executeRandomGestureWithoutAction(&seriesOfGestures, app, completionHandlerToTakeScreenshot: {
                    takeScreenshot(gestureNumberForScreenshotOfMockGesture)
                })
                takeScreenshot(gestureNumberForScreenshotOfMockGesture)
                gestureNumberForScreenshotOfMockGesture += 1
                mockGesturesExecutedSoFar += 1
            }
        }
    }

    func executeActualGestureUntilOnSameScreen(_ seriesOfGesture : [GestureInfo], _ actualGestureNo : inout Int, _ mockGestureNo : inout Int, _ accessId : String, _ screenName : String, _ gestureNumberInLogFile : inout Int, _ app : XCUIApplication) {
        var content = ""
        while true {
            if app.state == .runningForeground && actualGestureNo < mockGestureNo {
                checkForAlerts()
                content = "\n\nScreen Under Test : \(screenName)"
                LogFileHandler.appendLogsIntoFile(content)
                content = "\nGesture_\(gestureNumberInLogFile) -"
                gestureNumberInLogFile += 1
                LogFileHandler.appendLogsIntoFile(content)
                gestureHandler.executeGestureWithAction(seriesOfGesture[actualGestureNo], app)
                gestureNumberForScreenshotOfActualGesture += 1
                actualGestureNo += 1
            }
            let isRunningBackground = app.wait(for: .runningBackground, timeout: 3)
            if isRunningBackground {
                app.terminate()
                break
            }
            if app.otherElements[accessId].exists == false {
                if app.state == .runningForeground {
                    app.terminate()
                    break
                } else {
                    content = "\nFailed"
                    LogFileHandler.appendLogsIntoFile(content)
                    fatalError("terminating the process, crash occured!!")
                }
            }
            if actualGestureNo == mockGestureNo {
                break
            }
        }
    }

    func performChaosTestOnThisScreen(_ screenName : String, _ accessibilityIdentifier : String, _ gestureNumberInLogFile : inout Int, _ gestureNumberForScreenshotOfMockGesture : inout Int ) {
        var seriesOfGestures = [GestureInfo]()
        var mockGesturesExecutedSoFar = 0
        var actualGesturesExecutedSoFar = 0
        while mockGesturesExecutedSoFar < numberOfGesturesToBeExecuted || actualGesturesExecutedSoFar < mockGesturesExecutedSoFar {
            removeLaunchArgumentIfExist(app, "shouldExecuteScreenEventActions")
            executeMockGesturesUntilOnSameScreen(&mockGesturesExecutedSoFar, accessibilityIdentifier, &seriesOfGestures, &gestureNumberForScreenshotOfMockGesture, app)
            app.launchArguments.append("shouldExecuteScreenEventActions")
            launchAppWithTime()
            executeActualGestureUntilOnSameScreen(seriesOfGestures, &actualGesturesExecutedSoFar, &mockGesturesExecutedSoFar, accessibilityIdentifier, screenName, &gestureNumberInLogFile, app)
        }
        app.terminate()
    }

    func testAScreenForGivenNumberOfInputs() {
        print(app.launchArguments)
        var gestureNumberInLogFile = 0
        var gestureNumberForScreenshotOfMockGesture = 0
        LogFileHandler.createFileToStoreInputEvents()
        for (key) in screens {
            let accessibilityID = "\(key)ViewControllerAsId"
            print(app.launchArguments)
            appendRequiredArguments(key)
            performChaosTestOnThisScreen(key, accessibilityID, &gestureNumberInLogFile, &gestureNumberForScreenshotOfMockGesture)
            //now for double paws
            app.launchArguments.append("DoublePaws")
            performChaosTestOnThisScreen(key, accessibilityID, &gestureNumberInLogFile, &gestureNumberForScreenshotOfMockGesture)
            app.launchArguments = []
        }
    }
}
