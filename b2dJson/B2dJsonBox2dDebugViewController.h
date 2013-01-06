//
//  B2dJsonBox2dDebugViewController.h
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KoboldTouch.h"
#import "GLES-Render.h"
#include "Box2D.h"
@class B2dJsonBox2DController;
// internal use only
@interface B2dJsonBox2DDebugDrawNode : CCNode
@property (nonatomic) b2World* world;
@end

@interface B2dJsonBox2dDebugViewController : KTPhysicsDebugViewController
{
@protected
@private
    GLESDebugDraw* _debugDraw;

}
-(id) initWithPhysicsController:(B2dJsonBox2DController*)controller;
@property (nonatomic, weak) B2dJsonBox2DController* physicsController;

@end
