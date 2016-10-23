//
//  ViewController.swift
//  Compass
//
//  Created by Keith Russell on 9/30/16.
//  Copyright © 2016 Keith Russell. All rights reserved.
//

import UIKit
import MapKit
import CoreMotion

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.mapType = MKMapType.satellite
            mapView.isZoomEnabled = true
            mapView.isScrollEnabled = true;
        }
    }
    let manager = CMMotionManager()
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var compassNeedle: UIImageView!
    @IBOutlet weak var yawLbl: UILabel!
    @IBOutlet weak var rollLbl: UILabel!
    @IBOutlet weak var picthLbl: UILabel!
    @IBOutlet weak var mapFixedBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        deviceManagerSetup(btnPressed: false)
    }
    
    func setupView(){
        
        let side = sqrt(pow(view.frame.height/2, 2) + pow(view.frame.width/2, 2))
        print(2 * side)
        containerViewHeight.constant = 2 * side
        containerViewWidth.constant = 2 * side
        let deltaX = 5.0
        let deltaY = 5.0
        var region = MKCoordinateRegion()
        region.center.latitude = 40.0
        region.center.longitude = -75.0
        region.span.latitudeDelta = deltaX
        region.span.longitudeDelta = deltaY
        mapView.setRegion(region, animated: true )
        mapView.isUserInteractionEnabled = true
    }
    
    func radiansToDegrees(radians: Double) -> Double {
        let degrees = radians * 180/M_PI
        return round(degrees)
    }
    
    func deviceManagerSetup(btnPressed : Bool){

        var yaw: Double! = 0.0
        if btnPressed == true {
        if manager.isDeviceMotionAvailable == true {
            
            manager.deviceMotionUpdateInterval = 0.02
            let queue = OperationQueue()
            self.mapView.transform = CGAffineTransform.identity
            manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: queue, withHandler: {
                [weak self] (data:CMDeviceMotion?, error: Error?) in
                if (data?.attitude) != nil {
                    yaw = data?.attitude.yaw
                    let yawDegrees = self?.radiansToDegrees(radians: yaw!)
                    let roll = data?.attitude.roll
                    let rollDegrees = self?.radiansToDegrees(radians: roll!)
                    let pitch = data?.attitude.pitch
                    let pitchDegrees = self?.radiansToDegrees(radians: pitch!)
                    
                    OperationQueue.main.addOperation({
                        self?.yawLbl.text = "\(yawDegrees!)"
                        self?.rollLbl.text = "\(rollDegrees!)"
                        self?.picthLbl.text = "\(pitchDegrees!)"
                        self?.mapView.transform = CGAffineTransform(rotationAngle: CGFloat(yaw! + M_PI/2))
                    })
                }
                })
            }} else {
            manager.stopDeviceMotionUpdates()
        }
    }
    @IBAction func mapOrientationBtnPressed(_ sender: UIButton) {
        
        if mapFixedBtn.currentTitle == "mapFixed"
        {
            mapFixedBtn.setTitle("mapRotates", for: .normal)
            deviceManagerSetup(btnPressed: true)
        } else {
            mapFixedBtn.setTitle("mapFixed", for: .normal)
            deviceManagerSetup(btnPressed: false)
        }
    }
}
