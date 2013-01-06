//
//  B2dJsonBox2DWorldModel.m
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "B2dJsonBox2DWorldModel.h"
#import "NSCoder+KTCoderCategory.h"

@implementation B2dJsonBox2DWorldModel

#pragma mark Load/Unload


// Executed when model is first initialized. Is NOT executed when model is loaded from archive!
-(void) initWithDefaults
{
    //
    _pixelsToMeterRatio = 32.0f;
    _velocityIterations = 8;
    _positionIterations = 2;
}

// It is good practice to use a const string for archive keys, to avoid possible typos when archiving and loading.
NSString* const kCodingKeyForgravity = @"gravity";
NSString* const kCodingKeyForallowSleep = @"allowSleep";
NSString* const kCodingKeyForautoClearForces = @"autoClearForces";
NSString* const kCodingKeyForwarmStarting = @"warmStarting";
NSString* const kCodingKeyForcontinuousPhysics = @"continuousPhysics";
NSString* const kCodingKeyForsubStepping = @"subStepping";

NSString* const kCodingKeyFor_pixelsToMeterRatio = @"pixelsToMeterRatio";
NSString* const kCodingKeyFor_velocityIterations = @"velocityIterations";
NSString* const kCodingKeyFor_positionIterations = @"positionIterations";



// Executed when model is loaded from archive. Use this to load model data from an archive.
-(void) initWithArchive:(NSKeyedUnarchiver *)aDecoder archiveVersion:(int)archiveVersion
{
    CGPoint cp = [aDecoder decodeCGPointForKey:kCodingKeyForgravity];
    self.world = new b2World(b2Vec2(cp.x,cp.y));

    self.world->SetAllowSleeping([aDecoder decodeBoolForKey:kCodingKeyForallowSleep]);
    self.world->SetAutoClearForces([aDecoder decodeBoolForKey:kCodingKeyForautoClearForces]);
    self.world->SetWarmStarting([aDecoder decodeBoolForKey:kCodingKeyForwarmStarting]);
    self.world->SetSubStepping([aDecoder decodeBoolForKey:kCodingKeyForsubStepping]);
    
    self.pixelsToMeterRatio = [aDecoder decodeFloatForKey:kCodingKeyFor_pixelsToMeterRatio];
    self.velocityIterations = [aDecoder decodeInt32ForKey:kCodingKeyFor_velocityIterations];
    self.positionIterations = [aDecoder decodeInt32ForKey:kCodingKeyFor_positionIterations];
    
}

// Executed when model is being saved (encoded) to an archive. Use this to save your model's data.
-(void) archiveWithCoder:(NSKeyedArchiver *)aCoder
{
	// how to encode a BOOL property
    if (self.world) {
        [aCoder encodeCGPoint:CGPointMake(self.world->GetGravity().x,self.world->GetGravity().y) forKey:kCodingKeyForgravity];
        [aCoder encodeBool:self.world->GetAllowSleeping() forKey:kCodingKeyForallowSleep];
        [aCoder encodeBool:self.world->GetAutoClearForces() forKey:kCodingKeyForautoClearForces];
        [aCoder encodeBool:self.world->GetWarmStarting() forKey:kCodingKeyForwarmStarting];
        [aCoder encodeBool:self.world->GetContinuousPhysics() forKey:kCodingKeyForcontinuousPhysics];
        [aCoder encodeBool:self.world->GetSubStepping() forKey:kCodingKeyForsubStepping];
        
        [aCoder encodeFloat:self.pixelsToMeterRatio forKey:kCodingKeyFor_pixelsToMeterRatio];
        [aCoder encodeInt32:self.velocityIterations forKey:kCodingKeyFor_velocityIterations];
        [aCoder encodeInt32:self.positionIterations forKey:kCodingKeyFor_positionIterations];
    }
}

/*
 // Executed after model has been initialized or loaded from archive. Use this for common setup code.
 -(void) load
 {
 }
 */

/*
 // Unload private resources of the model.
 // The model's unload method is executed before the controller's unload method.
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
