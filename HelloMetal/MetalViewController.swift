//
//  ViewController.swift
//  HelloMetal
//
//  Created by Павел Шестаков on 09.12.15.
//  Copyright © 2015 Павел Шестаков. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

protocol MetalViewControllerDelegate : class{
  func updateLogic(timeSinceLastUpdate:CFTimeInterval)
  func renderObjects(drawable:CAMetalDrawable)
}

class MetalViewController: UIViewController {

  var device: MTLDevice! = nil
  var metalLayer: CAMetalLayer! = nil
  var pipelineState: MTLRenderPipelineState! = nil
  var commandQueue: MTLCommandQueue! = nil
  var timer: CADisplayLink! = nil
  var projectionMatrix: Matrix4!
  var lastFrameTimestamp: CFTimeInterval = 0.0
  
  weak var metalViewControllerDelegate:MetalViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degreesToRad(85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
    
    
    device = MTLCreateSystemDefaultDevice()
    metalLayer = CAMetalLayer()
    metalLayer.device = device
    metalLayer.pixelFormat = .BGRA8Unorm
    metalLayer.framebufferOnly = true
    view.layer.addSublayer(metalLayer)
    
    
    commandQueue = device.newCommandQueue()
    
    let defaultLibrary = device.newDefaultLibrary()
    let fragmentProgram = defaultLibrary!.newFunctionWithName("basic_fragment")
    let vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
    
    
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
    pipelineStateDescriptor.colorAttachments[0].blendingEnabled = true
    pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperation.Add;
    pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperation.Add;
    pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactor.One;
    pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactor.One;
    pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactor.OneMinusSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactor.OneMinusSourceAlpha;
    do {
        pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
    } catch {
        print("Failed to create pipeline state, error")
    }
    
    timer = CADisplayLink(target: self, selector: Selector("newFrame:"))
    timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    
  }
  
  //1
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let window = view.window {
      let scale = window.screen.nativeScale
      let layerSize = view.bounds.size
      //2
      view.contentScaleFactor = scale
      metalLayer.frame = CGRectMake(0, 0, layerSize.width, layerSize.height)
      metalLayer.drawableSize = CGSizeMake(layerSize.width * scale, layerSize.height * scale)
    }
    projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degreesToRad(85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
  }

  func render() {
    if let drawable = metalLayer.nextDrawable(){
      self.metalViewControllerDelegate?.renderObjects(drawable)
    }
  }
  
  
  func newFrame(displayLink: CADisplayLink){
    
    if lastFrameTimestamp == 0.0
    {
      lastFrameTimestamp = displayLink.timestamp
    }
    
    let elapsed:CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
    lastFrameTimestamp = displayLink.timestamp
    
    gameloop(timeSinceLastUpdate: elapsed)
  }
  
  func gameloop(timeSinceLastUpdate timeSinceLastUpdate: CFTimeInterval) {
    
    self.metalViewControllerDelegate?.updateLogic(timeSinceLastUpdate)
    
    autoreleasepool {
      self.render()
    }
  }

}

