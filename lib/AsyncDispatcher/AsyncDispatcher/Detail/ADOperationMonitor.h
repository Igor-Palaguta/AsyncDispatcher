#import "../ADRequest.h"
#import "../ADBlockDefs.h"

#import "ADDispatchArcDefs.h"

#import <Foundation/Foundation.h>

@interface ADOperationMonitor : NSObject< ADRequest >

@property ( nonatomic, AD_DISPATCH_PROPERTY, readonly ) dispatch_group_t group;

-(id)initWithParentRequest:( id< ADRequest > )request_;

-(void)incrementUsage;
-(void)decrementUsage;

-(BOOL)wait;
-(BOOL)waitForTimeInterval:( NSTimeInterval )seconds_;

-(void)cancel;

@end
