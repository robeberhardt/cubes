//
//  Particle.h
//  Cubes
//
//  Created by Rob Eberhardt on 2/3/16.
//  Copyright © 2016 Rob Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ksVector.h"
#import "ksMatrix.h"

@interface Particle : NSObject

@property int pID;
@property (nonatomic, assign) ksVec3 pPosition;
@property ksVec3 pRotation;
@property ksVec4 pColor;
@property int age;
@property ksMatrix4 pModelMatrix;
@property float pScale;

-(id)initWithPosition:(ksVec3)position rotation:(ksVec3)rotation color:(ksVec4)color;
- (NSString *)description;

@end
