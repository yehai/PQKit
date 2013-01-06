//
//  B2dJsonBox2dPhysicsEntityModel.m
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "B2dJsonBox2dPhysicsEntityModel.h"
#import "KTBox2DBody.h"
#import "B2dJsonBox2DController.h"
#import "KTPhysicsBody+b2dJsonController.h"
#import "B2dJsonBox2DBody.h"
@implementation B2dJsonBox2dPhysicsEntityModel

#pragma mark Load/Unload
+(id) physicsEntityModelWithB2dJsonBox2DController:(B2dJsonBox2DController*)physicsController andB2body:(b2Body*)body{
    return [[self alloc] initWithB2dJsonBox2DController:physicsController andB2body:body];
}
-(id) initWithB2dJsonBox2DController:(B2dJsonBox2DController*)physicsController andB2body:(b2Body*)body{
    if (self = [super initWithPhysicsController:physicsController]) {
        B2dJsonBox2DBody* ktBody = [B2dJsonBox2DBody bodyWithB2dJsonBox2DController:physicsController];
        ktBody.box2dBody = body;
        self.physicsBody = ktBody;
        _originScale = 1.0;
        _originRoration = 0.0;
        _originOffset = CGPointZero;
    }
    return self;
}
/* 
// Executed when model is first initialized. Is NOT executed when model is loaded from archive!
-(void) initWithDefaults
{
}
*/
NSString* const kCodingKeyFor_originScale = @"_originScale";
NSString* const kCodingKeyFor_originOffset = @"_originOffset";
NSString* const kCodingKeyFor_originRoration = @"_originRoration";


-(void) archiveWithCoder:(NSKeyedArchiver *)aCoder
{
    [super archiveWithCoder:aCoder];
    [aCoder encodeCGPoint:_originOffset forKey:kCodingKeyFor_originOffset];
    [aCoder encodeFloat:_originRoration forKey:kCodingKeyFor_originRoration];
    [aCoder encodeFloat:_originScale forKey:kCodingKeyFor_originScale];
    

}

-(void) initWithArchive:(NSKeyedUnarchiver *)aDecoder archiveVersion:(int)archiveVersion
{
    [super initWithArchive:aDecoder archiveVersion:archiveVersion];
    _originOffset = [aDecoder decodeCGPointForKey:kCodingKeyFor_originOffset];
    _originRoration = [aDecoder decodeFloatForKey:kCodingKeyFor_originRoration];
    _originScale = [aDecoder decodeFloatForKey:kCodingKeyFor_originScale];
}

-(void) setPosition:(CGPoint)position
{
	self.physicsBody.position = ccpSub(position,_originOffset);
}
-(CGPoint) position
{
	return ccpAdd(self.physicsBody.position,_originOffset);
}

-(void) setRotation:(float)rotation
{
	self.physicsBody.rotation = CC_DEGREES_TO_RADIANS((rotation + _originRoration) * -1.0f);
}

-(float) rotation
{
	return CC_RADIANS_TO_DEGREES((self.physicsBody.rotation - _originRoration) * -1.0f);
}
-(void) setScale:(float)scale
{
    [super setScale:_originScale * scale];
}
-(float) scale
{
    return [super scale] * _originScale;
}
/*
// It is good practice to use a const string for archive keys, to avoid possible typos when archiving and loading.
NSString* const kCodingKeyForBoolProperty = @"aBoolProperty";

// Executed when model is loaded from archive. Use this to load model data from an archive.
-(void) initWithArchive:(NSKeyedUnarchiver*)aDecoder archiveVersion:(unsigned int)archiveVersion
{
	// how to decode a BOOL property
	self.aBoolProperty = [aDecoder decodeBoolForKey:kCodingKeyForBoolProperty];
	
	// example: support loading of older archive versions
	if (archiveVersion < 5)
	{
		// set sensible default for previously non-archived data
		self.aBoolProperty = YES;
	}
}

// Executed when model is being saved (encoded) to an archive. Use this to save your model's data.
-(void) archiveWithCoder:(NSKeyedArchiver*)aCoder
{
	// how to encode a BOOL property
	[aCoder encodeBool:self.aBoolProperty forKey:kCodingKeyForBoolProperty];
}
*/

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
