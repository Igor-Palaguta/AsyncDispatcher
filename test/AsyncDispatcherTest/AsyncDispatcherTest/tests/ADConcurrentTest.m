#import "ADOperation+ADTConstructors.h"
#import "ADTMacroses.h"

#import <AsyncDispatcher/AsyncDispatcher.h>

@interface ADConcurrentTest : GHAsyncTestCase

@end

@implementation ADConcurrentTest

-(void)testConcurrentBlocks
{
   [ self prepare ];

   __block NSInteger operation_index_ = 0;

   NSRange operations_range_ = NSMakeRange( 0, 15 );

   //add 14(0.1 sec delay)..0(0 sec delay)
   NSArray* concurrent_operations_ = [ [ NSArray arrayWithOperationsFromRange: operations_range_
                                                                    doneBlock: ADT_CHECK_AND_INCREMENT_COUNT( operation_index_ )
                                                                delayFunction: ADTIndexDelay() ] reverseOrder ];

   ADConcurrent* concurrent_ = [ ADConcurrent compositeWithOperations: concurrent_operations_
                                                                 name: nil
                                                            doneBlock: ADT_CHECK_TOTAL_COUNT( operation_index_, NSMaxRange( operations_range_ ) ) ];

   [ concurrent_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 2.0 ];
}

-(void)testConcurrentOfConcurrents
{
   [ self prepare ];
   
   __block NSInteger operation_index_ = 0;

   const NSInteger concurrents_count_ = 5;

   NSRange operations_range_ = NSMakeRange( 0, 3 );

   NSMutableArray* concurrents_ = [ NSMutableArray arrayWithCapacity: concurrents_count_ ];

   //add[[14(1.4 sec delay)..12(1.2)] .. [2(0.2)..0(0 sec delay)]]
   for ( NSInteger i_ = 0; i_ < concurrents_count_; ++i_, operations_range_.location += operations_range_.length )
   {
      NSArray* operations_ = [ [ NSArray arrayWithOperationsFromRange: operations_range_
                                                            doneBlock: ADT_CHECK_AND_INCREMENT_COUNT( operation_index_ )
                                                        delayFunction: ADTIndexDelay() ] reverseOrder ];

      [ concurrents_ addObject: [ ADConcurrent compositeWithOperations: operations_
                                                                  name: [ NSString stringWithFormat: @"%d", i_ ]
                                                             doneBlock: nil ] ];
   }

   ADConcurrent* concurrent_ = [ ADConcurrent compositeWithOperations: [ concurrents_ reverseOrder ]
                                                                 name: nil
                                                            doneBlock: ADT_CHECK_TOTAL_COUNT( operation_index_, operations_range_.location ) ];

   [ concurrent_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 2.0 ];
}

-(void)testConcurrentOfSequences
{
   [ self prepare ];

   __block NSInteger operation_index_ = 0;

   const NSInteger sequence_count_ = 3;

   NSRange operations_range_ = NSMakeRange( 0, 15 );

   NSMutableArray* sequences_ = [ NSMutableArray arrayWithCapacity: sequence_count_ ];

   //[ {0(0 delay), 3(0.3 delay), 6, 9, 12} {1, 4, 7, 10, 13} {2, 5, 8, 11, 14} ]
   for ( NSInteger i_ = 0; i_ < sequence_count_; ++i_, ++operations_range_.location )
   {
      ADTDelayFunction delay_function_ = ^NSTimeInterval( NSInteger index_, NSRange range_ )
      {
         if ( index_ < sequence_count_ )
            return i_ * 0.025;

         return 0.1;
      };

      NSArray* operations_ = [ NSArray arrayWithOperationsFromRange: operations_range_
                                                          doneBlock: ADT_CHECK_AND_INCREMENT_COUNT( operation_index_ )
                                                      delayFunction: delay_function_
                                                               step: sequence_count_ ];

      [ sequences_ addObject: [ ADSequence compositeWithOperations: operations_
                                                              name: [ NSString stringWithFormat: @"%d", i_ ]
                                                         doneBlock: nil ] ];
   }

   ADConcurrent* global_sequence_ = [ ADConcurrent compositeWithOperations: [ sequences_ reverseOrder ]
                                                                      name: nil
                                                                 doneBlock: ADT_CHECK_TOTAL_COUNT( operation_index_, operations_range_.length ) ];

   [ global_sequence_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 2.0 ];
}

@end
