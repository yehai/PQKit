//
//  KTPhysicsDebugViewController+b2dJson.m
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KTPhysicsDebugViewController+b2dJson.h"
#import "B2dJsonBox2dDebugViewController.h"
#import "B2dJsonBox2DController.h"
@implementation KTPhysicsDebugViewController(b2dJson)

+(id) physicsDebugViewControllerWithB2dJsonBox2DController:(B2dJsonBox2DController*)physicsController{
    return [[B2dJsonBox2dDebugViewController alloc] initWithPhysicsController:physicsController];
}

@end
