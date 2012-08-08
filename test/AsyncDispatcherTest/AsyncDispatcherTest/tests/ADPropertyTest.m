#import "ADOperation+ADTConstructors.h"
#import "ADTMacroses.h"

#import <AsyncDispatcher/AsyncDispatcher.h>

@interface PropertyTester : NSObject

@property ( nonatomic, strong ) NSString* value;
@property ( nonatomic, strong ) NSString* failedValue;
@property ( nonatomic, strong ) NSString* expectedValue;
@property ( assign ) BOOL valueWorkerCalled;

@end

@implementation PropertyTester

@synthesize value;
@synthesize failedValue;
@synthesize expectedValue;
@synthesize valueWorkerCalled;

-(ADOperation*)asyncOperationForFailedValue
{
   ADWorkerBlock worker_block_ = ^id( NSError** error_ )
   {
      NSLog( @"Failed Worker", nil );
      [ NSThread sleepForTimeInterval: 1.0 ];
      *error_ = [ NSError new ];
      return nil;
   };

   return [ [ ADBlockOperation alloc ] initWithName: @"failedValue"
                                             worker: worker_block_ ];
}

-(ADOperation*)asyncOperationForKey:( NSString* )key_
{
   if ( [ key_ isEqualToString: @"value" ] )
   {
      ADWorkerBlock worker_block_ = ^id( NSError** error_ )
      {
         NSLog( @"Worker", nil );
         NSAssert( !self.valueWorkerCalled, @"Worker should be called only once" );
         [ NSThread sleepForTimeInterval: 1.0 ];
         return self.expectedValue;
      };

      return [ [ ADBlockOperation alloc ] initWithName: key_
                                                worker: worker_block_ ];
   }

   return [ super asyncOperationForKey: key_ ];
}

@end

typedef BOOL (^ADTResultPredicated)( id< ADResult > result_ );

@interface ADPropertyTest : GHAsyncTestCase

@end

@implementation ADPropertyTest

-(ADDoneBlock)doneBlockWithIndex:( NSUInteger )index_
                          states:( NSMutableArray* )states_
                 resultPredicate:( ADTResultPredicated )predicate_
{
   return ^( id< ADResult > result_ )
   {
      NSLog( @"Done block with index: %d", index_ );
      
      NSAssert( [ states_ count ] == index_, @"Check done block index" );
      
      BOOL success_ = predicate_( result_ );
      NSAssert( success_, @"Check result value" );
      [ states_ addObject: [ NSNumber numberWithBool: success_ ] ];
   };
}

-(ADDoneBlock)failedDoneBlockWithIndex:( NSUInteger )index_
                                states:( NSMutableArray* )states_
{
   return [ self doneBlockWithIndex: index_
                             states: states_
                    resultPredicate: ^BOOL( id< ADResult > result_ ){ return result_.error != nil; } ];
}

-(ADDoneBlock)doneBlockWithIndex:( NSUInteger )index_
                          states:( NSMutableArray* )states_
                  expectedResult:( id )expected_result_
{
   return [ self doneBlockWithIndex: index_
                             states: states_
                    resultPredicate: ^BOOL( id< ADResult > result_ ){ return [ result_.result isEqual: expected_result_ ]; } ];
}

-(void)testPropertyReader
{
   NSString* expected_value_ = @"MyValue";

   PropertyTester* tester_ = [ PropertyTester new ];
   tester_.expectedValue = expected_value_;

   NSMutableArray* states_ = [ NSMutableArray array ];

   [ tester_ asyncValueForKey: @"value"
                    doneBlock: [ self doneBlockWithIndex: 0
                                                  states: states_
                                          expectedResult: expected_value_ ] ];

   ADDelayAsyncOnMainThread( ^()
                            {
                               [ tester_ asyncValueForKey: @"value"
                                                doneBlock: [ self doneBlockWithIndex: 1
                                                                              states: states_
                                                                      expectedResult: expected_value_ ] ];
                            }
                            , 0.5 );

   [ NSThread sleepForTimeInterval: 1.1 ];

   [ tester_ asyncValueForKey: @"value"
                    doneBlock: [ self doneBlockWithIndex: 2
                                                  states: states_
                                          expectedResult: expected_value_ ] ];

   [ NSThread sleepForTimeInterval: 0.1 ];

   GHAssertTrue( [ tester_.value isEqualToString: expected_value_ ], @"Check property value" );

   NSArray* expected_states_ = [ NSArray arrayWithObjects: [ NSNumber numberWithBool: YES ]
                                , [ NSNumber numberWithBool: YES ]
                                , [ NSNumber numberWithBool: YES ]
                                , nil ];

   GHAssertTrue( [ states_ isEqualToArray: expected_states_ ], @"Check states" );
}

-(void)testFailedPropertyReader
{
   PropertyTester* tester_ = [ PropertyTester new ];

   NSMutableArray* states_ = [ NSMutableArray array ];
   
   [ tester_ asyncValueForKey: @"failedValue"
                    doneBlock: [ self failedDoneBlockWithIndex: 0 states: states_ ] ];

   ADDelayAsyncOnMainThread( ^()
                            {
                               [ tester_ asyncValueForKey: @"failedValue"
                                                doneBlock: [ self failedDoneBlockWithIndex: 1 states: states_ ] ];
                            }
                            , 0.5 );
   
   [ NSThread sleepForTimeInterval: 1.1 ];
   
   [ tester_ asyncValueForKey: @"failedValue"
                    doneBlock: [ self failedDoneBlockWithIndex: 2 states: states_ ] ];

   [ NSThread sleepForTimeInterval: 1.1 ];

   GHAssertTrue( tester_.failedValue == nil, @"Check property value" );

   NSArray* expected_states_ = [ NSArray arrayWithObjects: [ NSNumber numberWithBool: YES ]
                                , [ NSNumber numberWithBool: YES ]
                                , [ NSNumber numberWithBool: YES ]
                                , nil ];

   GHAssertTrue( [ states_ isEqualToArray: expected_states_ ], @"Check states" );
}

@end
