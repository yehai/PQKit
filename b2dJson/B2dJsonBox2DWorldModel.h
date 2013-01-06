//
//  B2dJsonBox2DWorldModel.h
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KoboldTouch.h"
#import "Box2D.h"
@interface B2dJsonBox2DWorldModel : KTModel
{
@protected
@private
}
@property (nonatomic) b2World* world;

/** How many velocity iterations each step. Default is 8. */
@property (nonatomic) unsigned int velocityIterations;
/** How many velocity iterations each step. Default is 2. */
@property (nonatomic) unsigned int positionIterations;
/** The pixel to meter ratio. Default is 32.
 \warning: Contrary to popular use, you don't need this anywhere in your code. The Box2D physics controller
 and related classes already perform the pixel-meter conversions for you! */
@property (nonatomic) float pixelsToMeterRatio;

//@property (nonatomic) CGPoint gravity;
//@property (nonatomic) bool allowSleep;
//@property (nonatomic) bool autoClearForces;
//@property (nonatomic) bool warmStarting;
//@property (nonatomic) bool continuousPhysics;
//@property (nonatomic) bool subStepping;
@end
