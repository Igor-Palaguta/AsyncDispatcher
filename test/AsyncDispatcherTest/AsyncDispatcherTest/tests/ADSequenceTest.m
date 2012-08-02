#import "ADOperation+ADTConstructors.h"
#import "ADTMacroses.h"

#import <AsyncDispatcher/AsyncDispatcher.h>

@interface ADSequenceTest : GHAsyncTestCase

@end

@implementation ADSequenceTest

-(void)testSequenceOfBlocks
{
   [ self prepare ];

   __block NSInteger recent_counter_ = 0;

   NSRange operations_range_ = NSMakeRange( 0, 15 );

   //{0..14}
   ADSequence* sequence_ = [ ADSequence compositeWithOperations: [ NSArray arrayWithOperationsFromRange: operations_range_
                                                                                              doneBlock: ADT_CHECK_AND_INCREMENT_COUNT( recent_counter_ ) ]
                                                           name: @"global"
                                                      doneBlock: ADT_CHECK_TOTAL_COUNT( recent_counter_, NSMaxRange( operations_range_ ) ) ];

   [ sequence_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 2.0 ];
}

-(void)testSequenceOfSequences
{
   [ self prepare ];

   __block NSInteger recent_counter_ = 0;

   const NSInteger sequence_count_ = 15;

   NSRange operations_range_ = NSMakeRange( 0, 15 );

   NSMutableArray* sequences_ = [ NSMutableArray arrayWithCapacity: sequence_count_ ];

   //{{0..14} {15..29} .. {210..224}}
   for ( NSInteger i_ = 0; i_ < sequence_count_; ++i_ )
   {
      NSArray* operations_ = [ NSArray arrayWithOperationsFromRange: operations_range_
                                                          doneBlock: ADT_CHECK_AND_INCREMENT_COUNT( recent_counter_ ) ];

      [ sequences_ addObject: [ ADSequence compositeWithOperations: operations_
                                                              name: [ NSString stringWithFormat: @"%d", i_ ]
                                                         doneBlock: nil ] ];

      operations_range_.location += operations_range_.length;
   }

   ADSequence* global_sequence_ = [ ADSequence compositeWithOperations: sequences_
                                                                  name: @"global"
                                                             doneBlock: ADT_CHECK_TOTAL_COUNT( recent_counter_, operations_range_.location ) ];

   [ global_sequence_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 2.0 ];
}

-(void)testSequenceOfConcurrents
{
   [ self prepare ];

   __block NSInteger recent_counter_ = 0;

   NSRange operations_range_ = NSMakeRange( 0, 15 );

   //{0..14
   NSMutableArray* operations_ = [ NSMutableArray arrayWithOperationsFromRange: operations_range_
                                                                     doneBlock: ADT_CHECK_AND_INCREMENT_COUNT( recent_counter_ ) ];

   operations_range_.location += operations_range_.length;

   //add [29(0.1 sec delay)..15(0 sec delay)]
   {
      NSArray* concurrent_operations_ = [ [ NSArray arrayWithOperationsFromRange: operations_range_
                                                                       doneBlock: ADT_CHECK_AND_INCREMENT_COUNT( recent_counter_ )
                                                                   delayFunction: ADTDirectDelay() ] reverseOrder ];

      ADConcurrent* concurrent_ = [ ADConcurrent compositeWithOperations: concurrent_operations_
                                                                    name: @"concurrent"
                                                               doneBlock: nil ];

      [ operations_ addObject: concurrent_ ];
   }

   operations_range_.location += operations_range_.length;

   //add 30..45}
   {
      [ operations_ addOperationsFromRange: operations_range_
                                 doneBlock: ADT_CHECK_AND_INCREMENT_COUNT( recent_counter_ ) ];
   }

   ADSequence* global_sequence_ = [ ADSequence compositeWithOperations: operations_
                                                                  name: @"global"
                                                             doneBlock: ADT_CHECK_TOTAL_COUNT( recent_counter_, NSMaxRange( operations_range_ ) ) ];

   [ global_sequence_ async ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 2.0 ];
}

-(void)testSequenceCancel
{
   [ self prepare ];

   NSRange operations_range_ = NSMakeRange( 0, 15 );

   __block NSInteger recent_counter_ = 0;

   //{0..14}
   ADSequence* sequence_ = [ ADSequence compositeWithOperations: [ NSArray arrayWithOperationsFromRange: operations_range_
                                                                                              doneBlock: ADT_CHECK_CANCEL_AND_INCREMENT_COUNT( recent_counter_ )
                                                                                          delayFunction: ADTConstDelay( 0.1 ) ]
                                                           name: @"global"
                                                      doneBlock: ADT_CHECK_TOTAL_COUNT( recent_counter_, NSMaxRange( operations_range_ ) ) ];

   id< ADRequest > request_ = [ sequence_ async ];
   [ request_ cancel ];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 2.0 ];
}

-(void)testErrorInSequence
{
   NSRange operations_range_ = NSMakeRange( 0, 15 );
   
   __block NSInteger operations_success_ = 0;
   __block NSInteger operations_failed_ = 0;
   NSMutableArray* operations_ = [ NSMutableArray arrayWithOperationsFromRange: operations_range_
                                                                     doneBlock: ADT_INCREMENT_SUCCESS_CANCELLED( operations_success_, operations_failed_ ) ];

   operations_range_.location += operations_range_.length;

   [ operations_ addObject: [ ADBlockOperation operationWithName: @"failed"
                                                errorDescription: @"Error description"
                                                       doneBlock: ADT_INCREMENT_SUCCESS_CANCELLED( operations_success_, operations_failed_ ) ] ];

   operations_range_.location += 1;
   operations_range_.length = 10;

   [ operations_ addOperationsFromRange: operations_range_
                              doneBlock: ADT_INCREMENT_SUCCESS_CANCELLED( operations_success_, operations_failed_ ) ];

   ADSequence* sequence_ = [ ADSequence compositeWithOperations: operations_
                                                           name: @"global"
                                                      doneBlock: ^( id< ADResult > result_ )
                            {
                               NSLog( @"Result: %@", result_ );
                            }];

   id< ADRequest > request_ = [ sequence_ async ];
   [ request_ wait ];

   GHAssertTrue( operations_success_ == 15, @"Check success operations count" );
   GHAssertTrue( operations_failed_ == 10, @"Check failed operations count" );
}

@end
