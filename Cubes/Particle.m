//
//  Particle.m
//  Cubes
//
//  Created by Rob Eberhardt on 2/3/16.
//  Copyright © 2016 Rob Eberhardt. All rights reserved.
//

#import "Particle.h"
#import "ksMatrix.h"

@implementation Particle

@synthesize pPosition, pRotation, pColor, pScale, pModelMatrix;

-(id)initWithPosition:(ksVec3)position rotation:(ksVec3)rotation color:(ksVec4)color
{
    self = [super init];
    if (self)
    {
        pPosition = position;
        pRotation = rotation;
        pColor = color;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Particle: id:%d", self.pID];
}


@end
