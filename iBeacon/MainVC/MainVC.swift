
//
//  MainVC.swift
//  iBeacon
//
//  Created by 劉陶恩 on 2023/3/6.
//

import UIKit
import CoreLocation
import CoreBluetooth

class MainVC: UIViewController, CBPeripheralManagerDelegate, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var rssi: UILabel!
    @IBOutlet weak var iBeaconOPen: UIButton!
    var locationManager: CLLocationManager!
    let proximityUUID = UUID(uuidString: "709CD0E1-EE0B-4B8F-9561-D9725F644FC9")
    var targetDevice: CBPeripheral!
    var macPeripheral: CBPeripheralManager!
//    var macCentralManager: CBCentralManager!
    var peripherals: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        macPeripheral = CBPeripheralManager(delegate: self, queue: nil)
//        macCentralManager = CBCentralManager(delegate: self, queue: nil)
        self.starScanBle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func iBeaconOp(_ sender: Any) {
       
        self.advertiseDevice(region: CLBeaconRegion.init(uuid: creatBeaconRegion()!.uuid, major: creatBeaconRegion()?.major as! CLBeaconMajorValue, minor: creatBeaconRegion()!.minor as! CLBeaconMinorValue, identifier: creatBeaconRegion()!.identifier))
        print("Advertise")
    }
    //設定iphone的iBeacon
    func creatBeaconRegion() -> CLBeaconRegion? {
        let proximity = UUID(uuidString: "709CD0E1-EE0B-4B8F-9561-D9725F644FC9")
        let major: CLBeaconMajorValue = 1
        let minor: CLBeaconMinorValue = 1
        let beacon = "ios.iBeacon"
        return CLBeaconRegion(uuid: proximity!, major: major, minor: minor, identifier: beacon)
    }
    //開始廣播
    func advertiseDevice(region: CLBeaconRegion) {
        let peripheralData = region.peripheralData(withMeasuredPower: nil)
        macPeripheral.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    }
    
    @IBAction func searchOther(_ sender: Any) {
//        macCentralManager.stopScan()
        let region1 = CLBeaconRegion(uuid: proximityUUID!, major: 1 , minor: 1, identifier: "ios.iBeacon")
        locationManager.startMonitoring(for: region1)
        print("Start")
        
    }
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state{
        case .poweredOn:
            print("藍芽開啟")
        case .poweredOff:
            print("藍芽關閉")
        case .unauthorized:
            print("無授權藍芽功能")
        case .unknown:
            print("未知狀態")
        case .unsupported:
            print("不支持藍牙服務")
        case .resetting:
            print("嘗試重新連接")
        default:
            print("nil")
        }
    }
    
    func starScanBle(){
//        macCentralManager.scanForPeripherals(withServices: nil,options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            print("藍芽開啟")
            NotificationCenter.default.post(name: Notification.Name("BluetoothStatus"), object: nil,userInfo: ["status":true])
            central.scanForPeripherals(withServices: nil,options: nil)
        case .poweredOff:
            print("藍芽關閉")
            NotificationCenter.default.post(name: Notification.Name("BluetoothStatus"), object: nil, userInfo: ["status":false])
        case .unauthorized:
            print("無授權藍芽功能")
        case .unknown:
            print("未知狀態")
        case .unsupported:
            print("不支持藍牙服務")
        case .resetting:
            print("嘗試重新連接")
        default:
            print("nil")
        }
    }
  
    
}

extension MainVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager did fail: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Location manager did fail: \(error.localizedDescription)")
    }
    
    //MARK: 開始偵測範圍之後，就先檢查目前的 state 是否在範圍內
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region is CLBeaconRegion else {return}
        
        // 在範圍內
        if state == .inside {
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: proximityUUID!, major: 1, minor: 1))
            } //在範圍外
        } else if state == .outside {
            manager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: proximityUUID!, major: 1, minor: 1))
        }
    }
    
    //進入 region 的處理
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        view.backgroundColor = .black
        
        let content = UNMutableNotificationContent()
        content.title = "注意"
        content.subtitle = "Mac就在你身邊"
        content.badge = 1
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        print("Enter region")
        
        if CLLocationManager.isRangingAvailable() {
            if let beaconRegion = region as? CLBeaconRegion {
                let constraint = CLBeaconIdentityConstraint(uuid: beaconRegion.uuid, major: beaconRegion.major as! CLBeaconMajorValue, minor: beaconRegion.minor as! CLBeaconMinorValue)
                locationManager.startRangingBeacons(satisfying: constraint)
            }
        }
    }
    //離開 region 的處理
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit region")
        let beaconRegion = region as? CLBeaconRegion
        let constraint = CLBeaconIdentityConstraint(uuid: beaconRegion!.uuid, major: beaconRegion?.major as! CLBeaconMajorValue, minor: beaconRegion?.minor as! CLBeaconMinorValue)
        locationManager.stopRangingBeacons(satisfying: constraint)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Location manager ranging beacons did fail: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if beacons.count > 0 {
            let nearsBeacons = beacons[0]
            print(nearsBeacons.proximity, nearsBeacons.major, nearsBeacons.minor,nearsBeacons.rssi)
            switch nearsBeacons.proximity {
            case .immediate:
                print("immediate")
                rssi.text = String(nearsBeacons.rssi)
            case .far:
                print("far")
                rssi.text = "Far"
            case .near:
                print("near")
                rssi.text = String(nearsBeacons.rssi)
            case .unknown:
                print("unknow")
            default:
                print("default")
            }
        }
    }
    
    
}

