//
//  ParticleManager.h
//  Cubes
//
//  Created by Rob Eberhardt on 2/3/16.
//  Copyright © 2016 Rob Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ksMatrix.h"

@class ParticleManagerDelegate;
@protocol ParticleManagerDelegate <NSObject>
@required
- (void)particlesInitialized;
@end

@interface ParticleManager : NSObject
@property (nonatomic) NSMutableArray *particles;
@property (nonatomic, weak) id <ParticleManagerDelegate> delegate;
+ (ParticleManager *)sharedInstance;

-(void)setup;

@end
