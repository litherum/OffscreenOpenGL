//
//  main.swift
//  OffscreenOpenGL
//
//  Created by Litherum on 8/20/16.
//  Copyright © 2016 Litherum. All rights reserved.
//

import Foundation
import OpenGL
import OpenGL.GL3

var error = kCGLNoError

var onlineRendererID = GLint(0)
var offlineRendererID = GLint(0)

var found = false
for maskBit in 0 ..< sizeof(GLuint) * 8 {
    var rendererInfo = CGLRendererInfoObj()
    var numRenderers = GLint(0)
    error = CGLQueryRendererInfo(UInt32(1 << maskBit), &rendererInfo, &numRenderers)
    if error != kCGLNoError {
        continue
    }
    assert(error == kCGLNoError)
    error = CGLDescribeRenderer(rendererInfo, 0, kCGLRPRendererCount, &numRenderers)
    assert(error == kCGLNoError)
    for renderer in 0 ..< numRenderers {
        var rendererID = GLint(0)
        error = CGLDescribeRenderer(rendererInfo, renderer, kCGLRPRendererID, &rendererID)
        assert(error == kCGLNoError)
        //if rendererID != currentRenderer {
        //    continue
        //}
        print("Found renderer.")
        var offscreen = GLint(0)
        error = CGLDescribeRenderer(rendererInfo, renderer, kCGLRPOffScreen, &offscreen)
        assert(error == kCGLNoError)
        print("Offscreen: \(offscreen)")
        var online = GLint(0)
        error = CGLDescribeRenderer(rendererInfo, renderer, kCGLRPOnline, &online)
        assert(error == kCGLNoError)
        print("Online: \(online)")
        if online != 0 {
            assert(onlineRendererID == 0 || onlineRendererID == rendererID)
            onlineRendererID = rendererID
        } else {
            assert(offlineRendererID == 0 || offlineRendererID == rendererID)
            offlineRendererID = rendererID
        }

        //found = true
        break
    }
    error = CGLDestroyRendererInfo(rendererInfo);
    assert(error == kCGLNoError)
    if found {
        break
    }
}

let attributes = [kCGLPFAColorSize, CGLPixelFormatAttribute(24), kCGLPFAOpenGLProfile, CGLPixelFormatAttribute(kCGLOGLPVersion_GL4_Core.rawValue), kCGLPFARendererID, CGLPixelFormatAttribute(UInt32(offlineRendererID)), kCGLPFAAllowOfflineRenderers, CGLPixelFormatAttribute(0)]
var pixelFormat = CGLPixelFormatObj()
var numScreens = GLint(0)
error = CGLChoosePixelFormat(attributes, &pixelFormat, &numScreens)
assert(error == kCGLNoError)
var context = CGLContextObj()
error = CGLCreateContext(pixelFormat, nil, &context)
assert(error == kCGLNoError)

var currentRenderer = GLint(0)
error = CGLGetParameter(context, kCGLCPCurrentRendererID, &currentRenderer)
assert(error == kCGLNoError)

print("Current renderer: \(currentRenderer)")

error = CGLSetCurrentContext(context)
assert(error == kCGLNoError)

func printGLError() {
    let glError = glGetError()
    print("Error: \(glError)")
    switch glError {
    case GLenum(GL_NO_ERROR):
        print("No error")
    case GLenum(GL_INVALID_ENUM):
        print("Invalid enum")
    case GLenum(GL_INVALID_VALUE):
        print("Invalid value")
    case GLenum(GL_INVALID_OPERATION):
        print("Invalid operation")
    case GLenum(GL_OUT_OF_MEMORY):
        print("Out of memory")
    default:
        print("Unknown error")
    }
}

var majorVersion = GLint(0)
glGetIntegerv(GLenum(GL_MAJOR_VERSION), &majorVersion)
printGLError()
var minorVersion = GLint(0)
glGetIntegerv(GLenum(GL_MINOR_VERSION), &minorVersion)
printGLError()

print("OpenGL \(majorVersion).\(minorVersion)")

let vendorCString = glGetString(GLenum(GL_VENDOR))
printGLError()
let vendorString = String(CString: UnsafePointer<CChar>(vendorCString), encoding: NSASCIIStringEncoding)!
print("Vendor: \(vendorString)")

var framebuffer = GLuint(0)
glGenFramebuffers(1, &framebuffer)
printGLError()
var renderbuffer = GLuint(0)
glGenRenderbuffers(1, &renderbuffer)
printGLError()
glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderbuffer)
printGLError()
glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_RGBA), 1, 1)
printGLError()

glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
printGLError()
glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT2), GLenum(GL_RENDERBUFFER), renderbuffer)
printGLError()

let drawBuffers = [ GLenum(GL_NONE), GLenum(GL_COLOR_ATTACHMENT2) ]
glDrawBuffers(2, drawBuffers);
printGLError()

let framebufferStatus = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
switch framebufferStatus {
case GLenum(GL_FRAMEBUFFER_COMPLETE):
    print("Framebuffer complete")
case GLenum(GL_FRAMEBUFFER_UNDEFINED):
    print("Framebuffer undefined")
case GLenum(GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT):
    print("Framebuffer incomplete attachment")
case GLenum(GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT):
    print("Framebuffer incomplete missing attachment")
case GLenum(GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER):
    print("Framebuffer incomplete draw buffer")
case GLenum(GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER):
    print("Framebuffer incomplete read buffer")
case GLenum(GL_FRAMEBUFFER_UNSUPPORTED):
    print("Framebuffer unsupported")
case GLenum(GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE):
    print("Framebuffer incomplete multisample")
case GLenum(GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS):
    print("Framebuffer incomplete layer targets")
default:
    print("Unknown framebuffer status")
}

let clearColor = [ GLfloat(1), GLfloat(0), GLfloat(0), GLfloat(1) ]
glClearBufferfv(GLenum(GL_COLOR), 1, clearColor)
printGLError()

glReadBuffer(GLenum(GL_COLOR_ATTACHMENT2))
printGLError()
var pixelData = [GLfloat](count: 4, repeatedValue: 0)
glReadPixels(0, 0, 1, 1, GLenum(GL_RGBA), GLenum(GL_FLOAT), &pixelData)
printGLError()
print("Color data: \(pixelData)")

glDeleteRenderbuffers(1, &renderbuffer)
printGLError()
glDeleteFramebuffers(1, &framebuffer)
printGLError()
