#import "../ADBlockDefs.h"

#import <Foundation/Foundation.h>

@protocol ADResult;

@interface ADDoneBlockPerformer : NSObject

+(id)performerWithDoneBlock:( ADDoneBlock )done_block_;

//If releaseWhenDone is YES doneBlock is released
//It is useful for releasing all block context variables in same thread
-(void)performOnThread:( NSThread* )thread_
            withResult:( id< ADResult > )result_
       releaseWhenDone:( BOOL )release_when_done_;

@end
