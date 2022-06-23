//
//  ChaosGestureCreationAndExecution.swift
//  AtpUITests
//
//  Created by Kannupriya on 26/05/22.
//  Copyright © 2022 Microsoft. All rights reserved.
//

import XCTest

class ChaosGestureCreationAndExecution: XCTestCase {
    let typesOfSinglePawGesturesAvailable = 9
    let typesOfDoublePawGesturesAvailable = 3

    func scrollUpRandomly(_ app : XCUIApplication, _ coordinate : XCUICoordinate, _ currentGesture : inout GestureInfo) {
        let maxSize = app.windows.element(boundBy: 0).frame.size
        let startY = coordinate.screenPoint.y
        let dy = (startY * getRandomValueBetween0And1()) / maxSize.height
        let vector = CGVector(dx: coordinate.screenPoint.x / maxSize.width, dy: dy)
        performScrollingAndAppendCurrentGestureInfo(coordinate, &currentGesture, vector, app)
    }

    func scrollDownRandomly(_ app : XCUIApplication, _ coordinate : XCUICoordinate, _ currentGesture : inout GestureInfo) {
        let maxSize = app.windows.element(boundBy: 0).frame.size
        let startY = coordinate.screenPoint.y
        let dy = ((maxSize.height - startY) * getRandomValueBetween0And1() + startY) / maxSize.height
        let vector = CGVector(dx: coordinate.screenPoint.x / maxSize.width, dy: dy)
        performScrollingAndAppendCurrentGestureInfo(coordinate, &currentGesture, vector, app)
    }

    func scrollLeftRandomly(_ app : XCUIApplication, _ coordinate : XCUICoordinate, _ currentGesture : inout GestureInfo) {
        let maxSize = app.windows.element(boundBy: 0).frame.size
        let startX = coordinate.screenPoint.x
        let dx = (startX * getRandomValueBetween0And1()) / maxSize.width
        let vector = CGVector(dx: dx, dy: coordinate.screenPoint.y / maxSize.height)
        performScrollingAndAppendCurrentGestureInfo(coordinate, &currentGesture, vector, app)
    }

    func scrollRightRandomly(_ app : XCUIApplication, _ coordinate : XCUICoordinate, _ currentGesture : inout GestureInfo) {
        let maxSize = app.windows.element(boundBy: 0).frame.size
        let startX = coordinate.screenPoint.x
        let dx = ((maxSize.width - startX) * getRandomValueBetween0And1() + startX) / maxSize.width
        let vector = CGVector(dx: dx, dy: coordinate.screenPoint.y / maxSize.height)
        performScrollingAndAppendCurrentGestureInfo(coordinate, &currentGesture, vector, app)
    }

    func performScrollingAndAppendCurrentGestureInfo(_ coordinate : XCUICoordinate, _ currentGesture : inout GestureInfo, _ vector : CGVector, _ app : XCUIApplication) {
        let endCoordinate = getCoordinateForVector(vector: vector, app)
        scroll(fromCoordinate: coordinate, toCoordinate: endCoordinate)
        currentGesture.endCoordinate = endCoordinate
    }

    func drawPawForThisSinglePawGestureAndStoreInArray(_ app : XCUIApplication, _ currentGesture : inout GestureInfo, _ randomGestureID : Int) {
        let coordinate = getRandomCoordinate(app)
        currentGesture.startCoordinate = coordinate
        switch randomGestureID {
            case 0:
                coordinate.tap()
            case 1:
                coordinate.press(forDuration: 2)
            case 2:
                let endCoordinate = getRandomCoordinate(app)
                coordinate.press(forDuration: 2, thenDragTo: endCoordinate)
                currentGesture.endCoordinate = endCoordinate
            case 3:
                app.swipeUp()
            case 4:
                app.swipeDown()
            case 5:
                app.swipeLeft()
            case 6:
                app.swipeRight()
            case 7:
                scrollLeftRandomly(app, coordinate, &currentGesture)
            case 8:
                scrollRightRandomly(app, coordinate, &currentGesture)
            default:
                break
        }
    }

    func drawPawForThisDoublePawGestureAndStoreInArray(_ app : XCUIApplication, _ currentGesture : inout GestureInfo, _ randomGestureID : Int) {
        let coordinate = getRandomCoordinate(app)
        currentGesture.startCoordinate = coordinate
        switch randomGestureID {
            case 0:
                coordinate.doubleTap()
            case 1:
                let withScale = Double.random(in: 0.03..<1)
                app.pinch(withScale: withScale, velocity: -40)
                currentGesture.withScale = withScale
            case 2:
                let withScale = Double.random(in: 2...43)
                app.pinch(withScale: withScale, velocity: 40)
                currentGesture.withScale = withScale
            default:
                break
        }
    }

    func executeRandomGestureWithoutAction(_ arrayOfGesturesInfo : inout [GestureInfo], _ app : XCUIApplication, completionHandlerToTakeScreenshot: () -> Void) {
        var currentGesture = GestureInfo()
        let randomGestureID : Int!
        if app.launchArguments.contains("DoublePaws") {
            randomGestureID = Int.random(in: 0...typesOfDoublePawGesturesAvailable - 1)
            currentGesture.gestureType = randomGestureID
            drawPawForThisDoublePawGestureAndStoreInArray(app, &currentGesture, randomGestureID)
        } else {
            randomGestureID = Int.random(in: 0...typesOfSinglePawGesturesAvailable - 1)
            currentGesture.gestureType = randomGestureID
            drawPawForThisSinglePawGestureAndStoreInArray(app, &currentGesture, randomGestureID)
        }
        arrayOfGesturesInfo.append(currentGesture)
        completionHandlerToTakeScreenshot()
    }

    func performActionForGivenSinglePawGesture(_ coordinate : XCUICoordinate?, _ endCoordinate : XCUICoordinate?, _ gestureType : Int, _ app : XCUIApplication) {
        var content = ""
        var directionToScroll = ""
        let directions : [Int:String] = [
            7 : "left",
            8 : "right"
        ]
        switch gestureType {
            case 0:
                coordinate!.tap()
                content = "\nTap on coordinate (\(coordinate!))"
            case 1:
                coordinate!.press(forDuration: 2)
                content = "\nLong Press on coordinate (\(coordinate!))"
            case 2:
                coordinate!.press(forDuration: 2, thenDragTo: endCoordinate!)
                content = "\nLong Press on coordinate (\(coordinate!)) and then dragged to (\(endCoordinate!)) "
            case 3:
                app.swipeUp()
                content = "\nSwipe up"
            case 4:
                app.swipeDown()
                content = "\nSwipe down"
            case 5:
                app.swipeLeft()
                content = "\nSwipe left"
            case 6:
                app.swipeRight()
                content = "\nSwipe right"
            case 7, 8 :
                scroll(fromCoordinate: coordinate!, toCoordinate: endCoordinate!)
                directionToScroll = directions[gestureType]!
                content = "\nScroll \(directionToScroll) from coordinate (\(coordinate!)) to (\(endCoordinate!)) "
            default:
                break
        }
        LogFileHandler.appendLogsIntoFile(content)
    }

    func performActionForGivenDoublePawGesture(_ coordinate : XCUICoordinate?, _ endCoordinate : XCUICoordinate?, _ gestureType : Int, _ app : XCUIApplication, _ withScale : Double?) {
        var content = ""
        switch gestureType {
            case 0:
                coordinate!.doubleTap()
                content = "\nDouble tap on coordinate (\(coordinate!))"
            case 1:
                app.pinch(withScale: withScale!, velocity: -40)
                content = "\nZoom out with scale \(withScale!)"
            case 2:
                app.pinch(withScale: withScale!, velocity: 40)
                content = "\nZoom in with scale \(withScale!)"
            default:
                break
        }
        LogFileHandler.appendLogsIntoFile(content)
    }

    func executeGestureWithAction(_ currentGesture : GestureInfo, _ app : XCUIApplication) {
        let coordinate = currentGesture.startCoordinate
        let endCoordinate = currentGesture.endCoordinate
        let withScale = currentGesture.withScale
        let gestureType = currentGesture.gestureType!
        if app.launchArguments.contains("DoublePaws") {
            performActionForGivenDoublePawGesture(coordinate, endCoordinate, gestureType, app, withScale)
        } else {
            performActionForGivenSinglePawGesture(coordinate, endCoordinate, gestureType, app)
        }
    }

    private func getRandomCoordinate(_ app : XCUIApplication) -> XCUICoordinate {
        let randomX = getRandomValueBetween0And1()
        let randomY = getRandomValueBetween0And1()
        let randomVector = CGVector(dx: randomX, dy: randomY)
        let coordinate = getCoordinateForVector(vector: randomVector, app)
        return coordinate
    }

    private func getCoordinateForVector(vector: CGVector, _ app : XCUIApplication) -> XCUICoordinate {
        let window = app.windows.element(boundBy: 0)
        let coordinate = window.coordinate(withNormalizedOffset: vector)
        return coordinate
    }

    private func getRandomValueBetween0And1() -> CGFloat {
        return CGFloat.random(in: 0...1)
    }

    private func scroll(fromCoordinate: XCUICoordinate, toCoordinate: XCUICoordinate) {
        fromCoordinate.press(forDuration: 0, thenDragTo: toCoordinate)
    }
}
