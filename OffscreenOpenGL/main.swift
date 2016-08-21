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
import IOSurface
import CoreVideo

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

let attributes = [kCGLPFAColorSize, CGLPixelFormatAttribute(24), kCGLPFAOpenGLProfile, CGLPixelFormatAttribute(kCGLOGLPVersion_GL4_Core.rawValue), kCGLPFARendererID, CGLPixelFormatAttribute(UInt32(onlineRendererID)), kCGLPFAAllowOfflineRenderers, kCGLPFASupportsAutomaticGraphicsSwitching, CGLPixelFormatAttribute(0)]
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

var drawBuffers = [ GLenum(GL_NONE), GLenum(GL_COLOR_ATTACHMENT2) ]
glDrawBuffers(2, drawBuffers);
printGLError()

var framebufferStatus = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
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

var clearColor = [ GLfloat(1), GLfloat(0), GLfloat(0), GLfloat(1) ]
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

//CGLTexImageIOSurface2D(ctx: CGLContextObj, _ target: GLenum, _ internal_format: GLenum, _ width: GLsizei, _ height: GLsizei, _ format: GLenum, _ type: GLenum, _ ioSurface: IOSurface, _ plane: GLuint) -> CGLError
var ioSurfaceBytesPerRow = IOSurfaceAlignProperty(kIOSurfaceBytesPerRow, 16)
let properties = [ kIOSurfaceWidth as String : 1, kIOSurfaceHeight as String : 1, kIOSurfacePixelFormat as String : Int(kCVPixelFormatType_32BGRA), kIOSurfaceBytesPerRow as String: ioSurfaceBytesPerRow, kIOSurfaceBytesPerElement as String: 16]
let ioSurface = IOSurfaceCreate(properties)!
let ioSurfacePixelFormat = IOSurfaceGetPixelFormat(ioSurface)
let ioSurfaceAllocSize = IOSurfaceGetAllocSize(ioSurface)
let ioSurfaceBytesPerElement = IOSurfaceGetBytesPerElement(ioSurface)
ioSurfaceBytesPerRow = IOSurfaceGetBytesPerRow(ioSurface)
let ioSurfacePlaneCount = IOSurfaceGetPlaneCount(ioSurface)
print("Usage count: \(IOSurfaceIsInUse(ioSurface))")
print("IOSurface pixel format: \(ioSurfacePixelFormat) \(kCVPixelFormatType_32RGBA)")
print("IOSurface alloc size: \(ioSurfaceAllocSize)")
print("IOSurface bytes per element: \(ioSurfaceBytesPerElement)")
print("IOSurface bytes per row: \(ioSurfaceBytesPerRow)")
print("IOSurface plane count: \(ioSurfacePlaneCount)")

var texture = GLuint(0)
glGenTextures(1, &texture)
printGLError()
glBindTexture(GLenum(GL_TEXTURE_RECTANGLE), texture)
printGLError()
glTexParameteri(GLenum(GL_TEXTURE_RECTANGLE), GLenum(GL_TEXTURE_BASE_LEVEL), 0);
printGLError()
glTexParameteri(GLenum(GL_TEXTURE_RECTANGLE), GLenum(GL_TEXTURE_MAX_LEVEL), 0);
printGLError()
error = CGLTexImageIOSurface2D(context, GLenum(GL_TEXTURE_RECTANGLE), GLenum(GL_RGBA), 1, 1, GLenum(GL_BGRA), GLenum(GL_UNSIGNED_INT_8_8_8_8_REV), ioSurface, 0)
assert(error == kCGLNoError)

glGenFramebuffers(1, &framebuffer)
printGLError()
glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
printGLError()
glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_RECTANGLE), texture, 0)
printGLError()

drawBuffers = [ GLenum(GL_COLOR_ATTACHMENT0) ]
glDrawBuffers(1, drawBuffers);
printGLError()

framebufferStatus = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
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

clearColor = [ GLfloat(0.1), GLfloat(0.5), GLfloat(0), GLfloat(1) ]
glClearBufferfv(GLenum(GL_COLOR), 0, clearColor)
printGLError()

glReadBuffer(GLenum(GL_COLOR_ATTACHMENT0))
printGLError()
pixelData = [GLfloat](count: 4, repeatedValue: 0)
glReadPixels(0, 0, 1, 1, GLenum(GL_RGBA), GLenum(GL_FLOAT), &pixelData)
printGLError()
print("Color data: \(pixelData)")

glDeleteFramebuffers(1, &framebuffer)
printGLError()
glDeleteTextures(1, &texture)
printGLError()
