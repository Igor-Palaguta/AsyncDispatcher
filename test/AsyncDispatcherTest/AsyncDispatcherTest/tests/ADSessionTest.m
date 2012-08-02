#import "ADOperation+ADTConstructors.h"

#import <AsyncDispatcher/AsyncDispatcher.h>

@interface ADSessionTest : GHAsyncTestCase

@end

@implementation ADSessionTest

-(void)testCancel
{
   [ self prepare ];

   __block NSUInteger cancelled_ = 0;
   __block NSUInteger not_cancelled_ = 0;

   ADSession* session_ = [ ADSession sharedSession ];
   GHAssertTrue( [ session_ count ] == 0, @"Check initial session requests count" );

   ADDoneBlock cancelled_done_block_ = ^( id< ADResult > result_ )
   {
      GHAssertTrue( result_.isCancelled, @"Check cancelled result" );
      ++cancelled_;
   };

   ADDoneBlock not_cancelled_done_block_ = ^( id< ADResult > result_ )
   {
      GHAssertTrue( !result_.isCancelled, @"Check no cancelled result" );
      ++not_cancelled_;
   };

   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 1
                                                              doneBlock: not_cancelled_done_block_
                                                                  delay: 0.1 ];

   [ operation_ async ];

   GHAssertTrue( [ session_ count ] == 1, @"Check session requests count" );

   NSRange sequence_range_ = NSMakeRange( 0, 15 );

   ADSequence* sequence_ = [ ADSequence compositeWithOperations: [ NSArray arrayWithOperationsFromRange: sequence_range_
                                                                                              doneBlock: cancelled_done_block_
                                                                  
                                                                                          delayFunction: ADTConstDelay( 0.2 ) ]
                                                           name: @"global"
                                                      doneBlock: ADDoneBlockSum( cancelled_done_block_, ADDoneLogResult() ) ];

   [ sequence_ async ];

   GHAssertTrue( [ session_ count ] == 2, @"Check session requests count" );
   
   ADBlockOperation* operation2_ = [ ADBlockOperation operationWithIndex: 3
                                                               doneBlock: cancelled_done_block_
                                                                   delay: 0.3 ];

   [ operation2_ async ];

   GHAssertTrue( [ session_ count ] == 3, @"Check session requests count" );

   ADDelayAsyncOnMainThread( ^() { [ session_ cancelAll ]; }
                            , 0.15 );

   ADDelayAsyncOnMainThread( ^(){ [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ]; }
                            , 0.4 );

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1.0 ];
   
   GHAssertTrue( [ session_ count ] == 0, @"Check session final count" );
   GHAssertTrue( not_cancelled_ == 1, @"Check not cancelled count" );
   GHAssertTrue( cancelled_ == 1 + 1 + sequence_range_.length, @"Check cancelled count" );
}

@end
