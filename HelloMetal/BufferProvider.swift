//
//  BufferProvider.swift
//  HelloMetal
//
//  Created by Павел Шестаков on 09.12.15.
//  Copyright © 2015 Павел Шестаков. All rights reserved.
//

import UIKit

class BufferProvider: NSObject {
  let inflightBuffersCount: Int
  private var uniformsBuffers: [MTLBuffer]
  private var avaliableBufferIndex: Int = 0
  var avaliableResourcesSemaphore:dispatch_semaphore_t
  
  init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {
    
    avaliableResourcesSemaphore = dispatch_semaphore_create(inflightBuffersCount)
    
    self.inflightBuffersCount = inflightBuffersCount
    uniformsBuffers = [MTLBuffer]()
    
    for _ in 0...inflightBuffersCount-1{
      let uniformsBuffer = device.newBufferWithLength(sizeOfUniformsBuffer, options: MTLResourceOptions.init(rawValue: 0))
      uniformsBuffers.append(uniformsBuffer)
    }
  }
  
  deinit{
    for _ in 0...self.inflightBuffersCount{
      dispatch_semaphore_signal(self.avaliableResourcesSemaphore)
    }
  }
  
  func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4) -> MTLBuffer {
    
    let buffer = uniformsBuffers[avaliableBufferIndex]
    
    let bufferPointer = buffer.contents()
    
    memcpy(bufferPointer, modelViewMatrix.raw(), sizeof(Float)*Matrix4.numberOfElements())
    memcpy(bufferPointer + sizeof(Float)*Matrix4.numberOfElements(), projectionMatrix.raw(), sizeof(Float)*Matrix4.numberOfElements())
    
    avaliableBufferIndex++
    if avaliableBufferIndex == inflightBuffersCount{
      avaliableBufferIndex = 0
    } 
    
    return buffer
  }
}
