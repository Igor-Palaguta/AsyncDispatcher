#import "../ADBlockDefs.h"

#import <Foundation/Foundation.h>

@interface ADDoneBlockPerformer : NSObject

@property ( nonatomic, copy, readonly ) ADDoneBlock doneBlock;

+(id)performerForDoneBlock:( ADDoneBlock )done_block_;

-(void)perform:( id< ADResult > )result_;

-(void)performOnThread:( NSThread* )thread_
            withResult:( id< ADResult > )result_;

@end
