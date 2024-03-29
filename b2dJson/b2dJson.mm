/*
 * Author: Chris Campbell - www.iforce2d.net
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */
/**
 * remove the image manager & process.
 * Consider the cocos2d have do much for this situation.
 *
 *
 * qiup added at 2012-12-15
 */

#include <istream>
#include <fstream>
#include "b2dJson.h"
#include "json/json.h"
//#include "b2dJsonImage.h"
#import "KoboldTouch.h"
#import "B2dJsonBox2DController.h"
#import "B2dJsonBox2DWorldModel.h"
#import "B2dJsonBox2dPhysicsEntityModel.h"
#import "KTBox2DBody.h"
#import "cocos2d.h"
using namespace std;

//inline bool b2dJsonImage_renderOrder_ascending(const b2dJsonImage* a, const b2dJsonImage* b)
//{
//    return a->renderOrder < b->renderOrder;
//}

b2dJson::b2dJson(B2dJsonBox2DController* koboldtouchController,KTController* parentController ,bool useHumanReadableFloats)
{
    m_useHumanReadableFloats = useHumanReadableFloats;
    m_physicsController = koboldtouchController;
    m_parentViewController = parentController;
}

b2dJson::~b2dJson()
{
    //    for (int i = 0; i < (int)m_images.size(); i++)
    //        delete m_images[i];
}

Json::Value b2dJson::writeToValue(b2World *world)
{
    if (!world)
        return Json::Value();
    
    return b2j(world);
}

std::string b2dJson::writeToString(b2World* world)
{
    if (!world)
        return std::string();
    
    Json::StyledWriter writer;
    return writer.write( b2j(world) );
}

bool b2dJson::writeToFile(b2World* world, const char* filename)
{
    if ( !world || !filename )
        return false;
    
    std::ofstream ofs;
    ofs.open(filename, std::ios::out);
    if (!ofs) {
        std::cout << "Could not open file " << filename << " for writing\n";
        return false;
    }
    
    Json::StyledStreamWriter writer("   ");
    writer.write( ofs, b2j(world) );
    
    ofs.close();
    
    return true;
}

Json::Value b2dJson::b2j(b2World* world)
{
    m_bodyToIndexMap.clear();
    m_jointToIndexMap.clear();
    
    Json::Value worldValue;
    
    vecToJson("gravity", world->GetGravity(), worldValue);
    worldValue["allowSleep"] = world->GetAllowSleeping();
    worldValue["autoClearForces"] = world->GetAutoClearForces();
    worldValue["warmStarting"] = world->GetWarmStarting();
    worldValue["continuousPhysics"] = world->GetContinuousPhysics();
    worldValue["subStepping"] = world->GetSubStepping();
    //worldValue["hasDestructionListener"] = world->HasDestructionListener();
    //worldValue["hasContactFilter"] = world->HasContactFilter();
    //worldValue["hasContactListener"] = world->HasContactListener();
    
    int i =  0;
    for (b2Body* body = world->GetBodyList(); body; body = body->GetNext()) {
        m_bodyToIndexMap[body] = i;
        worldValue["body"][i] =  b2j(body);
        i++;
    }
    
    //need two passes for joints because gear joints reference other joints
    i = 0;
    for (b2Joint* joint = world->GetJointList(); joint; joint = joint->GetNext()) {
        if ( joint->GetType() == e_gearJoint )
            continue;
        worldValue["joint"][i] =  b2j(joint);
        m_jointToIndexMap[joint] = i;
        i++;
    }
    for (b2Joint* joint = world->GetJointList(); joint; joint = joint->GetNext()) {
        if ( joint->GetType() != e_gearJoint )
            continue;
        worldValue["joint"][i] =  b2j(joint);
        m_jointToIndexMap[joint] = i;
        i++;
    }
    // qiup changed at 2012-12-15
    //
    /** old Version **/
    //    i = 0;
    //    {
    //        std::map<b2dJsonImage*,string>::iterator it = m_imageToNameMap.begin();
    //        std::map<b2dJsonImage*,string>::iterator end = m_imageToNameMap.end();
    //        while (it != end) {
    //            b2dJsonImage* image = it->first;
    //            worldValue["image"][i] =  b2j(image);
    //            i++;
    //
    //            ++it;
    //        }
    //    }
    /**     end     */
    
    m_bodyToIndexMap.clear();
    m_jointToIndexMap.clear();
    
    return worldValue;
}

Json::Value b2dJson::b2j(b2Body* body)
{
    Json::Value bodyValue;
    
    string bodyName = getBodyName(body);
    if ( bodyName != "" )
        bodyValue["name"] = bodyName;
    
    bodyValue["type"] = body->GetType();
    switch( body->GetType() )
    {
        case b2_staticBody:
            bodyValue["type"].setComment("//static", Json::commentAfterOnSameLine);
            break;
        case b2_dynamicBody:
            bodyValue["type"].setComment("//dynamic", Json::commentAfterOnSameLine);
            break;
        case b2_kinematicBody:
            bodyValue["type"].setComment("//kinematic", Json::commentAfterOnSameLine);
            break;
    }
    
    vecToJson("position", body->GetPosition(), bodyValue);
    floatToJson("angle", body->GetAngle(), bodyValue );
    
    vecToJson("linearVelocity", body->GetLinearVelocity(), bodyValue);
    floatToJson("angularVelocity", body->GetAngularVelocity(), bodyValue);
    
    if ( body->GetLinearDamping() != 0 )
        floatToJson("linearDamping", body->GetLinearDamping(), bodyValue);
    if ( body->GetAngularDamping() != 0 )
        floatToJson("angularDamping", body->GetAngularDamping(), bodyValue);
    if ( body->GetGravityScale() != 1 )
        floatToJson("gravityScale", body->GetGravityScale(), bodyValue);
    
    if ( body->IsBullet() )
        bodyValue["bullet"] = true;
    if ( ! body->IsSleepingAllowed() )
        bodyValue["allowSleep"] = false;
    if ( body->IsAwake() )
        bodyValue["awake"] = true;
    if ( ! body->IsActive() )
        bodyValue["active"] = false;
    if ( body->IsFixedRotation() )
        bodyValue["fixedRotation"] = true;
    
    b2MassData massData;
    body->GetMassData(&massData);
    if ( massData.mass != 0 )
        floatToJson("massData-mass", massData.mass, bodyValue);
    if ( massData.center.x != 0 || massData.center.y != 0 )
        vecToJson("massData-center", massData.center, bodyValue);
    if ( massData.I != 0 )
        floatToJson("massData-I", massData.I, bodyValue);
    
    int i = 0;
    for (b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext())
        bodyValue["fixture"][i++] = b2j(fixture);
    
    return bodyValue;
}

Json::Value b2dJson::b2j(b2Fixture *fixture)
{
    Json::Value fixtureValue;
    
    string fixtureName = getFixtureName(fixture);
    if ( fixtureName != "" )
        fixtureValue["name"] = fixtureName;
    
    if ( fixture->GetRestitution() != 0 )
        floatToJson("restitution", fixture->GetRestitution(), fixtureValue);
    if ( fixture->GetFriction() != 0 )
        floatToJson("friction", fixture->GetFriction(), fixtureValue);
    if ( fixture->GetDensity() != 0 )
        floatToJson("density", fixture->GetDensity(), fixtureValue);
    if ( fixture->IsSensor() )
        fixtureValue["sensor"] = true;
    
    b2Filter filter = fixture->GetFilterData();
    if ( filter.categoryBits != 0x0001 )
        fixtureValue["filter-categoryBits"] = filter.categoryBits;
    if ( filter.maskBits != 0xffff )
        fixtureValue["filter-maskBits"] = filter.maskBits;
    if ( filter.groupIndex != 0 )
        fixtureValue["filter-groupIndex"] = filter.groupIndex;
    
    b2Shape* shape = fixture->GetShape();
    switch (shape->GetType())
    {
        case b2Shape::e_circle:
        {
            b2CircleShape* circle = (b2CircleShape*)shape;
            floatToJson("radius", circle->m_radius, fixtureValue["circle"]);
            vecToJson("center", circle->m_p, fixtureValue["circle"]);
        }
            break;
        case b2Shape::e_edge:
        {
            b2EdgeShape* edge = (b2EdgeShape*)shape;
            vecToJson("vertex1", edge->m_vertex1, fixtureValue["edge"]);
            vecToJson("vertex2", edge->m_vertex2, fixtureValue["edge"]);
            if ( edge->m_hasVertex0 )
                fixtureValue["edge"]["hasVertex0"] = true;
            if ( edge->m_hasVertex3 )
                fixtureValue["edge"]["hasVertex3"] = true;
            if ( edge->m_hasVertex0 )
                vecToJson("vertex0", edge->m_vertex0, fixtureValue["edge"]);
            if ( edge->m_hasVertex3 )
                vecToJson("vertex3", edge->m_vertex3, fixtureValue["edge"]);
        }
            break;
        case b2Shape::e_chain:
        {
            b2ChainShape* chain = (b2ChainShape*)shape;
            int32 count = chain->m_count;
            const b2Vec2* vertices = chain->m_vertices;
            for (int32 i = 0; i < count; ++i)
                vecToJson("vertices", vertices[i], fixtureValue["chain"], i);
            if ( chain->m_hasPrevVertex )
                fixtureValue["chain"]["hasPrevVertex"] = true;
            if ( chain->m_hasNextVertex )
                fixtureValue["chain"]["hasNextVertex"] = true;
            if ( chain->m_hasPrevVertex )
                vecToJson("prevVertex", chain->m_prevVertex, fixtureValue["chain"]);
            if ( chain->m_hasNextVertex )
                vecToJson("nextVertex", chain->m_nextVertex, fixtureValue["chain"]);
        }
            break;
        case b2Shape::e_polygon:
        {
            b2PolygonShape* poly = (b2PolygonShape*)shape;
            int32 vertexCount = poly->GetVertexCount();
            b2Assert(vertexCount <= b2_maxPolygonVertices);
            for (int32 i = 0; i < vertexCount; ++i)
                vecToJson("vertices", poly->m_vertices[i], fixtureValue["polygon"], i);
        }
            break;
        default:
            std::cout << "Unknown shape type : " << shape->GetType() << std::endl;
    }
    
    return fixtureValue;
}

Json::Value b2dJson::b2j(b2Joint* joint)
{
    Json::Value jointValue;
    
    int bodyIndexA = lookupBodyIndex( joint->GetBodyA() );
    int bodyIndexB = lookupBodyIndex( joint->GetBodyB() );
    jointValue["bodyA"] = bodyIndexA;
    jointValue["bodyB"] = bodyIndexB;
    if ( joint->GetCollideConnected() )
        jointValue["collideConnected"] = true;
    
    string jointName = getJointName(joint);
    if ( jointName != "" )
        jointValue["name"] = jointName;
    
    b2Body* bodyA = joint->GetBodyA();
    b2Body* bodyB = joint->GetBodyB();
    
    switch ( joint->GetType() )
    {
        case e_revoluteJoint:
        {
            jointValue["type"] = "revolute";
            
            b2RevoluteJoint* revoluteJoint = (b2RevoluteJoint*)joint;
            vecToJson("anchorA", bodyA->GetLocalPoint(revoluteJoint->GetAnchorA()), jointValue);
            vecToJson("anchorB", bodyB->GetLocalPoint(revoluteJoint->GetAnchorB()), jointValue);
            floatToJson("refAngle", bodyB->GetAngle() - bodyA->GetAngle() - revoluteJoint->GetJointAngle(), jointValue);
            floatToJson("jointSpeed", revoluteJoint->GetJointSpeed(), jointValue);
            jointValue["enableLimit"] = revoluteJoint->IsLimitEnabled();
            floatToJson("lowerLimit", revoluteJoint->GetLowerLimit(), jointValue);
            floatToJson("upperLimit", revoluteJoint->GetUpperLimit(), jointValue);
            jointValue["enableMotor"] = revoluteJoint->IsMotorEnabled();
            floatToJson("motorSpeed", revoluteJoint->GetMotorSpeed(), jointValue);
            floatToJson("maxMotorTorque", revoluteJoint->GetMaxMotorTorque(), jointValue);
        }
            break;
        case e_prismaticJoint:
        {
            jointValue["type"] = "prismatic";
            
            b2PrismaticJoint* prismaticJoint = (b2PrismaticJoint*)joint;
            vecToJson("anchorA", bodyA->GetLocalPoint(prismaticJoint->GetAnchorA()), jointValue);
            vecToJson("anchorB", bodyB->GetLocalPoint(prismaticJoint->GetAnchorB()), jointValue);
            vecToJson("localAxisA", prismaticJoint->GetLocalAxisA(), jointValue);
            floatToJson("refAngle", prismaticJoint->GetReferenceAngle(), jointValue);
            jointValue["enableLimit"] = prismaticJoint->IsLimitEnabled();
            floatToJson("lowerLimit", prismaticJoint->GetLowerLimit(), jointValue);
            floatToJson("upperLimit", prismaticJoint->GetUpperLimit(), jointValue);
            jointValue["enableMotor"] = prismaticJoint->IsMotorEnabled();
            floatToJson("maxMotorForce", prismaticJoint->GetMaxMotorForce(), jointValue);
            floatToJson("motorSpeed", prismaticJoint->GetMotorSpeed(), jointValue);
        }
            break;
        case e_distanceJoint:
        {
            jointValue["type"] = "distance";
            
            b2DistanceJoint* distanceJoint = (b2DistanceJoint*)joint;
            vecToJson("anchorA", bodyA->GetLocalPoint(distanceJoint->GetAnchorA()), jointValue);
            vecToJson("anchorB", bodyB->GetLocalPoint(distanceJoint->GetAnchorB()), jointValue);
            floatToJson("length", distanceJoint->GetLength(), jointValue);
            floatToJson("frequency", distanceJoint->GetFrequency(), jointValue);
            floatToJson("dampingRatio", distanceJoint->GetDampingRatio(), jointValue);
        }
            break;
        case e_pulleyJoint:
        {
            jointValue["type"] = "pulley";
            
            b2PulleyJoint* pulleyJoint = (b2PulleyJoint*)joint;
            vecToJson("groundAnchorA", pulleyJoint->GetGroundAnchorA(), jointValue);
            vecToJson("groundAnchorB", pulleyJoint->GetGroundAnchorB(), jointValue);
            vecToJson("anchorA", bodyA->GetLocalPoint(pulleyJoint->GetAnchorA()), jointValue);
            vecToJson("anchorB", bodyB->GetLocalPoint(pulleyJoint->GetAnchorB()), jointValue);
            floatToJson("lengthA", (pulleyJoint->GetGroundAnchorA() - pulleyJoint->GetAnchorA()).Length(), jointValue);
            floatToJson("lengthB", (pulleyJoint->GetGroundAnchorB() - pulleyJoint->GetAnchorB()).Length(), jointValue);
            floatToJson("ratio", pulleyJoint->GetRatio(), jointValue);
        }
            break;
        case e_mouseJoint:
        {
            jointValue["type"] = "mouse";
            
            b2MouseJoint* mouseJoint = (b2MouseJoint*)joint;
            vecToJson("target", mouseJoint->GetTarget(), jointValue);
            vecToJson("anchorB", mouseJoint->GetAnchorB(), jointValue);
            floatToJson("maxForce", mouseJoint->GetMaxForce(), jointValue);
            floatToJson("frequency", mouseJoint->GetFrequency(), jointValue);
            floatToJson("dampingRatio", mouseJoint->GetDampingRatio(), jointValue);
        }
            break;
        case e_gearJoint:
        {
            jointValue["type"] = "gear";
            
            b2GearJoint* gearJoint = (b2GearJoint*)joint;
            int jointIndex1 = lookupJointIndex( gearJoint->GetJoint1() );
            int jointIndex2 = lookupJointIndex( gearJoint->GetJoint2() );
            jointValue["joint1"] = jointIndex1;
            jointValue["joint2"] = jointIndex2;
            jointValue["ratio"] = gearJoint->GetRatio();
        }
            break;
        case e_wheelJoint:
        {
            jointValue["type"] = "wheel";
            
            b2WheelJoint* wheelJoint = (b2WheelJoint*)joint;
            vecToJson("anchorA", bodyA->GetLocalPoint(wheelJoint->GetAnchorA()), jointValue);
            vecToJson("anchorB", bodyB->GetLocalPoint(wheelJoint->GetAnchorB()), jointValue);
            vecToJson("localAxisA", wheelJoint->GetLocalAxisA(), jointValue);
            jointValue["enableMotor"] = wheelJoint->IsMotorEnabled();
            floatToJson("motorSpeed", wheelJoint->GetMotorSpeed(), jointValue);
            floatToJson("maxMotorTorque", wheelJoint->GetMaxMotorTorque(), jointValue);
            floatToJson("springFrequency", wheelJoint->GetSpringFrequencyHz(), jointValue);
            floatToJson("springDampingRatio", wheelJoint->GetSpringDampingRatio(), jointValue);
        }
            break;
        case e_weldJoint:
        {
            jointValue["type"] = "weld";
            
            b2WeldJoint* weldJoint = (b2WeldJoint*)joint;
            vecToJson("anchorA", bodyA->GetLocalPoint(weldJoint->GetAnchorA()), jointValue);
            vecToJson("anchorB", bodyB->GetLocalPoint(weldJoint->GetAnchorB()), jointValue);
            floatToJson("refAngle", weldJoint->GetReferenceAngle(), jointValue);
        }
            break;
        case e_frictionJoint:
        {
            jointValue["type"] = "friction";
            
            b2FrictionJoint* frictionJoint = (b2FrictionJoint*)joint;
            vecToJson("anchorA", bodyA->GetLocalPoint(frictionJoint->GetAnchorA()), jointValue);
            vecToJson("anchorB", bodyB->GetLocalPoint(frictionJoint->GetAnchorB()), jointValue);
            floatToJson("maxForce", frictionJoint->GetMaxForce(), jointValue);
            floatToJson("maxTorque", frictionJoint->GetMaxTorque(), jointValue);
        }
            break;
        case e_ropeJoint:
        {
            jointValue["type"] = "rope";
            
            b2RopeJoint* ropeJoint = (b2RopeJoint*)joint;
            vecToJson("anchorA", bodyA->GetLocalPoint(ropeJoint->GetAnchorA()), jointValue);
            vecToJson("anchorB", bodyB->GetLocalPoint(ropeJoint->GetAnchorB()), jointValue);
            floatToJson("maxLength", ropeJoint->GetMaxLength(), jointValue);
        }
            break;
        case e_unknownJoint:
        default:
            std::cout << "Unknown joint type not stored in snapshot : " << joint->GetType() << std::endl;
    }
    
    return jointValue;
}
// qiup changed at 2012-12-15
//
/** old Version **/
//Json::Value b2dJson::b2j(b2dJsonImage *image)
//{
//    Json::Value imageValue;
//
//    if ( image->body )
//        imageValue["body"] = lookupBodyIndex( image->body );
//    else
//        imageValue["body"] = -1;
//
//    if ( image->name != "" )
//        imageValue["name"] = image->name;
//    if ( image->file != "" )
//        imageValue["file"] = image->file;
//
//    vecToJson("center", image->center, imageValue);
//    floatToJson("angle", image->angle, imageValue );
//    floatToJson("scale", image->scale, imageValue );
//    if ( image->flip )
//        imageValue["flip"] = true;
//    floatToJson("opacity", image->opacity, imageValue );
//    imageValue["filter"] = image->filter;
//    floatToJson("renderOrder", image->renderOrder, imageValue );
//
//    //image->updateCorners();
//    for (int i = 0; i < 4; i++)
//        vecToJson("corners", image->m_corners[i], imageValue, i);
//
//    //image->updateUVs();
//    for (int i = 0; i < 2*image->numPoints; i++) {
//        vecToJson("glVertexPointer", image->points[i], imageValue, i);
//        vecToJson("glTexCoordPointer", image->uvCoords[i], imageValue, i);
//    }
//    for (int i = 0; i < image->numIndices; i++)
//        vecToJson("glDrawElements", (unsigned int)image->indices[i], imageValue, i);
//
//    return imageValue;
//}
/**     end     **/

void b2dJson::setBodyName(b2Body* body, const char* name)
{
    m_bodyToNameMap[body] = name;
}

void b2dJson::setFixtureName(b2Fixture* fixture, const char* name)
{
    m_fixtureToNameMap[fixture] = name;
}

void b2dJson::setJointName(b2Joint* joint, const char* name)
{
    m_jointToNameMap[joint] = name;
}

//void b2dJson::setImageName(b2dJsonImage* image, const char* name)
//{
//    m_imageToNameMap[image] = name;
//}
//
//void b2dJson::addImage(b2dJsonImage *image)
//{
//    setImageName(image, image->name.c_str());
//}

void b2dJson::floatToJson(const char* name, float f, Json::Value& value)
{
    //cut down on file space for common values
    if ( f == 0 )
        value[name] = 0;
    else if ( f == 1 )
        value[name] = 1;
    else {
        if ( m_useHumanReadableFloats )
            value[name] = f;
        else
            value[name] = floatToHex(f);
    }
}

inline void b2dJson::vecToJson(const char* name, unsigned int v, Json::Value& value, int index)
{
    if (index > -1)
        value[name][index] = v;
    else
        value[name] = v;
}

void b2dJson::vecToJson(const char *name, float v, Json::Value &value, int index)
{
    if (index > -1) {
        if ( m_useHumanReadableFloats ) {
            value[name][index] = v;
        }
        else {
            if ( v == 0 )
                value[name][index] = 0;
            else if ( v == 1 )
                value[name][index] = 1;
            else
                value[name][index] = floatToHex(v);
        }
    }
    else
        floatToJson(name, v, value);
}

inline void b2dJson::vecToJson(const char* name, b2Vec2 vec, Json::Value& value, int index)
{
    if (index > -1) {
        if ( m_useHumanReadableFloats ) {
            value[name]["x"][index] = vec.x;
            value[name]["y"][index] = vec.y;
        }
        else {
            if ( vec.x == 0 )
                value[name]["x"][index] = 0;
            else if ( vec.x == 1 )
                value[name]["x"][index] = 1;
            else
                value[name]["x"][index] = floatToHex(vec.x);
            if ( vec.y == 0 )
                value[name]["y"][index] = 0;
            else if ( vec.y == 1 )
                value[name]["y"][index] = 1;
            else
                value[name]["y"][index] = floatToHex(vec.y);
        }
    }
    else {
        if ( vec.x == 0 && vec.y == 0 )
            value[name] = 0;//cut down on file space for common values
        else {
            floatToJson("x", vec.x, value[name]);
            floatToJson("y", vec.y, value[name]);
        }
    }
}
















void b2dJson::clear()
{
    m_indexToBodyMap.clear();
    m_bodyToIndexMap.clear();
    m_jointToIndexMap.clear();
    m_bodies.clear();
    m_joints.clear();
    //    m_images.clear();
    
    m_bodyToNameMap.clear();
    m_fixtureToNameMap.clear();
    m_jointToNameMap.clear();
    //    m_imageToNameMap.clear();
}

b2World *b2dJson::readFromValue(Json::Value worldValue)
{
    clear();
    
    return j2b2World(worldValue);
}

b2World* b2dJson::readFromString(std::string str, std::string& errorMsg)
{
    Json::Value worldValue;
    Json::Reader reader;
    if ( ! reader.parse(str, worldValue) )
    {
        errorMsg = string("Failed to parse JSON:\n") + reader.getFormatedErrorMessages();
        return NULL;
    }
    
    return j2b2World(worldValue);
}

b2World* b2dJson::readFromFile(const char* filename, std::string& errorMsg)
{
    if (!filename)
        return NULL;
	
	NSString* nsstr = [NSString stringWithUTF8String:filename];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:nsstr ofType:nil];
	if (filePath) {
		NSError* error = nil;
		NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
		if (myText)
			return readFromString([myText UTF8String], errorMsg);
	}
	
    std::cout << "Could not open file " << filename << " for reading\n";
	return NULL;
}
bool b2dJson::loadIntoExistingWorld(b2World* world, const char* filename, std::string& errorMsg)
{
    if (!filename)
        return false;
    
    std::ifstream ifs;
    ifs.open(filename, std::ios::in);
    if (!ifs) {
        errorMsg = string("Could not open file '") + string(filename) + string("' for reading");
        return false;
    }
    
    Json::Value worldValue;
    Json::Reader reader;
    if ( ! reader.parse(ifs, worldValue) )
    {
        errorMsg = string("Failed to parse '") + string(filename) + string("' : ") + reader.getFormatedErrorMessages();
        ifs.close();
        return false;
    }
    ifs.close();
    j2b2World(world , worldValue);
    return true;
}
// qiup added at 2012-12-28
void b2dJson::j2b2World(b2World* world,Json::Value worldValue)
{
    int i = 0;
    Json::Value bodyValue = worldValue["body"][i];
    while ( !bodyValue.isNull() ) {
        b2Body* body = j2b2Body(world, bodyValue);
        m_bodies.push_back(body);
        m_indexToBodyMap[i] = body;
        
        i++;
        bodyValue = worldValue["body"][i];
    }
    
    //need two passes for joints because gear joints reference other joints
    i = 0;
    Json::Value jointValue = worldValue["joint"][i++];
    while ( !jointValue.isNull() ) {
        if ( jointValue["type"].asString() != "gear" ) {
            b2Joint* joint = j2b2Joint(world, jointValue);
            m_joints.push_back(joint);
        }
        jointValue = worldValue["joint"][i++];
    }
    i = 0;
    jointValue = worldValue["joint"][i++];
    while ( !jointValue.isNull() ) {
        if ( jointValue["type"].asString() == "gear" ) {
            b2Joint* joint = j2b2Joint(world, jointValue);
            m_joints.push_back(joint);
        }
        jointValue = worldValue["joint"][i++];
    }
    // qiup changed at 2012-12-15
    //
    /** old Version **/
    //    i = 0;
    //    Json::Value imageValue = worldValue["image"][i++];
    //    while ( !imageValue.isNull() ) {
    //        b2dJsonImage* img = j2b2dJsonImage(imageValue);
    //        m_images.push_back(img);
    //        addImage(img);
    //
    //        imageValue = worldValue["image"][i++];
    //    }
    /**     end     */
    i = 0;
    Json::Value imageValue = worldValue["image"][i++];
    while ( !imageValue.isNull() ) {
        b2Body* body = NULL;
        std::string strName;
        KTSpriteViewController* spriteVC = nil;
        float ratio = ((B2dJsonBox2DWorldModel*)m_physicsController.model).pixelsToMeterRatio;
        //
        // qiup added at 2012-12-29
        if ( imageValue["file"].isString() )
        {
            std::string strFileName = imageValue["file"].asString();
            std::size_t pos =  strFileName.rfind('/');
            NSString* bundlFilename = nil;
            
            if (pos != (std::size_t)-1 && pos < strFileName.length() -2) {
                bundlFilename = [NSString stringWithUTF8String:strFileName.data() + pos + 1];
            }else{
                bundlFilename = [NSString stringWithUTF8String:strFileName.c_str()];
            }
            
            spriteVC = [KTSpriteViewController spriteControllerWithSpriteFrameName:bundlFilename];
            float opacity = jsonToFloat("opacity", imageValue);
            bool bFlip = jsonToFloat("flip", imageValue);
            int order = jsonToFloat("renderOrder", imageValue);
            // qiup added at 2012-12-29
            float scale = jsonToFloat("scale", imageValue);

            spriteVC.loadViewBlock = ^(CCNode* rootNode){
                CCSprite* sprite = (CCSprite*)rootNode;
                sprite.opacity = opacity * 255;
                sprite.flipX = bFlip;
                sprite.zOrder = order;
                if (spriteVC.model) {
                    float imageHeight = sprite.textureRect.size.height;
                    B2dJsonBox2dPhysicsEntityModel* entityModel = (B2dJsonBox2dPhysicsEntityModel*)spriteVC.model;
                    // qiup added at 2012-12-29
                    //  R.U.B.E scale 不是图片的放缩，而是图片的高度和m的比例
                    float pixelsHeight = scale * ratio;
                    entityModel.originScale = pixelsHeight / imageHeight;
                }
            };
        }
        if (spriteVC && imageValue["body"].isInt() )
        {
            body = lookupBodyFromIndex( imageValue["body"].asInt());
            if (body) {
                float roration = jsonToFloat("angle", imageValue);                // qiup added at 2012-12-29
                b2Vec2 offset = jsonToVec("center", imageValue);
                CGPoint offsetPoint = ccp(offset.x * ratio, offset.y*ratio);
                spriteVC.createModelBlock = ^(){
                    B2dJsonBox2dPhysicsEntityModel* entityModel = [B2dJsonBox2dPhysicsEntityModel physicsEntityModelWithB2dJsonBox2DController:m_physicsController andB2body:body];
                    // 编辑器的图片初始值。
                    entityModel.originRoration = roration;
                    // qiup added at 2012-12-29
                    entityModel.originOffset = offsetPoint;

                    return entityModel;
                };
            }
        }
        if (spriteVC &&  imageValue["name"].isString() )
        {
            strName = imageValue["name"].asString();
        }
        if (spriteVC)
        {
            [m_parentViewController addSubController:spriteVC];
            if (!strName.empty()) {
                [m_parentViewController.sceneViewController registerController:spriteVC withName:[NSString stringWithUTF8String:strName.c_str()]];
            }
        }
        imageValue = worldValue["image"][i++];
    }

}

b2World* b2dJson::j2b2World(Json::Value worldValue)
{
    m_bodies.clear();
    
    b2World* world = new b2World( jsonToVec("gravity", worldValue) );
    world->SetAllowSleeping( worldValue["allowSleep"].asBool() );
    
    world->SetAutoClearForces( worldValue["autoClearForces"].asBool() );
    world->SetWarmStarting( worldValue["warmStarting"].asBool() );
    world->SetContinuousPhysics( worldValue["continuousPhysics"].asBool() );
    world->SetSubStepping( worldValue["subStepping"].asBool() );
    
    //bool recreationMayDiffer = false; //hahaha
    //if ( ! world->GetAutoClearForces() ) { std::cout << "Note: world is not set to auto clear forces.\n"; recreationMayDiffer = true; }
    //if ( world->GetWarmStarting() ) { std::cout << "Note: world is set to use warm starting.\n"; recreationMayDiffer = true; }
    //if ( world->GetContinuousPhysics() ) { std::cout << "Note: world is set to use continuous physics.\n"; recreationMayDiffer = true; }
    //if ( world->GetSubStepping() ) { std::cout << "Note: world is set to use sub stepping.\n"; recreationMayDiffer = true; }
    //if ( worldValue["hasDestructionListener"].asBool() ) { std::cout << "Note: world originally had a destruction listener set.\n"; recreationMayDiffer = true; }
    //if ( worldValue["hasContactFilter"].asBool() ) { std::cout << "Note: world originally had a contact filter set.\n"; recreationMayDiffer = true; }
    //if ( worldValue["hasContactListener"].asBool() ) { std::cout << "Note: world originally had a contact listener set.\n"; recreationMayDiffer = true; }
    //if ( recreationMayDiffer )
    //    std::cout << "Recreated behaviour may differ from original.\n";
    j2b2World(world,worldValue);

    
    
    return world;
}

b2Body* b2dJson::j2b2Body(b2World* world, Json::Value bodyValue)
{
    b2Body* body = NULL;
    
    b2BodyDef bodyDef;
    
    bodyDef.type = (b2BodyType)bodyValue["type"].asInt();
    bodyDef.position = jsonToVec("position", bodyValue);
    bodyDef.angle = jsonToFloat("angle", bodyValue );
    bodyDef.linearVelocity = jsonToVec("linearVelocity", bodyValue);
    bodyDef.angularVelocity = jsonToFloat("angularVelocity", bodyValue);
    bodyDef.linearDamping = jsonToFloat("linearDamping", bodyValue, -1, 0);
    bodyDef.angularDamping = jsonToFloat("angularDamping", bodyValue, -1, 0);
    bodyDef.gravityScale = jsonToFloat("gravityScale", bodyValue, -1, 1);
    
    bodyDef.allowSleep = bodyValue.get("allowSleep",true).asBool();
    bodyDef.awake = bodyValue.get("awake", false).asBool();
    bodyDef.fixedRotation = bodyValue.get("fixedRotation",false).asBool();
    bodyDef.bullet = bodyValue.get("bullet",false).asBool();
    bodyDef.active = bodyValue.get("active",true).asBool();
    
    body = world->CreateBody(&bodyDef);
    
    string bodyName = bodyValue.get("name","").asString();
    if ( bodyName != "" ) {
        //printf("Found named body: %s\n",bodyName.c_str());
        setBodyName(body, bodyName.c_str());
    }
    
    int i = 0;
    Json::Value fixtureValue = bodyValue["fixture"][i++];
    while ( !fixtureValue.isNull() ) {
        /*b2Fixture* fixture =*/ j2b2Fixture(body, fixtureValue);
        
        fixtureValue = bodyValue["fixture"][i++];
    }
    
    //may be necessary if user has overridden mass characteristics
    b2MassData massData;
    massData.mass = jsonToFloat("massData-mass", bodyValue);
    massData.center = jsonToVec("massData-center", bodyValue);
    massData.I = jsonToFloat("massData-I", bodyValue);
    body->SetMassData(&massData);
    
    return body;
}

b2Fixture* b2dJson::j2b2Fixture(b2Body* body, Json::Value fixtureValue)
{
    b2Fixture* fixture = NULL;
    
    b2FixtureDef fixtureDef;
    fixtureDef.restitution = jsonToFloat("restitution", fixtureValue);
    fixtureDef.friction = jsonToFloat("friction", fixtureValue);
    fixtureDef.density = jsonToFloat("density", fixtureValue);
    fixtureDef.isSensor = fixtureValue.get("sensor",false).asBool();
    
    fixtureDef.filter.categoryBits = fixtureValue.get("filter-categoryBits",0x0001).asInt();
    fixtureDef.filter.maskBits = fixtureValue.get("filter-maskBits",0xffff).asInt();
    fixtureDef.filter.groupIndex = fixtureValue.get("filter-groupIndex",0).asInt();
    
    if ( fixtureValue.isNull() )
        return NULL;
    
    if ( !fixtureValue["circle"].isNull() ) {
        b2CircleShape circleShape;
        circleShape.m_radius = jsonToFloat("radius", fixtureValue["circle"]);
        circleShape.m_p = jsonToVec("center", fixtureValue["circle"]);
        fixtureDef.shape = &circleShape;
        fixture = body->CreateFixture(&fixtureDef);
    }
    else if ( !fixtureValue["edge"].isNull() ) {
        b2EdgeShape edgeShape;
        edgeShape.m_vertex1 = jsonToVec("vertex1", fixtureValue["edge"]);
        edgeShape.m_vertex2 = jsonToVec("vertex2", fixtureValue["edge"]);
        edgeShape.m_hasVertex0 = fixtureValue["edge"].get("hasVertex0",false).asBool();
        edgeShape.m_hasVertex3 = fixtureValue["edge"].get("hasVertex3",false).asBool();
        if ( edgeShape.m_hasVertex0 )
            edgeShape.m_vertex0 = jsonToVec("vertex0", fixtureValue["edge"]);
        if ( edgeShape.m_hasVertex3 )
            edgeShape.m_vertex3 = jsonToVec("vertex3", fixtureValue["edge"]);
        fixtureDef.shape = &edgeShape;
        fixture = body->CreateFixture(&fixtureDef);
    }
    else if ( !fixtureValue["loop"].isNull() ) { //support old format (r197)
        b2ChainShape chainShape;
        int numVertices = fixtureValue["loop"]["vertices"]["x"].size();
        b2Vec2* vertices = new b2Vec2[numVertices];
        for (int i = 0; i < numVertices; i++)
            vertices[i] = jsonToVec("vertices", fixtureValue["loop"], i);
        chainShape.CreateLoop(vertices, numVertices);
        fixtureDef.shape = &chainShape;
        fixture = body->CreateFixture(&fixtureDef);
        delete[] vertices;
    }
    else if ( !fixtureValue["chain"].isNull() ) {
        b2ChainShape chainShape;
        int numVertices = fixtureValue["chain"]["vertices"]["x"].size();
        b2Vec2* vertices = new b2Vec2[numVertices];
        for (int i = 0; i < numVertices; i++)
            vertices[i] = jsonToVec("vertices", fixtureValue["chain"], i);
        chainShape.CreateChain(vertices, numVertices);
        chainShape.m_hasPrevVertex = fixtureValue["chain"].get("hasPrevVertex",false).asBool();
        chainShape.m_hasNextVertex = fixtureValue["chain"].get("hasNextVertex",false).asBool();
        if ( chainShape.m_hasPrevVertex )
            chainShape.m_prevVertex = jsonToVec("prevVertex", fixtureValue["chain"]);
        if ( chainShape.m_hasNextVertex )
            chainShape.m_nextVertex = jsonToVec("nextVertex", fixtureValue["chain"]);
        fixtureDef.shape = &chainShape;
        fixture = body->CreateFixture(&fixtureDef);
        delete[] vertices;
    }
    else if ( !fixtureValue["polygon"].isNull() ) {
        b2Vec2 vertices[b2_maxPolygonVertices];
        int numVertices = fixtureValue["polygon"]["vertices"]["x"].size();
        if ( numVertices > b2_maxPolygonVertices ) {
            std::cout << "Ignoring polygon fixture with too many vertices.\n";
        }
        else if ( numVertices < 2 ) {
            std::cout << "Ignoring polygon fixture less than two vertices.\n";
        }
        else if ( numVertices == 2 ) {
            std::cout << "Creating edge shape instead of polygon with two vertices.\n";
            b2EdgeShape edgeShape;
            edgeShape.m_vertex1 = jsonToVec("vertices", fixtureValue["polygon"], 0);
            edgeShape.m_vertex2 = jsonToVec("vertices", fixtureValue["polygon"], 1);
            fixtureDef.shape = &edgeShape;
            fixture = body->CreateFixture(&fixtureDef);
        }
        else {
            b2PolygonShape polygonShape;
            for (int i = 0; i < numVertices; i++)
                vertices[i] = jsonToVec("vertices", fixtureValue["polygon"], i);
            polygonShape.Set(vertices, numVertices);
            fixtureDef.shape = &polygonShape;
            fixture = body->CreateFixture(&fixtureDef);
        }
    }
    
    string fixtureName = fixtureValue.get("name","").asString();
    if ( fixtureName != "" ) {
        setFixtureName(fixture, fixtureName.c_str());
    }
    
    return fixture;
}

b2Joint* b2dJson::j2b2Joint(b2World* world, Json::Value jointValue)
{
    b2Joint* joint = NULL;
    
    int bodyIndexA = jointValue["bodyA"].asInt();
    int bodyIndexB = jointValue["bodyB"].asInt();
    if ( bodyIndexA >= (int)m_bodies.size() || bodyIndexB >= (int)m_bodies.size() )
        return NULL;
    
    //keep these in scope after the if/else below
    b2RevoluteJointDef revoluteDef;
    b2PrismaticJointDef prismaticDef;
    b2DistanceJointDef distanceDef;
    b2PulleyJointDef pulleyDef;
    b2MouseJointDef mouseDef;
    b2GearJointDef gearDef;
    b2WheelJointDef wheelDef;
    b2WeldJointDef weldDef;
    b2FrictionJointDef frictionDef;
    b2RopeJointDef ropeDef;
    
    //will be used to select one of the above to work with
    b2JointDef* jointDef = NULL;
    
    b2Vec2 mouseJointTarget;
    std::string type = jointValue["type"].asString();
    if ( type == "revolute" )
    {
        jointDef = &revoluteDef;
        revoluteDef.localAnchorA = jsonToVec("anchorA", jointValue);
        revoluteDef.localAnchorB = jsonToVec("anchorB", jointValue);
        revoluteDef.referenceAngle = jsonToFloat("refAngle", jointValue);
        revoluteDef.enableLimit = jointValue["enableLimit"].asBool();
        revoluteDef.lowerAngle = jsonToFloat("lowerLimit", jointValue);
        revoluteDef.upperAngle = jsonToFloat("upperLimit", jointValue);
        revoluteDef.enableMotor = jointValue["enableMotor"].asBool();
        revoluteDef.motorSpeed = jsonToFloat("motorSpeed", jointValue);
        revoluteDef.maxMotorTorque = jsonToFloat("maxMotorTorque", jointValue);
    }
    else if ( type == "prismatic" )
    {
        jointDef = &prismaticDef;
        prismaticDef.localAnchorA = jsonToVec("anchorA", jointValue);
        prismaticDef.localAnchorB = jsonToVec("anchorB", jointValue);
        if ( !jointValue["localAxisA"].isNull() )
            prismaticDef.localAxisA = jsonToVec("localAxisA", jointValue);
        else
            prismaticDef.localAxisA = jsonToVec("localAxis1", jointValue);
        prismaticDef.referenceAngle = jsonToFloat("refAngle", jointValue);
        prismaticDef.enableLimit = jointValue["enableLimit"].asBool();
        prismaticDef.lowerTranslation = jsonToFloat("lowerLimit", jointValue);
        prismaticDef.upperTranslation = jsonToFloat("upperLimit", jointValue);
        prismaticDef.enableMotor = jointValue["enableMotor"].asBool();
        prismaticDef.motorSpeed = jsonToFloat("motorSpeed", jointValue);
        prismaticDef.maxMotorForce = jsonToFloat("maxMotorForce", jointValue);
    }
    else if ( type == "distance" )
    {
        jointDef = &distanceDef;
        distanceDef.localAnchorA = jsonToVec("anchorA", jointValue);
        distanceDef.localAnchorB = jsonToVec("anchorB", jointValue);
        distanceDef.length = jsonToFloat("length", jointValue);
        distanceDef.frequencyHz = jsonToFloat("frequency", jointValue);
        distanceDef.dampingRatio = jsonToFloat("dampingRatio", jointValue);
    }
    else if ( type == "pulley" )
    {
        jointDef = &pulleyDef;
        pulleyDef.groundAnchorA = jsonToVec("groundAnchorA", jointValue);
        pulleyDef.groundAnchorB = jsonToVec("groundAnchorB", jointValue);
        pulleyDef.localAnchorA = jsonToVec("anchorA", jointValue);
        pulleyDef.localAnchorB = jsonToVec("anchorB", jointValue);
        pulleyDef.lengthA = jsonToFloat("lengthA", jointValue);
        pulleyDef.lengthB = jsonToFloat("lengthB", jointValue);
        pulleyDef.ratio = jsonToFloat("ratio", jointValue);
    }
    else if ( type == "mouse" )
    {
        jointDef = &mouseDef;
        mouseJointTarget = jsonToVec("target", jointValue);
        mouseDef.target = jsonToVec("anchorB", jointValue);//alter after creating joint
        mouseDef.maxForce = jsonToFloat("maxForce", jointValue);
        mouseDef.frequencyHz = jsonToFloat("frequency", jointValue);
        mouseDef.dampingRatio = jsonToFloat("dampingRatio", jointValue);
    }
    else if ( type == "gear" )
    {
        jointDef = &gearDef;
        int jointIndex1 = jointValue["joint1"].asInt();
        int jointIndex2 = jointValue["joint2"].asInt();
        gearDef.joint1 = m_joints[jointIndex1];
        gearDef.joint2 = m_joints[jointIndex2];
        gearDef.ratio = jsonToFloat("ratio", jointValue);
    }
    else if ( type == "wheel" )
    {
        jointDef = &wheelDef;
        wheelDef.localAnchorA = jsonToVec("anchorA", jointValue);
        wheelDef.localAnchorB = jsonToVec("anchorB", jointValue);
        wheelDef.localAxisA = jsonToVec("localAxisA", jointValue);
        wheelDef.enableMotor = jointValue["enableMotor"].asBool();
        wheelDef.motorSpeed = jsonToFloat("motorSpeed", jointValue);
        wheelDef.maxMotorTorque = jsonToFloat("maxMotorTorque", jointValue);
        wheelDef.frequencyHz = jsonToFloat("springFrequency", jointValue);
        wheelDef.dampingRatio = jsonToFloat("springDampingRatio", jointValue);
    }
    else if ( type == "weld" )
    {
        jointDef = &weldDef;
        weldDef.localAnchorA = jsonToVec("anchorA", jointValue);
        weldDef.localAnchorB = jsonToVec("anchorB", jointValue);
        weldDef.referenceAngle = 0;//jsonToFloat("refAngle", jointValue);
    }
    else if ( type == "friction" )
    {
        jointDef = &frictionDef;
        frictionDef.localAnchorA = jsonToVec("anchorA", jointValue);
        frictionDef.localAnchorB = jsonToVec("anchorB", jointValue);
        frictionDef.maxForce = jsonToFloat("maxForce", jointValue);
        frictionDef.maxTorque = jsonToFloat("maxTorque", jointValue);
    }
    else if ( type == "rope" )
    {
        jointDef = &ropeDef;
        ropeDef.localAnchorA = jsonToVec("anchorA", jointValue);
        ropeDef.localAnchorB = jsonToVec("anchorB", jointValue);
        ropeDef.maxLength = jsonToFloat("maxLength", jointValue);
    }
    
    if ( jointDef ) {
        //set features common to all joints
        jointDef->bodyA = m_bodies[bodyIndexA];
        jointDef->bodyB = m_bodies[bodyIndexB];
        jointDef->collideConnected = jointValue.get("collideConnected",false).asBool();
        
        joint = world->CreateJoint(jointDef);
        
        if ( type == "mouse" )
            ((b2MouseJoint*)joint)->SetTarget(mouseJointTarget);
        
        string jointName = jointValue.get("name","").asString();
        if ( jointName != "" ) {
            setJointName(joint, jointName.c_str());
        }
    }
    
    return joint;
}
// qiup changed at 2012-12-15
//
/** old Version **/
//b2dJsonImage* b2dJson::j2b2dJsonImage(Json::Value imageValue)
//{
//    b2dJsonImage* img = new b2dJsonImage();
//
//    if ( imageValue["body"].isInt() )
//        img->body = lookupBodyFromIndex( imageValue["body"].asInt() );
//
//    if ( imageValue["name"].isString() ) {
//        img->name = imageValue["name"].asString();
//        setImageName(img, img->name.c_str());
//    }
//
//    if ( imageValue["file"].isString() )
//        img->file = imageValue["file"].asString();
//
//    img->center = jsonToVec("center", imageValue);
//    img->angle = jsonToFloat("angle", imageValue);
//    img->scale = jsonToFloat("scale", imageValue);
//    img->opacity = jsonToFloat("opacity", imageValue);
//    img->renderOrder = jsonToFloat("renderOrder", imageValue);
//
//    if ( imageValue["flip"].isBool() )
//        img->flip = imageValue["flip"].asBool();
//
//    if ( imageValue["filter"].isInt() )
//        img->filter = imageValue["filter"].asInt();
//
//    for (int i = 0; i < 4; i++)
//        img->m_corners[i] = jsonToVec("corners", imageValue, i);
//
//    if ( imageValue["glVertexPointer"].isArray() && imageValue["glTexCoordPointer"].isArray() &&
//         (imageValue["glVertexPointer"].size()  ==  imageValue["glTexCoordPointer"].size()) ) {
//        int numFloats = imageValue["glVertexPointer"].size();
//        img->numPoints = numFloats / 2;
//        img->points = new float[numFloats];
//        img->uvCoords = new float[numFloats];
//        for (int i = 0; i < numFloats; i++) {
//            img->points[i] = jsonToFloat("glVertexPointer", imageValue, i);
//            img->uvCoords[i] = jsonToFloat("glTexCoordPointer", imageValue, i);
//        }
//    }
//
//    if ( imageValue["glDrawElements"].isArray() ) {
//        img->numIndices = imageValue["glDrawElements"].size();
//        img->indices = new unsigned short[img->numIndices];
//        for (int i = 0; i < img->numIndices; i++)
//            img->indices[i] = imageValue["glDrawElements"][i].asInt();
//    }
//
//    return img;
//}
/**     end     */

float b2dJson::jsonToFloat(const char* name, Json::Value& value, int index, float defaultValue)
{
    if ( ! value.isMember(name) )
        return defaultValue;
    
    if ( index > -1 ) {
        if ( value[name][index].isNull() )
            return defaultValue;
        else if ( value[name][index].isInt() )
            return value[name][index].asInt();//usually 0 or 1
        else if ( value[name][index].isString() )
            return hexToFloat( value[name][index].asString() );
        else
            return value[name][index].asFloat();
    }
    else {
        if ( value[name].isNull() )
            return defaultValue;
        else if ( value[name].isInt() )
            return value[name].asInt();//usually 0 or 1
        else if ( value[name].isString() )
            return hexToFloat( value[name].asString() );
        else
            return value[name].asFloat();
    }
}

b2Vec2 b2dJson::jsonToVec(const char* name, Json::Value& value, int index, b2Vec2 defaultValue)
{
    b2Vec2 vec = defaultValue;
    
    if ( ! value.isMember(name) )
        return defaultValue;
    
    if (index > -1) {
        
        if ( value[name]["x"][index].isInt() ) //usually 0 or 1
            vec.x = value[name]["x"][index].asInt();
        else if ( value[name]["x"][index].isString() )
            vec.x = hexToFloat(value[name]["x"][index].asString());
        else
            vec.x = value[name]["x"][index].asFloat();
        
        if ( value[name]["y"][index].isInt() ) //usually 0 or 1
            vec.y = value[name]["y"][index].asInt();
        else if ( value[name]["y"][index].isString() )
            vec.y = hexToFloat(value[name]["y"][index].asString());
        else
            vec.y = value[name]["y"][index].asFloat();
    }
    else {
        
        if ( value[name].isInt() ) //zero vector
            vec.Set(0,0);
        else {
            vec.x = jsonToFloat("x", value[name]);
            vec.y = jsonToFloat("y", value[name]);
        }
    }
    
    return vec;
}



















std::string b2dJson::floatToHex(float f)
{
    char buf[16];
    //sprintf(buf, "%08X", *((int*)(&f)) ); dereferencing type-punned pointer will break strict-aliasing rules
    int* i = (int*)(&f);
    sprintf(buf, "%08X", *i );
    return std::string(buf);
}

float b2dJson::hexToFloat(std::string str)
{
    int strLen = 8;//32 bit float
    unsigned char bytes[4];
    int bptr = (strLen / 2) - 1;
    
    for (int i = 0; i < strLen; i++){
        unsigned char   c;
        c = str[i];
        if (c > '9') c -= 7;
        c <<= 4;
        bytes[bptr] = c;
        
        ++i;
        c = str[i];
        if (c > '9') c -= 7;
        c -= '0';
        bytes[bptr] |= c;
        
        --bptr;
    }
    
    //return *((float*)bytes); dereferencing type-punned pointer will break strict-aliasing rules
    float* f = (float*)bytes;
    return *f;
}

b2Body* b2dJson::lookupBodyFromIndex( unsigned int index )
{
    std::map<int,b2Body*>::iterator it = m_indexToBodyMap.find(index);
    if ( it != m_indexToBodyMap.end() )
        return it->second;
    else
        return NULL;
}

int b2dJson::lookupBodyIndex( b2Body* body )
{
    std::map<b2Body*,int>::iterator it = m_bodyToIndexMap.find(body);
    if ( it != m_bodyToIndexMap.end() )
        return it->second;
    else
        return -1;
}

int b2dJson::lookupJointIndex( b2Joint* joint )
{
    std::map<b2Joint*,int>::iterator it = m_jointToIndexMap.find(joint);
    if ( it != m_jointToIndexMap.end() )
        return it->second;
    else
        return -1;
}




string b2dJson::getBodyName(b2Body* body)
{
    map<b2Body*,string>::iterator it = m_bodyToNameMap.find( body );
    if ( it == m_bodyToNameMap.end() )
        return "";
    return it->second;
}

string b2dJson::getFixtureName(b2Fixture* fixture)
{
    map<b2Fixture*,string>::iterator it = m_fixtureToNameMap.find( fixture );
    if ( it == m_fixtureToNameMap.end() )
        return "";
    return it->second;
}

string b2dJson::getJointName(b2Joint* joint)
{
    map<b2Joint*,string>::iterator it = m_jointToNameMap.find( joint );
    if ( it == m_jointToNameMap.end() )
        return "";
    return it->second;
}

//string b2dJson::getImageName(b2dJsonImage *img)
//{
//    map<b2dJsonImage*,string>::iterator it = m_imageToNameMap.find( img );
//    if ( it == m_imageToNameMap.end() )
//        return "";
//    return it->second;
//}

int b2dJson::getBodiesByName(string name, vector<b2Body*>& bodies)
{
    map<b2Body*,string>::iterator it = m_bodyToNameMap.begin();
    map<b2Body*,string>::iterator end = m_bodyToNameMap.end();
    while (it != end) {
        if ( it->second == name )
            bodies.push_back(it->first);
        ++it;
    }
    return (int)bodies.size();
}

int b2dJson::getFixturesByName(string name, vector<b2Fixture*>& fixtures)
{
    map<b2Fixture*,string>::iterator it = m_fixtureToNameMap.begin();
    map<b2Fixture*,string>::iterator end = m_fixtureToNameMap.end();
    while (it != end) {
        if ( it->second == name )
            fixtures.push_back(it->first);
        ++it;
    }
    return (int)fixtures.size();
}

int b2dJson::getJointsByName(string name, vector<b2Joint*>& joints)
{
    map<b2Joint*,string>::iterator it = m_jointToNameMap.begin();
    map<b2Joint*,string>::iterator end = m_jointToNameMap.end();
    while (it != end) {
        if ( it->second == name )
            joints.push_back(it->first);
        ++it;
    }
    return (int)joints.size();
}

//int b2dJson::getImagesByName(string name, vector<b2dJsonImage*> &images)
//{
//    map<b2dJsonImage*,string>::iterator it = m_imageToNameMap.begin();
//    map<b2dJsonImage*,string>::iterator end = m_imageToNameMap.end();
//    while (it != end) {
//        if ( it->second == name )
//            images.push_back(it->first);
//        ++it;
//    }
//    return (int)images.size();
//}
//
//int b2dJson::getAllImages(vector<b2dJsonImage*> &images)
//{
//    images.insert( images.begin(), m_images.begin(), m_images.end() );
//    std::sort(images.begin(), images.end(), b2dJsonImage_renderOrder_ascending);
//    return (int)images.size();
//}


b2Body* b2dJson::getBodyByName(string name)
{
    map<b2Body*,string>::iterator it = m_bodyToNameMap.begin();
    map<b2Body*,string>::iterator end = m_bodyToNameMap.end();
    while (it != end) {
        if ( it->second == name )
            return it->first;
        ++it;
    }
    return NULL;
}

b2Fixture* b2dJson::getFixtureByName(string name)
{
    map<b2Fixture*,string>::iterator it = m_fixtureToNameMap.begin();
    map<b2Fixture*,string>::iterator end = m_fixtureToNameMap.end();
    while (it != end) {
        if ( it->second == name )
            return it->first;
        ++it;
    }
    return NULL;
}

b2Joint* b2dJson::getJointByName(string name)
{
    map<b2Joint*,string>::iterator it = m_jointToNameMap.begin();
    map<b2Joint*,string>::iterator end = m_jointToNameMap.end();
    while (it != end) {
        if ( it->second == name )
            return it->first;
        ++it;
    }
    return NULL;
}
//
//b2dJsonImage* b2dJson::getImageByName(string name)
//{
//    map<b2dJsonImage*,string>::iterator it = m_imageToNameMap.begin();
//    map<b2dJsonImage*,string>::iterator end = m_imageToNameMap.end();
//    while (it != end) {
//        if ( it->second == name )
//            return it->first;
//        ++it;
//    }
//    return NULL;
//}



