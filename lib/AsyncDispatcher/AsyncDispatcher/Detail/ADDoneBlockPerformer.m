#import "ADDoneBlockPerformer.h"

@interface ADDoneBlockPerformer ()

@property ( nonatomic, copy ) ADDoneBlock doneBlock;

@end


@implementation ADDoneBlockPerformer

@synthesize doneBlock;

+(id)performerForDoneBlock:( ADDoneBlock )done_block_
{
   ADDoneBlockPerformer* performer_ = [ self new ];
   performer_.doneBlock = done_block_;
   return performer_;
}

-(void)perform:( id< ADResult > )result_
{
   self.doneBlock( result_ );
}

-(void)performOnThread:( NSThread* )thread_
            withResult:( id< ADResult > )result_
{
   [ self performSelector: @selector(perform:)
                 onThread: thread_
               withObject: result_
            waitUntilDone: NO ];
}

@end
