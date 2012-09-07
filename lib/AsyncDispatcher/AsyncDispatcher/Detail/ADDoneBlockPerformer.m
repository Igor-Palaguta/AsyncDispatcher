#import "ADDoneBlockPerformer.h"

@interface ADDoneBlockPerformer ()

@property ( nonatomic, copy ) ADDoneBlock doneBlock;

@end

@implementation ADDoneBlockPerformer

@synthesize doneBlock;

+(id)performerWithDoneBlock:( ADDoneBlock )done_block_
{
   ADDoneBlockPerformer* performer_ = [ self new ];
   performer_.doneBlock = done_block_;
   return performer_;
}

-(void)performDoneBlockWithResult:( id< ADResult > )result_
{
   if ( self.doneBlock )
   {
      self.doneBlock( result_ );
   }
}

-(void)performAndReleaseDoneBlockWithResult:( id< ADResult > )result_
{
   [ self performDoneBlockWithResult: result_ ];
   self.doneBlock = nil;
}

-(void)performOnThread:( NSThread* )thread_
            withResult:( id< ADResult > )result_
       releaseWhenDone:( BOOL )release_when_done_
{
   SEL perform_sel_ = release_when_done_
      ? @selector( performAndReleaseDoneBlockWithResult: )
      : @selector( performDoneBlockWithResult: );

   [ self performSelector: perform_sel_
                 onThread: thread_
               withObject: result_
            waitUntilDone: NO ];
}

@end
