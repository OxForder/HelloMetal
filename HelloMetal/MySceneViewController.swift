//
//  MySceneViewController.swift
//  HelloMetal
//
//  Created by Павел Шестаков on 09.12.15.
//  Copyright © 2015 Павел Шестаков. All rights reserved.
//

import UIKit

class MySceneViewController: MetalViewController,MetalViewControllerDelegate {
  
  var worldModelMatrix:Matrix4!
  var objectToDraw: Cube!
  
  let panSensivity:Float = 5.0
  var lastPanLocation: CGPoint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    worldModelMatrix = Matrix4()
    worldModelMatrix.translate(0.0, y: 0.0, z: -4)
    worldModelMatrix.rotateAroundX(Matrix4.degreesToRad(25), y: 0.0, z: 0.0)
    
    objectToDraw = Cube(device: device, commandQ:commandQueue)
    self.metalViewControllerDelegate = self
    
    setupGestures()
  }
  
  //MARK: - MetalViewControllerDelegate
  func renderObjects(drawable:CAMetalDrawable) {
    
    objectToDraw.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
  }
  
  func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
    objectToDraw.updateWithDelta(timeSinceLastUpdate)
  }

  //MARK: - Gesture related
  // 1
  func setupGestures(){
    let pan = UIPanGestureRecognizer(target: self, action: Selector("pan:"))
    self.view.addGestureRecognizer(pan)
  }
  
  // 2
  func pan(panGesture: UIPanGestureRecognizer){
    if panGesture.state == UIGestureRecognizerState.Changed{
      let pointInView = panGesture.locationInView(self.view)
      // 3
      let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
      let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
      // 4
      objectToDraw.rotationY -= xDelta
      objectToDraw.rotationX -= yDelta
      lastPanLocation = pointInView
    } else if panGesture.state == UIGestureRecognizerState.Began{
      lastPanLocation = panGesture.locationInView(self.view)
    } 
  }
  
}
