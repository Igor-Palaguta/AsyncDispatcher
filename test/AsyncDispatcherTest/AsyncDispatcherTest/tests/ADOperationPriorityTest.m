#import <AsyncDispatcher/AsyncDispatcher.h>

@interface ADOperationPriorityTest : GHAsyncTestCase

@end

@implementation ADOperationPriorityTest

-(ADOperation*)operationWithName:( NSString* )name_
                        priority:( ADOperationPriority )priority_
                          states:( NSMutableArray* )states_
{
   NSDate* now_ = [ NSDate date ];

   ADWorkerBlock worker_ = ^id( NSError** error_ )
   {
      long long result_ = 0;
      for ( long long i_ = 0; i_ < 1000000000; ++i_ )
      {
         result_ += i_;
      }
      
      NSTimeInterval time_spent_ = -[ now_ timeIntervalSinceNow ];
      return @(time_spent_);
   };

   ADBlockOperation* operation_ = [ [ ADBlockOperation alloc ] initWithName: name_
                                                                     worker: worker_ ];

   operation_.doneBlock = ^( id< ADResult > result_ )
   {
      NSLog( @"%@ time spent: %@", name_, result_.result );
      [ states_ addObject: name_ ];
   };;

   operation_.priority = priority_;

   return operation_;
}

-(void)testPriority
{
   [ self prepare ];

   NSMutableArray* states_ = [ NSMutableArray array ];

   {
      ADOperation* operation_ = [ self operationWithName: @"low"
                                                priority: ADOperationPriorityLow
                                                  states: states_ ];

      [ operation_ async ];
   }

   {
      ADOperation* operation_ = [ self operationWithName: @"background"
                                                priority: ADOperationPriorityBackground
                                                  states: states_ ];

      operation_.doneBlock = ADDoneBlockSum( operation_.doneBlock, ^( id< ADResult > result_ )
                                            {
                                               [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
                                            });

      [ operation_ async ];
   }
   
   {
      ADOperation* operation_ = [ self operationWithName: @"default"
                                                priority: ADOperationPriorityDefault
                                                  states: states_ ];

      [ operation_ async ];
   }

   {
      ADOperation* operation_ = [ self operationWithName: @"high"
                                                priority: ADOperationPriorityHigh
                                                  states: states_ ];

      [ operation_ async ];
   }

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 60.0 ];

   NSArray* expected_states_ = @[@"high"
                                , @"default"
                                , @"low"
                                , @"background"];

   GHAssertTrue( [ states_ isEqualToArray: expected_states_ ], @"Compare real states: %@ with expected states: %@", states_, expected_states_ );
}

@end
