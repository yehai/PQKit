//
//  KTPhysicsBody+b2dJsonController.h
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KoboldTouch.h"
@class B2dJsonBox2DController;
@interface KTPhysicsBody(b2dJson)
{
@protected
@private
}
+(id) bodyWithB2dJsonBox2DController:(B2dJsonBox2DController*)physicsController;
-(id) initWithB2dJsonBox2DController:(B2dJsonBox2DController*)physicsController; // Not to be used directly!

@end
