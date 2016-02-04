//
//  OpenGLView.h
//  Cubes
//
//  Created by Rob Eberhardt on 2/3/16.
//  Copyright © 2016 Rob Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "ksMatrix.h"
#import "ParticleManager.h"

@interface OpenGLView : UIView <ParticleManagerDelegate>
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _renderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programHandle;
    GLuint _positionSlot;
    GLuint _modelViewSlot;
    GLuint _projectionSlot;
    GLuint _colorSlot;
    
    ksMatrix4 _modelViewMatrix;
    ksMatrix4 _projectionMatrix;
    
    ksMatrix4 _cubeModelViewMatrix;
    ksMatrix4 _cube2ModelViewMatrix;
}

@property (nonatomic, assign) int cubeCount;

-(void)render;
-(void)cleanup;
-(void)toggleDisplayLink;

@end
