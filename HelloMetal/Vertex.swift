//
//  Vertex.swift
//  HelloMetal
//
//  Created by Павел Шестаков on 09.12.15.
//  Copyright © 2015 Павел Шестаков. All rights reserved.
//

struct Vertex{
  
  var x,y,z: Float     // position data
  var r,g,b,a: Float   // color data
  var s,t: Float       // texture coordinates
  
  func floatBuffer() -> [Float] {
    return [x,y,z,r,g,b,a,s,t]
  }
  
};
