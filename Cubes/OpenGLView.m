//
//  OpenGLView.m
//  Cubes
//
//  Created by Rob Eberhardt on 2/3/16.
//  Copyright © 2016 Rob Eberhardt. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"
#import "ParticleManager.h"
#import "Particle.h"

@implementation OpenGLView 
{
    float _rotateCube;
    CADisplayLink * _displayLink;
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 4.0;
        
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
        [self setupProjection];
        [self setupBuffers];
        [self setupTransform];
        
        [ParticleManager sharedInstance].delegate = self;
        [[ParticleManager sharedInstance] setup];
    }
    
    return self;
}

-(void)particlesInitialized
{
    NSLog(@"particles initialized");
    
    [self toggleDisplayLink];
}

-(void) setupLayer
{
    _eaglLayer = (CAEAGLLayer *) self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil
                                    ];
}

-(void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
    {
        NSLog(@"Couldn't init OpenGLES 2.0 Context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context])
    {
        _context = nil;
        NSLog(@"Couldn't set openGL current context");
        exit(1);
    }
}

-(void)setupProgram
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    
    _programHandle = [GLESUtils loadProgram:vertexShaderPath withFragmentShaderFilepath:fragmentShaderPath];
    if (_programHandle == 0)
    {
        NSLog(@"Error loading shaders.");
        return;
    }
    
    glUseProgram(_programHandle);
    
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _colorSlot = glGetAttribLocation(_programHandle, "vSourceColor");
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
}

-(void)setupProjection
{
    float aspectRatio = self.frame.size.width / self.frame.size.height;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 110.0, aspectRatio, 1.0f, 10.0f);
    
    ksMatrixTranslate(&_projectionMatrix, 10.0, 0.0, 0.0);
    ksMatrixScale(&_projectionMatrix, 4.0, 1.0, 1.0);
    
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
    glEnable(GL_CULL_FACE);
}

-(void)drawCube:(ksColor) color
{
    GLfloat vertices[] = {
        0.0f, -0.5f, 0.5f,
        0.0f, 0.5f, 0.5f,
        1.0f, 0.5f, 0.5f,
        1.0f, -0.5f, 0.5f,
        
        1.0f, -0.5f, -0.5f,
        1.0f, 0.5f, -0.5f,
        0.0f, 0.5f, -0.5f,
        0.0f, -0.5f, -0.5f,
    };
    
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 5, 5, 6, 6, 7, 7, 4,
        0, 7, 1, 6, 2, 5, 3, 4
    };
    
    // source color
    glVertexAttrib4f(_colorSlot, color.r, color.g, color.b, color.a);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}

-(void)setupTransform
{
    NSLog(@"setup transform");
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksMatrixTranslate(&_modelViewMatrix, -0.0, 0.0, -5.5);
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);

}

-(void)updateTransform
{
    ksMatrixLoadIdentity(&_cubeModelViewMatrix);
    ksMatrixTranslate(&_cubeModelViewMatrix, 0.0, 0.0, -5.5);
    ksMatrixRotate(&_cubeModelViewMatrix, _rotateCube, 1.0, 1.0, 0.0);
    ksMatrixCopy(&_modelViewMatrix, &_cubeModelViewMatrix);
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
}

-(void)updateOtherTransform
{
    ksMatrixLoadIdentity(&_cube2ModelViewMatrix);
    ksMatrixTranslate(&_cube2ModelViewMatrix, 1.0, -1.0, -5.5);
    ksMatrixRotate(&_cube2ModelViewMatrix, _rotateCube, 0.0, 1.0, 1.0);
    ksMatrixCopy(&_modelViewMatrix, &_cube2ModelViewMatrix);
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
}

-(void)setupBuffers
{
    // render buffer
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    // frame buffer
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // attach render buffer to frame buffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

-(void)teardownBuffers
{
    glDeleteBuffers(1, &_renderBuffer);
    _renderBuffer = 0;
    
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}

-(void)render
{
    if (_context == nil)
    {
        return;
    }
    
    glClearColor(0.0, 0.0, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    for (int i=0; i < [ParticleManager sharedInstance].currentCount; i++)
    {
        Particle *p = [ParticleManager sharedInstance].particles[i];
        ksColor pColor = { p.pColor.x, p.pColor.y, p.pColor.z, 1.0 };

        ksMatrix4 pMat = p.pModelMatrix;
        ksMatrixLoadIdentity(&pMat);
        ksMatrixTranslate(&pMat, p.pPosition.x, p.pPosition.y, p.pPosition.z);

        // handle rotations
        ksMatrixRotate(&pMat, _rotateCube * p.pRotation.x, 1.0, 0.0, 0.0);
        ksMatrixRotate(&pMat, _rotateCube * p.pRotation.y, 0.0, 1.0, 0.0);
        ksMatrixRotate(&pMat, _rotateCube * p.pRotation.z, 0.0, 0.0, 1.0);

        ksMatrixScale(&pMat, p.pScale, p.pScale, p.pScale);
        ksMatrixCopy(&_modelViewMatrix, &pMat);
        ksMatrixTranslate(&_modelViewMatrix, 15.0, 5.0, -5.5);
        glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);

        [self drawCube:pColor];

    }
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)toggleDisplayLink
{
    if (_displayLink == nil)
    {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

-(void)displayLinkCallback:(CADisplayLink *)displayLink
{
    _rotateCube += displayLink.duration * 50;
    
    [self render];
}

-(void)cleanup
{
    [self teardownBuffers];
    if (_programHandle != 0)
    {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    if (_context && [EAGLContext currentContext] == _context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    _context = nil;
}

@end
