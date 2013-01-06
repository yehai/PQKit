//
//  B2dJsonBox2DController.m
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "B2dJsonBox2DController.h"
#import "b2dJson.h"
#import "Box2D.h"
#import "KTBox2DBody.h"
#import "KTBox2DShape.h"
#import "B2dJsonBox2DWorldModel.h"


@implementation B2dJsonBox2DController

// IMPORTANT: avoid adding/overriding init and dealloc methods!
// To load resources, init other objects, set property values use the appropriate 
// callback functions below. 
#pragma mark - 
-(id)initWithB2dJsonFilename:(NSString*)filename
         parentViewController:(KTController*)controller
           pixelToMeterRatio:(float)ratio
{
    if ([self init]) {
        strFilename_ = filename;
        parentViewController_ = controller;
        ratio_ = ratio;
    }
    return self;
}
// qiup added at 2012-12-28
-(bool) loadOtherB2dJsonFile:(NSString*)filename
{
    b2World* world_ = NULL;
    world_ = ((B2dJsonBox2DWorldModel*)self.model).world;
    NSAssert(world_, @"the world has not exited!");
    b2dJson json(self,parentViewController_,false);
	std::string errorMsg;
    if (json.loadIntoExistingWorld(world_, [filename UTF8String], errorMsg)) {
        return true;
    }else{
        NSLog(@"b2djson read file Error: %@", [NSString stringWithUTF8String:errorMsg.c_str()]);
        return false;
    }
}
#pragma mark World

-(void) createWorld
{
    b2dJson json(self,parentViewController_,false);
	std::string errorMsg;
    b2World* world_  = json.readFromFile([strFilename_ UTF8String] , errorMsg);
    if (!world_) {
        NSLog(@"b2djson read file Error: %@", [NSString stringWithUTF8String:errorMsg.c_str()]);
    }else{
        ((B2dJsonBox2DWorldModel*)self.model).world = world_;
    }
}

-(void) destroyWorld
{
    b2World* pWorld = ((B2dJsonBox2DWorldModel*)self.model).world;
    if (pWorld) {
        delete pWorld;
        ((B2dJsonBox2DWorldModel*)self.model).world = NULL;
    }	
}

-(void) performAddBody:(KTBox2DBody*)physicsBody
{
    b2World* pWorld = ((B2dJsonBox2DWorldModel*)self.model).world;
    NSAssert1(pWorld, @"Box2D world is not initialized yet! Run this method *after* presenting the scene.", self);
    float pixelsToMeterRatio_ = ((B2dJsonBox2DWorldModel*)self.model).pixelsToMeterRatio;
    b2BodyDef bodyDef;
	bodyDef.position = b2Vec2(physicsBody.position.x / pixelsToMeterRatio_, physicsBody.position.y / pixelsToMeterRatio_);
	bodyDef.angle = CC_DEGREES_TO_RADIANS(physicsBody.rotation);
	
	switch (physicsBody.bodyType)
	{
		case kPhysicsBodyTypeDynamic:
        bodyDef.type = b2_dynamicBody;
        break;
		case kPhysicsBodyTypeKinematic:
        bodyDef.type = b2_kinematicBody;
        break;
		case kPhysicsBodyTypeStatic:
        bodyDef.type = b2_staticBody;
        break;
	}
	
	// using defaults for now
	bodyDef.allowSleep = physicsBody.isSleepingAllowed;
	CGPoint linearVelocity = physicsBody.linearVelocity;
	bodyDef.linearVelocity = b2Vec2(linearVelocity.x, linearVelocity.y);
	bodyDef.linearDamping = physicsBody.linearDamping;
	bodyDef.angularVelocity = physicsBody.angularVelocity;
	bodyDef.angularDamping = physicsBody.angularDamping;
	bodyDef.active = physicsBody.isActive;
	bodyDef.awake = physicsBody.isAwake;
	bodyDef.bullet = physicsBody.preventTunneling;
	bodyDef.fixedRotation = physicsBody.isFixedRotation;
	bodyDef.gravityScale = physicsBody.gravityScale;
	
	b2Body* body = pWorld->CreateBody(&bodyDef);
	body->SetUserData((__bridge void*)physicsBody);
	
//    physicsBody->_shapes;
//    for (KTBox2DShape* shape in physicsBody.shapes) {
//    }
	b2FixtureDef fixtureDef;
	fixtureDef.density = physicsBody.firstShape.density;
	fixtureDef.friction = physicsBody.firstShape.friction;
	fixtureDef.restitution = physicsBody.firstShape.bounce;
	
	switch (physicsBody.firstShape.shapeType)
	{
		case kPhysicsShapeTypeCircle:
		{
//        b2CircleShape circleShape;
//        circleShape.m_radius = physicsBody.firstShape.radius;
//        fixtureDef.shape = &circleShape;
        break;
		}
		case kPhysicsShapeTypeSquare:
		{
        NSAssert(nil, @"square shape not implemented");
        break;
		}
		case kPhysicsShapeTypeRect:
		{
        NSAssert(nil, @"rect shape not implemented");
        break;
		}
		case kPhysicsShapeTypePolygon:
		{
        NSAssert(nil, @"polygon shape not implemented");
        break;
		}
        default:break;
	}
	
	b2Fixture* fixture = body->CreateFixture(&fixtureDef);
	fixture->SetUserData((__bridge void*)physicsBody);
	
	physicsBody.box2dBody = body;

}

-(b2Fixture*) touchBody:(b2Body*)body withShap:(KTBox2DShape*) shape
{
    
    b2FixtureDef fixtureDef;
	fixtureDef.density = shape.density;
	fixtureDef.friction = shape.friction;
	fixtureDef.restitution = shape.bounce;
//    fixtureDef.filter.categoryBits = shape.filter.categoryBits;
//    fixtureDef.filter.maskBits = shape.filter.maskBits;
//    fixtureDef.filter.groupIndex = shape.filter.groupIndex;
	
	switch (shape.shapeType)
	{
		case kPhysicsShapeTypeCircle:
		{
//        b2CircleShape circleShape;
//        circleShape.m_radius = physicsBody.firstShape.radius;
//        fixtureDef.shape = &circleShape;
        break;
		}
		case kPhysicsShapeTypeSquare:
		{
        NSAssert(nil, @"square shape not implemented");
        break;
		}
		case kPhysicsShapeTypeRect:
		{
        NSAssert(nil, @"rect shape not implemented");
        break;
		}
		case kPhysicsShapeTypePolygon:
		{
        NSAssert(nil, @"polygon shape not implemented");
        break;
		}
        default:break;
	}
	
//	b2Fixture* fixture = body->CreateFixture(&fixtureDef);
    return  nil;
}

-(void) performRemoveBody:(KTPhysicsBody*)physicsBody
{
}
#pragma mark Controller Callbacks

// Executed after controller is first allocated and initialized.
// Add subcontrollers, set createModelBlock and loadViewBlock here.
-(void) initWithDefaults
{
    self.createModelBlock = ^{
        B2dJsonBox2DWorldModel* ret = [B2dJsonBox2DWorldModel model];
        ret.pixelsToMeterRatio = ratio_;
        return ret;
    };
}

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

// Executed every frame, unless self.nextStep is set greater than stepInfo.currentStep
-(void) step:(KTStepInfo *)stepInfo
{
	// example: this pauses step methods for 200 steps, effentively creating a 200-step interval
    if (self.model) {
        
        b2World* world = ((B2dJsonBox2DWorldModel*)self.model).world;
        if (world)
            {
            world->Step(self.timeStep, ((B2dJsonBox2DWorldModel*)self.model).velocityIterations, ((B2dJsonBox2DWorldModel*)self.model).positionIterations);
            }
    }
}

/*
// Executed after the step method
-(void) afterStep:(KTStepInfo *)stepInfo
{
}
*/
@end
