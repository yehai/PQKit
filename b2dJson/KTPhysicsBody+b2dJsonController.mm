//
//  KTPhysicsBody+b2dJsonController.m
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KTPhysicsBody+b2dJsonController.h"
#import "B2dJsonBox2DController.h"


@implementation KTPhysicsBody(b2dJson)

// IMPORTANT: avoid adding/overriding init and dealloc methods!
// To load resources, init other objects, set property values use the appropriate 
// callback functions below. 
+(id) bodyWithB2dJsonBox2DController:(B2dJsonBox2DController*)physicsController{
    return [[self alloc]initWithB2dJsonBox2DController:physicsController];
}

-(id) initWithB2dJsonBox2DController:(B2dJsonBox2DController*)physicsController{
    return [self initWithPhysicsController:physicsController];
}
#pragma mark Controller Callbacks

/*
// Executed after controller is first allocated and initialized.
// Add subcontrollers, set createModelBlock and loadViewBlock here.
-(void) initWithDefaults
{
}
*/

/* 
// At this point the model is already initialized. Update the controller based on model.
-(void) load
{
}
*/

/* 
// Unload controller (private) resources here. The view and model are unloaded automatically.
// The controller's unload method is executed after the model's unload method.
-(void) unload
{
}
*/

/*
// Runs just before the sceneViewController is replaced with a new one. 
// The self.sceneViewController property still points to the previous sceneViewController.
// Mainly used by game controllers to perform cleanup when the scene is about to change.
-(void) sceneWillChange
{
}
*/

/*
// Runs just after the previous sceneViewController has been replaced with a new one.
// The self.sceneViewController property already points to the new sceneViewController.
-(void) sceneDidChange
{
}
*/

#pragma mark Step

/*
// Executed before step and afterStep
-(void) beforeStep:(KTStepInfo *)stepInfo
{
}
*/

/*
// Executed every frame, unless self.nextStep is set greater than stepInfo.currentStep
-(void) step:(KTStepInfo *)stepInfo
{
	// example: this pauses step methods for 200 steps, effentively creating a 200-step interval
	self.nextStep = stepInfo.currentStep + 200;
}
*/

/*
// Executed after the step method
-(void) afterStep:(KTStepInfo *)stepInfo
{
}
*/

@end
