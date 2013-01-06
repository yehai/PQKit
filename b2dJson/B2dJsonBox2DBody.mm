//
//  B2dJsonBox2DBody.m
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "B2dJsonBox2DBody.h"
#import "B2dJsonBox2DController.h"
#import "B2dJsonBox2DWorldModel.h"
@implementation B2dJsonBox2DBody

// IMPORTANT: avoid adding/overriding init and dealloc methods!
// To load resources, init other objects, set property values use the appropriate 
// callback functions below. 

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ box2dBody = %p", [super description], _box2dBody];
}

#pragma mark Controller Callbacks
-(void) setPosition:(CGPoint)position
{
	[super setPosition:position];
	if (_box2dBody)
	{
		float ptmRatio = ((B2dJsonBox2DWorldModel*)((B2dJsonBox2DController*)self.physicsController).model).pixelsToMeterRatio;
		NSAssert1(ptmRatio > 0, @"ptmRatio is <= 0 ... physicsController: %@", self.physicsController);
		_box2dBody->SetTransform(b2Vec2(position.x / ptmRatio, position.y / ptmRatio), _box2dBody->GetAngle());
	}
}
-(CGPoint) position
{
	if (_box2dBody)
	{
		b2Vec2 pos = _box2dBody->GetPosition();
		float ptmRatio = ((B2dJsonBox2DWorldModel*)((B2dJsonBox2DController*)self.physicsController).model).pixelsToMeterRatio;
		NSAssert1(ptmRatio > 0, @"ptmRatio is <= 0 ... physicsController: %@", self.physicsController);
		return CGPointMake(pos.x * ptmRatio, pos.y * ptmRatio);
	}
	return [super position];
}

-(void) setRotation:(float)rotation
{
	[super setRotation:rotation];
	if (_box2dBody)
	{
		_box2dBody->SetTransform(_box2dBody->GetPosition(), rotation);
	}
}
-(float) rotation
{
	if (_box2dBody)
	{
		return _box2dBody->GetAngle();
	}
	return [super rotation];
}

#pragma mark linear velocity/damping
-(void) setLinearVelocity:(CGPoint)linearVelocity
{
	[super setLinearVelocity:linearVelocity];
	if (_box2dBody)
	{
		_box2dBody->SetLinearVelocity(b2Vec2(linearVelocity.x, linearVelocity.y));
	}
}
-(CGPoint) linearVelocity
{
	if (_box2dBody)
	{
		const b2Vec2 velocity = _box2dBody->GetLinearVelocity();
		return CGPointMake(velocity.x, velocity.y);
	}
	return [super linearVelocity];
}

-(void) setLinearDamping:(float)linearDamping
{
	[super setLinearDamping:linearDamping];
	if (_box2dBody)
	{
		_box2dBody->SetLinearDamping(linearDamping);
	}
}
-(float) linearDamping
{
	if (_box2dBody)
	{
		return _box2dBody->GetLinearDamping();
	}
	return [super linearDamping];
}

#pragma mark angular velocity/damping
-(void) setAngularVelocity:(float)angularVelocity
{
	[super setAngularVelocity:angularVelocity];
	if (_box2dBody)
	{
		_box2dBody->SetAngularVelocity(angularVelocity);
	}
}
-(float) angularVelocity
{
	if (_box2dBody)
	{
		return _box2dBody->GetAngularVelocity();
	}
	return [super angularVelocity];
}

-(void) setAngularDamping:(float)angularDamping
{
	[super setAngularDamping:angularDamping];
	if (_box2dBody)
	{
		_box2dBody->SetAngularDamping(angularDamping);
	}
}
-(float) angularDamping
{
	if (_box2dBody)
	{
		return _box2dBody->GetAngularDamping();
	}
	return [super angularDamping];
}

@end
