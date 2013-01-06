//
//  SMSpriteViewController.h
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-26.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KoboldTouch.h"
#import "statemap.h"

typedef enum
{
    kStandingAnimation = 0,
    kWalkingAnimation,
    kPunchingAnimation
} AnimationType;

@interface SMSpriteViewController : KTSpriteViewController
{
@protected
@private
}
@property (nonatomic) SMCFSMContext* fsm;
-(void)runAnimation:(AnimationType)anim;
@end
