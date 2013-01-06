//
//  B2dJsonBox2dPhysicsEntityModel.h
//  Kobold2D-Libraries
//
//  Created by qiup on 12-12-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "KoboldTouch.h"
#import "KTPhysicsEntityModel.h"
class b2Body;
@class B2dJsonBox2DController;
@interface B2dJsonBox2dPhysicsEntityModel : KTPhysicsEntityModel
{
@protected
@private
}
// 由于存在b2dJson编辑器中，可以先对图片进行编辑，而后再于body进行绑定。
@property (nonatomic) float originScale;
@property (nonatomic) CGPoint originOffset;
@property (nonatomic) float originRoration;
+(id) physicsEntityModelWithB2dJsonBox2DController:(B2dJsonBox2DController*)physicsController andB2body:(b2Body*)body;
-(id) initWithB2dJsonBox2DController:(B2dJsonBox2DController*)physicsController andB2body:(b2Body*)body;

@end
