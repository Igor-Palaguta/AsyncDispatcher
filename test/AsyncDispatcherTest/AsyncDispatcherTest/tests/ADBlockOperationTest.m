#import "ADOperation+ADTConstructors.h"
#import "ADTMacroses.h"
#import "ADDoneBlockChecker.h"

#import <AsyncDispatcher/AsyncDispatcher.h>

@interface ADBlockOperationTest : GHAsyncTestCase

@end

@implementation ADBlockOperationTest

-(void)testDoneBlock
{
   [ self prepare ];

   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADT_CHECK_RESULT( [ NSNumber numberWithInteger: 7 ] )
                                                                  delay: 2 ];

   [ operation_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 3.0 ];
}

-(void)testDoneOnMainThread
{
   [ self prepare ];
   
   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADDoneOnMainThread( ADCheckResultOnMainThread( ADNotifySuccess( nil, self, _cmd ), [ NSNumber numberWithInteger: 7 ] ) )
                                                                  delay: 2 ];

   [ operation_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 3.0 ];
}

-(void)testTransformBlock
{
   [ self prepare ];

   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADT_CHECK_RESULT( [ NSNumber numberWithInteger: 56 ] ) ];

   operation_.transformBlock = ^void( id< ADMutableResult > result_ )
   {
      GHAssertTrue( ![ NSThread isMainThread ], @"Should be main thread" );
      
      result_.result = [ NSNumber numberWithInteger: [ result_.result intValue ] * 8 ];
   };

   [ operation_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1.0 ];
}

-(void)testTransformOnMainThread
{
   [ self prepare ];
   
   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: ADT_CHECK_RESULT( [ NSNumber numberWithInteger: 56 ] ) ];

   operation_.doneBlock = ADDoneOnMainThread( ADCheckResultOnMainThread( ADNotifySuccess( nil, self, _cmd ), [ NSNumber numberWithInteger: 56 ] ) );

   operation_.transformBlock = ADTransfromOnMainThread
   ( ^void( id< ADMutableResult > result_ )
    {
       GHAssertTrue( [ NSThread isMainThread ], @"Should be main thread" );
       result_.result = [ NSNumber numberWithInteger:[ result_.result intValue ] * 8 ];
    } );

   [ operation_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1.0 ];
}

-(void)testCancelRequest
{
   [ self prepare ];

   ADDoneBlock done_block_ = ^void( id< ADResult > result_ )
   {
      GHAssertTrue( result_.isCancelled, @"Result should be cancelled in doneBlock" );
      [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
   };

   ADBlockOperation* operation_ = [ ADBlockOperation operationWithIndex: 7
                                                              doneBlock: done_block_
                                                                  delay: 2 ];

   operation_.transformBlock = ^void( id< ADMutableResult > result_ )
   {
      GHAssertTrue( NO, @"transformBlock should not be called when request was cancelled" );
   };

   id< ADRequest > request_ = [ operation_ async ];

   ADDelayAsyncOnMainThread(
                            ^()
                            {
                               [ request_ cancel ];
                               GHAssertTrue( request_.isCancelled, @"Result should be cancelled after cancel" );
                            }
                            , 1.9 );

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 3.0 ];
   GHAssertTrue( request_.isCancelled, @"Request should be cancelled" );
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
                                                                  delay: 1.0 ];

   id< ADRequest > request_ = [ operation_ async ];
   [ request_ cancel ];
   [ request_ wait ];

   operation_.doneBlock = success_if_called_;

   id< ADRequest > request2_ = [ operation_ async ];
   [ request2_ wait ];
   GHAssertTrue( called_, @"doneBlock must be called" );
}

@end