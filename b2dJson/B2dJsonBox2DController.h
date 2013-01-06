//
//  B2dJsonBox2DController.h
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KoboldTouch.h"
#include <Box2D/Box2D.h>
@interface B2dJsonBox2DController : KTPhysicsController
{
@protected
@private
    NSString* strFilename_;
    KTController* parentViewController_;
    float ratio_;
}

-(id)initWithB2dJsonFilename:(NSString*)filename
        parentViewController:(KTController*)controller
           pixelToMeterRatio:(float) ratio;
-(bool) loadOtherB2dJsonFile:(NSString*)filename;
@end
