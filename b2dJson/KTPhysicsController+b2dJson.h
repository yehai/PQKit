//
//  KTBox2DController.h
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KTPhysicsController.h"
@interface KTPhysicsController(b2dJson)
{
@protected
@private
}
// qiup added at 2012-12-30
// 不同分辨率下ratio不同
+(id) physicsControllerWithB2dJsonFile:(NSString*)filename
                  parentViewController:(KTController*)parentController
                     pixelToMeterRatio:(float) ratio;
// qiup added at 2012-12-28
+(bool) loadOtherB2dJsonFile:(NSString*)filename
toTheExitedPhysicsController:(KTPhysicsController*) curController;

// telecomadmin
// nE7jA%5m
@end
