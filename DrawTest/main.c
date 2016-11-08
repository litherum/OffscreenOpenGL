//
//  main.c
//  OpenGLTest
//
//  Created by Litherum on 11/8/16.
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

    printf("%s\n", glGetString(GL_VERSION));
    assert(glGetError() == GL_NO_ERROR);

    GLint numExtensions = 0;
    glGetIntegerv(GL_NUM_EXTENSIONS, &numExtensions);
    assert(glGetError() == GL_NO_ERROR);
    for (GLint i = 0; i < numExtensions; ++i) {
        const GLubyte* extension = glGetStringi(GL_EXTENSIONS, i);
        assert(glGetError() == GL_NO_ERROR);
        printf("%s\n", extension);
    }

    int width = 8;
    int height = 8;

    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    assert(glGetError() == GL_NO_ERROR);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    assert(glGetError() == GL_NO_ERROR);

    GLuint renderbuffer;
    glGenRenderbuffers(1, &renderbuffer);
    assert(glGetError() == GL_NO_ERROR);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    assert(glGetError() == GL_NO_ERROR);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, width, height);
    assert(glGetError() == GL_NO_ERROR);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
    assert(glGetError() == GL_NO_ERROR);

    GLenum drawBuffers[] = { GL_COLOR_ATTACHMENT0 };
    glDrawBuffers(1, drawBuffers);
    assert(glGetError() == GL_NO_ERROR);

    GLenum framebufferStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    assert(glGetError() == GL_NO_ERROR);
    assert(framebufferStatus == GL_FRAMEBUFFER_COMPLETE);

    glActiveTexture(GL_TEXTURE0);
    assert(glGetError() == GL_NO_ERROR);
    GLuint texture;
    glGenTextures(1, &texture);
    assert(glGetError() == GL_NO_ERROR);
    glBindTexture(GL_TEXTURE_2D, texture);
    assert(glGetError() == GL_NO_ERROR);
    float* textureData = malloc(width * height * 4 * sizeof(float));
    assert(textureData != NULL);
    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            textureData[i * width * 4 + j * 4 + 0] = 0.3f;
            textureData[i * width * 4 + j * 4 + 1] = 0.4f;
            textureData[i * width * 4 + j * 4 + 2] = 0.5f;
            textureData[i * width * 4 + j * 4 + 3] = 0.6f;
        }
    }
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, width, height, 0, GL_RGBA, GL_FLOAT, textureData);
    assert(glGetError() == GL_NO_ERROR);
    free(textureData);
    /*float* textureData2 = malloc((width / 2) * (height / 2) * 4 * sizeof(float));
    for (int i = 0; i < (height / 2); ++i) {
        for (int j = 0; j < (width / 2); ++j) {
            textureData2[i * (width / 2) * 4 + j * 4 + 0] = 0.7f;
            textureData2[i * (width / 2) * 4 + j * 4 + 1] = 0.8f;
            textureData2[i * (width / 2) * 4 + j * 4 + 2] = 0.9f;
            textureData2[i * (width / 2) * 4 + j * 4 + 3] = 1.0f;
        }
    }
    glTexImage2D(GL_TEXTURE_2D, 1, GL_RGBA32F, width / 2, height / 2, 0, GL_RGBA, GL_FLOAT, textureData2);
    assert(glGetError() == GL_NO_ERROR);
    free(textureData2);*/
    unsigned char* textureData2 = malloc((width / 2) * (height / 2) * 4 * sizeof(unsigned char));
    for (int i = 0; i < (height / 2); ++i) {
        for (int j = 0; j < (width / 2); ++j) {
            textureData2[i * (width / 2) * 4 + j * 4 + 0] = 1;
            textureData2[i * (width / 2) * 4 + j * 4 + 1] = 128;
            textureData2[i * (width / 2) * 4 + j * 4 + 2] = 0;
            textureData2[i * (width / 2) * 4 + j * 4 + 3] = 255;
        }
    }
    glTexImage2D(GL_TEXTURE_2D, 1, GL_RGBA32F, width / 2, height / 2, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData2);
    assert(glGetError() == GL_NO_ERROR);
    free(textureData2);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    assert(glGetError() == GL_NO_ERROR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    assert(glGetError() == GL_NO_ERROR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    assert(glGetError() == GL_NO_ERROR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    assert(glGetError() == GL_NO_ERROR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);
    assert(glGetError() == GL_NO_ERROR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 1);
    assert(glGetError() == GL_NO_ERROR);

    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    assert(glGetError() == GL_NO_ERROR);
    char* vertexShaderSource = "#version 150\n"
    "\n"
    "in vec2 position;\n"
    "out vec2 textureCoordinate;\n"
    "\n"
    "void main() {\n"
    "    gl_Position = vec4(position, 0, 1);\n"
    "    textureCoordinate = (position + 1.0) / 2.0;\n"
    "}\n"
    "";
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    assert(glGetError() == GL_NO_ERROR);
    glCompileShader(vertexShader);
    assert(glGetError() == GL_NO_ERROR);
    GLint compileStatus;
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &compileStatus);
    assert(glGetError() == GL_NO_ERROR);
    assert(compileStatus == GL_TRUE);

    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    assert(glGetError() == GL_NO_ERROR);
    char* fragmentShaderSource = "#version 150\n"
    "\n"
    "uniform sampler2D tex;\n"
    "in vec2 textureCoordinate;\n"
    "out vec4 color;\n"
    "\n"
    "void main() {\n"
    //"    color = textureLod(tex, textureCoordinate, 1.0);\n"
    "    color = texelFetch(tex, ivec2(0, 0), 1);\n"
    "}\n"
    "";
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    assert(glGetError() == GL_NO_ERROR);
    glCompileShader(fragmentShader);
    assert(glGetError() == GL_NO_ERROR);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &compileStatus);
    assert(glGetError() == GL_NO_ERROR);
    assert(compileStatus == GL_TRUE);

    GLuint program = glCreateProgram();
    assert(glGetError() == GL_NO_ERROR);
    glAttachShader(program, vertexShader);
    assert(glGetError() == GL_NO_ERROR);
    glAttachShader(program, fragmentShader);
    assert(glGetError() == GL_NO_ERROR);
    glBindFragDataLocation(program, 0, "color");
    assert(glGetError() == GL_NO_ERROR);
    glLinkProgram(program);
    assert(glGetError() == GL_NO_ERROR);
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    assert(glGetError() == GL_NO_ERROR);
    assert(linkStatus == GL_TRUE);
    glUseProgram(program);
    assert(glGetError() == GL_NO_ERROR);

    GLuint buffer;
    glGenBuffers(1, &buffer);
    assert(glGetError() == GL_NO_ERROR);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    assert(glGetError() == GL_NO_ERROR);
    float bufferData[] = { -1.f, -1.f, -1.f, 1.f, 1.f, 1.f, 1.f, 1.f, 1.f, -1.f, -1.f, -1.f };
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 2 * 3 * 2, bufferData, GL_STREAM_DRAW);
    assert(glGetError() == GL_NO_ERROR);

    GLuint vertexArray;
    glGenVertexArrays(1, &vertexArray);
    assert(glGetError() == GL_NO_ERROR);
    glBindVertexArray(vertexArray);
    assert(glGetError() == GL_NO_ERROR);

    GLint uniformLocation = glGetUniformLocation(program, "tex");
    assert(glGetError() == GL_NO_ERROR);
    glUniform1i(uniformLocation, 0);

    GLint attribLocation = glGetAttribLocation(program, "position");
    assert(glGetError() == GL_NO_ERROR);
    glEnableVertexAttribArray(attribLocation);
    assert(glGetError() == GL_NO_ERROR);
    glVertexAttribPointer(attribLocation, 2, GL_FLOAT, 0, 0, NULL);
    assert(glGetError() == GL_NO_ERROR);

    glViewport(0, 0, width, height);
    assert(glGetError() == GL_NO_ERROR);

    glClear(GL_COLOR_BUFFER_BIT);
    assert(glGetError() == GL_NO_ERROR);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    assert(glGetError() == GL_NO_ERROR);

    glReadBuffer(GL_COLOR_ATTACHMENT0);
    assert(glGetError() == GL_NO_ERROR);
    unsigned char* pixels = malloc(width * height * 4);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    assert(glGetError() == GL_NO_ERROR);
    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            printf("(%u, %u, %u, %u) ", (unsigned)pixels[i * width * 4 + j * 4 + 0], (unsigned)pixels[i * width * 4 + j * 4 + 1], (unsigned)pixels[i * width * 4 + j * 4 + 2], (unsigned)pixels[i * width * 4 + j * 4 + 3]);
        }
        printf("\n");
    }
    free(pixels);

    glDeleteVertexArrays(1, &vertexArray);
    assert(glGetError() == GL_NO_ERROR);

    glDeleteBuffers(1, &buffer);
    assert(glGetError() == GL_NO_ERROR);
    
    glDeleteProgram(program);
    assert(glGetError() == GL_NO_ERROR);

    glDeleteShader(fragmentShader);
    assert(glGetError() == GL_NO_ERROR);

    glDeleteShader(vertexShader);
    assert(glGetError() == GL_NO_ERROR);

    glDeleteTextures(1, &texture);
    assert(glGetError() == GL_NO_ERROR);

    glDeleteRenderbuffers(1, &renderbuffer);
    assert(glGetError() == GL_NO_ERROR);

    glDeleteFramebuffers(1, &framebuffer);
    assert(glGetError() == GL_NO_ERROR);

    cglError = CGLDestroyContext(ctx);
    assert(cglError == kCGLNoError);
    return 0;
}
