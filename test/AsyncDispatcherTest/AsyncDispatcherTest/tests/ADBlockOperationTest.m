#import "ADOperation+ADTConstructors.h"
#import "ADTMacroses.h"
#import "ADDoneBlockChecker.h"
#import "ADTDeallocHere.h"

#import <AsyncDispatcher/AsyncDispatcher.h>

@interface ADBlockOperationTest : GHAsyncTestCase

@end

@implementation ADBlockOperationTest

-(void)testDoneBlock
{
   [ self prepare ];

   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADT_CHECK_RESULT( [ NSNumber numberWithInteger: 7 ] )
                                                                  delay: 0.1 ];

   [ operation_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testDoneOnMainThread
{
   [ self prepare ];
   
   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADDoneOnMainThread( ADCheckResultOnMainThread( ADNotifySuccess( nil, self, _cmd ), @7 ) )
                                                                  delay: 0.1 ];

   [ operation_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testDeallocOnMainThread
{
   [ self prepare ];

   @autoreleasepool
   {
      ADTDeallocHere* thread_tester_ = [ ADTDeallocHere expectsDeallocOnThread: [ NSThread mainThread ]
                                                                          test: self
                                                                      selector: _cmd ];

      ADDoneBlock done_block_ = ADDoneOnMainThread(
                                       ^( id< ADResult > result_ )
                                       {
                                          [ thread_tester_ doSomething ];
                                       }
                                       );

      ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                                 doneBlock: done_block_
                                                                     delay: 0.1 ];

      [ operation_ async ];
   }

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testDeallocOnThisThread
{
   [ self prepare ];

   @autoreleasepool
   {
      ADTDeallocHere* thread_tester_ = [ ADTDeallocHere expectsDeallocOnThread: [ NSThread currentThread ]
                                                                          test: self
                                                                      selector: _cmd ];

      ADDoneBlock done_block_ = ADDoneOnThisThread(
                                                   ^( id< ADResult > result_ )
                                                   {
                                                      [ thread_tester_ doSomething ];
                                                   }
                                                   );

      ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                                 doneBlock: done_block_
                                                                     delay: 0.1 ];

      [ operation_ async ];
   }

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testDoneOnBackgroundThread
{
   [ self prepare ];
   
   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADDoneOnBackgroundThread( ADCheckResultOnBackgroundThread( ADNotifySuccess( nil, self, _cmd ), @7 ) )
                                                                  delay: 0.1 ];
   
   [ operation_ async ];
   
   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testDoneOnThisThread
{
   [ self prepare ];
   
   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADDoneOnThisThread( ADCheckResultOnThisThread( ADNotifySuccess( nil, self, _cmd ), @7 ) )
                                                                  delay: 0.1 ];
   
   [ operation_ async ];
   
   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testTransformBlock
{
   [ self prepare ];

   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADT_CHECK_RESULT( [ NSNumber numberWithInteger: 56 ] ) ];

   operation_.transformBlock = ^void( id< ADMutableResult > result_ )
   {
      GHAssertTrue( ![ NSThread isMainThread ], @"Should not be main thread" );
      
      result_.result = @([ result_.result intValue ] * 8);
   };

   [ operation_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testCopy
{
   [ self prepare ];
   
   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADT_CHECK_RESULT( [ NSNumber numberWithInteger: 56 ] ) ];

   operation_.transformBlock = ^void( id< ADMutableResult > result_ )
   {
      GHAssertTrue( ![ NSThread isMainThread ], @"Should not be main thread" );

      result_.result = @([ result_.result intValue ] * 8);
   };

   ADBlockOperation* operation_copy_ = [ operation_ copy ];
   GHAssertTrue( [ operation_.name isEqualToString: operation_copy_.name ], @"Names of initial operation and copy should be equal" );

   [ operation_copy_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testTransformOnMainThread
{
   [ self prepare ];
   
   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADT_CHECK_RESULT( [ NSNumber numberWithInteger: 56 ] ) ];

   operation_.doneBlock = ADDoneOnMainThread( ADCheckResultOnMainThread( ADNotifySuccess( nil, self, _cmd ), @56 ) );

   operation_.transformBlock = ADTransfromOnMainThread
   ( ^void( id< ADMutableResult > result_ )
    {
       GHAssertTrue( [ NSThread isMainThread ], @"Should be main thread" );
       result_.result = @([ result_.result intValue ] * 8);
    } );

   [ operation_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testTransformOnFailedResult
{
   [ self prepare ];

   ADBlockOperation* operation_ = [ ADBlockOperation operationWithName: @"failed"
                                                      errorDescription: @"Error description"
                                                             doneBlock: ADNotifySuccess( nil, self, _cmd ) ];

   operation_.transformBlock = ADNoTransformForFailedResult
   ( ^void( id< ADMutableResult > result_ )
    {
       GHAssertTrue( NO, @"Tranform should not be called for failed result" );
    } );

   [ operation_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.2 ];
}

-(void)testWaitRequest
{
   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: nil
                                                                  delay: 2.0 ];

   id< ADRequest > request_ = [ operation_ async ];
   GHAssertFalse( [ request_ waitForTimeInterval: 0.5 ], @"test wait in 0.5" );
   GHAssertFalse( [ request_ waitForTimeInterval: 0.5 ], @"test wait in 1.0" );
   GHAssertFalse( [ request_ waitForTimeInterval: 0.5 ], @"test wait in 1.5" );
   GHAssertTrue( [ request_ waitForTimeInterval: 0.6 ], @"test wait in 2.1" );

   id< ADRequest > request2_ = [ operation_ async ];
   GHAssertFalse( [ request2_ waitForTimeInterval: 0.5 ], @"test wait in 0.5" );
   GHAssertTrue( [ request2_ wait ], @"test wait in 2.1" );
}

-(void)testFilterCancel
{
   [ self prepare ];

   ADDoneBlock fail_if_called_ = ^void( id< ADResult > result_ )
   {
      GHAssertTrue( NO, @"doneBlock must not be called" );
   };

   __block BOOL called_ = NO;
   ADDoneBlock success_if_called_ = ^void( id< ADResult > result_ )
   {
      called_ = YES;
      GHAssertTrue( YES, @"doneBlock must be called" );
   };

   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADFilterCancelledResult( fail_if_called_ )
                                                                  delay: 0.1 ];

   id< ADRequest > request_ = [ operation_ async ];
   [ request_ cancel ];
   [ request_ wait ];

   operation_.doneBlock = success_if_called_;

   id< ADRequest > request2_ = [ operation_ async ];
   [ request2_ wait ];
   GHAssertTrue( called_, @"doneBlock must be called" );
}

-(void)testCancelRequest
{
   [ self prepare ];

   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ^( id< ADResult > result_ )
                                   {
                                      if ( result_.isCancelled && [ result_.result isEqual: @(49) ] )
                                      {
                                         [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
                                      }
                                      else
                                      {
                                         [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
                                      }
                                   }
                                                                  delay: 0.2 ];

   operation_.transformBlock = ^void( id< ADMutableResult > result_ )
   {
      NSInteger plain_result_ = [ result_.result integerValue ];
      result_.result = @(plain_result_ * plain_result_);
   };

   id< ADRequest > request_ = [ operation_ async ];
   ADDelayAsyncOnMainThread(
                            ^()
                            {
                               [ request_ cancel ];
                               GHAssertTrue( request_.isCancelled, @"Result should be cancelled after cancel" );
                            }
                            , 0.1 );

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 0.3 ];
}


@end
