//
//  KTBox2DController.m
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KTPhysicsController+b2dJson.h"
#import "B2dJsonBox2DController.h"
#import "B2dJsonBox2DWorldModel.h"
@implementation KTPhysicsController(b2dJson)


+(KTPhysicsController*) physicsControllerWithB2dJsonFile:(NSString*)filename
                                     parentViewController:(KTController*)parentController
                                       pixelToMeterRatio:(float)ratio
{
	return [[B2dJsonBox2DController alloc] initWithB2dJsonFilename:filename
                                              parentViewController:parentController
                                                 pixelToMeterRatio:ratio];
}
// 
+(bool) loadOtherB2dJsonFile:(NSString*)filename toTheExitedPhysicsController:(KTPhysicsController*) curController{
    bool bResult = false;
    if ([curController isKindOfClass:[B2dJsonBox2DController class]]){
        bResult =[(B2dJsonBox2DController*)curController loadOtherB2dJsonFile:filename];
    }
	else
	{
		NSAssert1(nil, @"unsupported physicsController class: %@ for b2dJson", NSStringFromClass([curController class]));
	}
    return bResult;
}

@end

