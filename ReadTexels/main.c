//
//  main.c
//  ReadTexels
//
//  Created by Litherum on 11/10/16.
//  Copyright © 2016 Litherum. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl3.h>

int main(int argc, const char * argv[]) {
    CGLPixelFormatAttribute attribs[] = { kCGLPFAOpenGLProfile, kCGLOGLPVersion_3_2_Core, 0 };
    CGLPixelFormatObj pix;
    GLint npix;
    CGLError cglError = CGLChoosePixelFormat(attribs, &pix, &npix);
    assert(cglError == kCGLNoError);
    CGLContextObj ctx;
    cglError = CGLCreateContext(pix, NULL, &ctx);
    assert(cglError == kCGLNoError);
    cglError = CGLDestroyPixelFormat(pix);
    assert(cglError == kCGLNoError);
    cglError = CGLSetCurrentContext(ctx);
    assert(cglError == kCGLNoError);

    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    assert(glGetError() == GL_NO_ERROR);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    assert(glGetError() == GL_NO_ERROR);

    GLuint texture;
    glGenTextures(1, &texture);
    assert(glGetError() == GL_NO_ERROR);
    glBindTexture(GL_TEXTURE_2D, texture);
    assert(glGetError() == GL_NO_ERROR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    assert(glGetError() == GL_NO_ERROR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    assert(glGetError() == GL_NO_ERROR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    assert(glGetError() == GL_NO_ERROR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    assert(glGetError() == GL_NO_ERROR);

    int width = 8;
    int height = 8;

    GLushort* textureData = malloc(width * height * sizeof(GLushort));
    assert(textureData != NULL);
    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            unsigned value = (i << 11) | ((i + j) << 5) | j;
            textureData[i * width + j] = value;
        }
    }
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB565, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, textureData);
    assert(glGetError() == GL_NO_ERROR);
    free(textureData);

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
    assert(glGetError() == GL_NO_ERROR);

    GLenum framebufferStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    assert(glGetError() == GL_NO_ERROR);
    assert(framebufferStatus == GL_FRAMEBUFFER_COMPLETE);

    glReadBuffer(GL_COLOR_ATTACHMENT0);
    assert(glGetError() == GL_NO_ERROR);

    /*GLushort* readData = malloc(width * height * sizeof(GLushort));
    assert(readData != NULL);
    glReadPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, readData);
    assert(glGetError() == GL_NO_ERROR);
    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            GLushort pixel = readData[i * width + j];
            // AAAA ABBB BBBA AAAA
            printf("(%u %u %u) ", (unsigned)((pixel & 0xF800) >> 11), (unsigned)((pixel & 0x7E0) >> 5), (unsigned)(pixel & 0x1F));
        }
        printf("\n");
    }
    free(readData);*/

    // OpenGL scales the entropy, so that the maximum value that fits in each 5-bit component is scaled so that the output is 255 (when writing out into a GL_UNSIGNED_BYTE)

    GLubyte* readData = malloc(width * height * 3 * sizeof(GLubyte));
    assert(readData != NULL);
    glReadPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, readData);
    assert(glGetError() == GL_NO_ERROR);
    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            GLubyte r = readData[(i * width + j) * 3 + 0];
            GLubyte g = readData[(i * width + j) * 3 + 1];
            GLubyte b = readData[(i * width + j) * 3 + 2];
            printf("(0x%X 0x%X 0x%X) ", (unsigned)r, (unsigned)g, (unsigned)b);
        }
        printf("\n");
    }
    free(readData);

    glDeleteTextures(1, &texture);
    assert(glGetError() == GL_NO_ERROR);

    glDeleteFramebuffers(1, &framebuffer);
    assert(glGetError() == GL_NO_ERROR);

    cglError = CGLDestroyContext(ctx);
    assert(cglError == kCGLNoError);
    return 0;
}
