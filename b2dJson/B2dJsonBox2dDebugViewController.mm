//
//  B2dJsonBox2dDebugViewController.m
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "B2dJsonBox2dDebugViewController.h"
#import "B2dJsonBox2DController.h"
#import "B2dJsonBox2DWorldModel.h"
@implementation B2dJsonBox2DDebugDrawNode
-(void)draw
{
	if (_world)
        {
//        glViewport(0, 0, 480, 320);
		ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
		kmGLPushMatrix();
		_world->DrawDebugData();
		kmGLPopMatrix();
        }
}
@end

@implementation B2dJsonBox2dDebugViewController

// IMPORTANT: avoid adding/overriding init and dealloc methods!
// To load resources, init other objects, set property values use the appropriate 
// callback functions below. 

#pragma mark Controller Callbacks
-(id) initWithPhysicsController:(B2dJsonBox2DController*)physicsController
{
	self = [super init];
	if (self)
        {
		_physicsController = physicsController;
        }
	return self;
}

-(void) loadView
{
    B2dJsonBox2DWorldModel* worldModel= (B2dJsonBox2DWorldModel*)_physicsController.model;
	_debugDraw = new GLESDebugDraw(worldModel.pixelsToMeterRatio);
    
	unsigned int debugDrawFlags = 0;
	debugDrawFlags += b2Draw::e_shapeBit;
	debugDrawFlags += b2Draw::e_jointBit;
	//debugDrawFlags += b2Draw::e_aabbBit;
	//debugDrawFlags += b2Draw::e_pairBit;
	//debugDrawFlags += b2Draw::e_centerOfMassBit;
	_debugDraw->SetFlags(debugDrawFlags);
    worldModel.world->SetDebugDraw(_debugDraw);
    
	B2dJsonBox2DDebugDrawNode* debugDrawNode = [B2dJsonBox2DDebugDrawNode node];
	debugDrawNode.world = worldModel.world;
    
	self.rootNode = debugDrawNode;
}

-(void) viewWillDisappear
{
    B2dJsonBox2DWorldModel* worldModel= (B2dJsonBox2DWorldModel*)_physicsController.model;

	B2dJsonBox2DDebugDrawNode* debugDrawNode = (B2dJsonBox2DDebugDrawNode*)self.rootNode;
	debugDrawNode.world = NULL;
	
	worldModel.world->SetDebugDraw(NULL);
	
	delete _debugDraw;
	_debugDraw = NULL;
}

@end
