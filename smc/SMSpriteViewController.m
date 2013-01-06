//
//  SMSpriteViewController.m
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-26.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SMSpriteViewController.h"


@implementation SMSpriteViewController

// IMPORTANT: avoid adding/overriding init and dealloc methods!
// To load resources, init other objects, set property values use the appropriate 
// callback functions below. 
-(void)runAnimation:(AnimationType)anim
{
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

#pragma mark View Controller Callbacks

/*
// Executed before loadView, self.rootNode is still nil at this point.
-(void) viewWillLoad
{
}
*/

/*
// Loads the view. Create a custom view by creating an instance of a CCNode class or subclass,
// then assign this view to self.rootNode. After loadView the loadViewBlock is run and the
// self.rootNode is passed into the block as the rootNode parameter.
// The default implementation simply creates a CCNode instance as rootNode, as seen below.
-(void) loadView
{
	self.rootNode = [CCNode node];
}
*/

/*
// Executed after loadView and after the loadViewBlock was executed. The view hierarchy is
// fully set up by this point. You can make final adjustments to the view here, or update the
// view with model data or vice versa.
-(void) viewDidLoad
{
}
*/

/*
// Executed when a new scene is being presented and the current scene will soon disappear.
// If the scene uses a scene transition, then viewWillDisappear is executed when the transition begins.
-(void) viewWillDisappear
{
}
*/

/*
// Executed when the current scene has been removed from the view. self.rootNode is already nil at this point.
// Executed just before controller's unload method is executed.
-(void) viewDidDisappear
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
