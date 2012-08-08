#import "../ADBlockDefs.h"

#import <Foundation/Foundation.h>

@class ADOperation;

@protocol ADResult;

@interface ADOperationSubscribers : NSObject

-(void)addSubscriber:( ADDoneBlock )done_block_;

-(void)sendToSubscribersResult:( id< ADResult > )result_;

@end


