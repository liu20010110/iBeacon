//
//  MathUnitTest.swift
//  iBeaconTests
//
//  Created by 劉陶恩 on 2023/3/8.
//

import XCTest
import CoreLocation
@testable import iBeacon


final class MathUnitTest: XCTestCase {
    
    var vc: MainVC!
    
//    var sut: Arithmetic!

    override func setUpWithError() throws {
//        sut = Arithmetic()
        vc = MainVC()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        vc = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddition() {
        //Given
        let dis = vc.locationManager
        let beacons: [CLBeacon] = []
        let region = CLRegion()
        let beaconRegion2 = region as? CLBeaconRegion
        let beaconConstrain = CLBeaconIdentityConstraint(uuid: vc.proximityUUID!, major: 1, minor: 1)
        let exit = "Exit"
        //When
        let result2: Void? = dis!.delegate?.locationManager!(dis!, didRange: beacons, satisfying: beaconConstrain)
        let result: Void? = dis!.delegate?.locationManager?(dis!, didExitRegion: beaconRegion2!)
        
        //Then
//        XCTAssertEqual(result, exit)
        
    }
  
    
 

}
