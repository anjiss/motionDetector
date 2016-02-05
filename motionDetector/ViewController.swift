//
//  ViewController.swift
//  motionDetector
//
//  Created by Anjiss on 2/4/16.
//  Copyright © 2016 Anjiss. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    
    @IBOutlet weak var x_prompt_Label: UILabel!
    @IBOutlet weak var y_prompt_Label: UILabel!
    @IBOutlet weak var z_prompt_Label: UILabel!
    @IBOutlet weak var omega_Label: UILabel!
    @IBOutlet weak var phi_Label: UILabel!
    @IBOutlet weak var kappa_Label: UILabel!
    @IBOutlet weak var x_Label: UILabel!
    @IBOutlet weak var y_Label: UILabel!
    @IBOutlet weak var z_Label: UILabel!
    
    enum x_State {
        case left
        case left_in
        case right
        case right_in
        case still
    }
    enum y_State {
        case foward
        case foward_in
        case back
        case back_in
        case still
    }
    enum z_State {
        case up
        case up_in
        case down
        case down_in
        case still
    }

    
    var motionManager = CMMotionManager()
    var intervelT = 0.1
    var ax = [0.0, 0.0, 0.0]
    var xState = x_State.still
    var yState = y_State.still
    var zState = z_State.still
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        self.x_prompt_Label.text = "Holding"
        self.y_prompt_Label.text = "Holding"
        self.z_prompt_Label.text = "Holding"
        self.xState = .still

        motionManager.deviceMotionUpdateInterval = intervelT
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!) {
            deviceData, error in
            
            if (error != nil) {
                print("Error: \(error)")
            }
            
            self.ax[0] = deviceData!.userAcceleration.x
            self.ax[1] = deviceData!.userAcceleration.y
            self.ax[2] = deviceData!.userAcceleration.z
            
            let R = deviceData!.attitude.rotationMatrix
            var x_r = self.ax[0] * R.m11 + self.ax[1] * R.m21 + self.ax[2] * R.m31
            var y_r = self.ax[0] * R.m12 + self.ax[1] * R.m22 + self.ax[2] * R.m32
            var z_r = self.ax[0] * R.m13 + self.ax[1] * R.m23 + self.ax[2] * R.m33

            
            self.omega_Label.text = String(format: "%.2f°", deviceData!.attitude.pitch*180/M_PI)
            self.phi_Label.text = String(format: "%.2f°", deviceData!.attitude.roll*180/M_PI)
            self.kappa_Label.text = String(format: "%.2f°", deviceData!.attitude.yaw*180/M_PI)
            self.x_Label.text = String(format: "%.2f", x_r)
            self.y_Label.text = String(format: "%.2f", y_r)
            self.z_Label.text = String(format: "%.2f", z_r)
            
            let noise = self.intervelT
            
            if (x_r > -noise && x_r < noise) { x_r = 0.0 }
            if (y_r > -noise && y_r < noise) { y_r = 0.0 }
            if (z_r > -noise && z_r < noise) { z_r = 0.0 }
            
            if (self.xState == .still){
                if (x_r > noise) {
                    self.xState = .left
                    self.x_prompt_Label.text = "Left"
                } else if (x_r < -noise) {
                    self.xState = .right
                    self.x_prompt_Label.text = "Right"
                }
            } else if (self.xState == .left){
                if (x_r < -noise) {
                    self.xState = .left_in
                    self.x_prompt_Label.text = "Left_in"
                }
            } else if (self.xState == .right){
                if (x_r > noise) {
                    self.xState = .right_in
                    self.x_prompt_Label.text = "Right_in"
                }
            } else if (self.xState == .left_in){
                if (x_r > -noise) {
                    self.xState = .still
                    self.x_prompt_Label.text = "Holding"
                }
            } else if (self.xState == .right_in){
                if (x_r < noise) {
                    self.xState = .still
                    self.x_prompt_Label.text = "Holding"
                }
            }
            
            if (self.yState == .still){
                if (y_r > noise) {
                    self.yState = .back
                    self.y_prompt_Label.text = "Back"
                } else if (y_r < -noise) {
                    self.yState = .foward
                    self.y_prompt_Label.text = "Foward"
                }
            } else if (self.yState == .back){
                if (y_r < -noise) {
                    self.yState = .back_in
                    self.y_prompt_Label.text = "Back_in"
                }
            } else if (self.yState == .foward){
                if (y_r > noise) {
                    self.yState = .foward_in
                    self.y_prompt_Label.text = "Foward_in"
                }
            } else if (self.yState == .back_in){
                if (y_r > -noise) {
                    self.yState = .still
                    self.y_prompt_Label.text = "Holding"
                }
            } else if (self.yState == .foward_in){
                if (y_r < noise) {
                    self.yState = .still
                    self.y_prompt_Label.text = "Holding"
                }
            }
            
            if (self.zState == .still){
                if (z_r > noise) {
                    self.zState = .down
                    self.z_prompt_Label.text = "Down"
                    self.view.backgroundColor = UIColor.greenColor()
                } else if (z_r < -noise) {
                    self.zState = .up
                    self.z_prompt_Label.text = "Up"
                    self.view.backgroundColor = UIColor.redColor()
                }
            } else if (self.zState == .down){
                if (z_r < -noise) {
                    self.zState = .down_in
                    self.z_prompt_Label.text = "Down_in"
                }
            } else if (self.zState == .up){
                if (z_r > noise) {
                    self.zState = .up_in
                    self.z_prompt_Label.text = "Up_in"
                }
            } else if (self.zState == .down_in){
                if (z_r > -noise) {
                    self.zState = .still
                    self.z_prompt_Label.text = "Holding"
                    self.view.backgroundColor = UIColor.whiteColor()
                }
            } else if (self.zState == .up_in){
                if (z_r < noise) {
                    self.zState = .still
                    self.z_prompt_Label.text = "Holding"
                    self.view.backgroundColor = UIColor.whiteColor()
                }
            }

        }
        
    }

    @IBAction func reset(sender: AnyObject) {
        self.xState = .still
        self.yState = .still
        self.zState = .still
        self.x_prompt_Label.text = "Holding"
        self.y_prompt_Label.text = "Holding"
        self.z_prompt_Label.text = "Holding"
        self.view.backgroundColor = UIColor.whiteColor()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

