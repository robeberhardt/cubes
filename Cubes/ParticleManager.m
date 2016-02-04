//
//  ParticleManager.m
//  Cubes
//
//  Created by Rob Eberhardt on 2/3/16.
//  Copyright © 2016 Rob Eberhardt. All rights reserved.
//

#import "ParticleManager.h"
#import "Particle.h"

#define MAX_PARTICLE_COUNT 10000
#define MAX_AGE 200

#define ARC4RANDOM_MAX      0x100000000

@implementation ParticleManager

+ (ParticleManager *)sharedInstance
{
    static ParticleManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ParticleManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)setup
{
    NSLog(@"ParticleManager setup");
    _particles = [[NSMutableArray alloc] initWithCapacity:MAX_PARTICLE_COUNT];
    for (int i = 0; i < MAX_PARTICLE_COUNT; i++)
    {
//        NSLog(@"creating particle %d", i);
        ksVec3 pos, rot;
        ksVec4 col;
        pos.x = [self randomParticleValue] * 10 - 5;
        pos.y = [self randomParticleValue] * 10 - 5;
        pos.z = -5.5 + ([self randomParticleValue] * 2 - 1);
        rot.x = [self randomParticleValue] * 2 - 1;
        rot.y = [self randomParticleValue] * 2 - 1;
        rot.z = [self randomParticleValue] * 2 - 1;
        col.x = [self randomParticleValue];
        col.y = [self randomParticleValue];
        col.z = [self randomParticleValue];
        Particle *p = [[Particle alloc] initWithPosition:pos rotation:rot color:col];
        p.pID = i;
        p.pScale = [self randomParticleValue] * 1.2;
        [_particles addObject:p];
    }
    [_delegate particlesInitialized];
}

-(float)randomParticleValue
{
    return ((float)arc4random() / ARC4RANDOM_MAX);
}

@end
