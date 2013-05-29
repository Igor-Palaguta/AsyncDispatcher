#import "ADCompositeOperation.h"

#import "ADBlockWrappers.h"

#import "Detail/ADOperationMonitor.h"
#import "Detail/ADDispatchQueue.h"
#import "Detail/ADMutableCompositeResult.h"
#import "Detail/ADMutableResult.h"
#import "Detail/ADOperation+Private.h"
#import "Detail/ADBlockUtils.h"
#import "Detail/ADSemaphore.h"

#include <libkern/OSAtomic.h>

@interface ADCompositeOperation ()

@property ( nonatomic, strong ) NSArray* operations;
@property ( nonatomic, assign, getter=isConcurrent ) BOOL concurrent;

@end

@implementation ADCompositeOperation : ADOperation

@synthesize operations;
@synthesize concurrent;

-(id)initWithName:( NSString* )name_
       operations:( NSArray* )operations_
       concurrent:( BOOL )concurrent_
{
   self = [ super initWithName: name_ ];
   if ( self )
   {
      self.operations = operations_;
      self.concurrent = concurrent_;
   }
   return self;
}

#pragma mark - Overriden methods

-(ADDispatchQueue*)createQueue
{
   return [ [ ADDispatchQueue alloc ] initWithName: self.name concurrent: self.isConcurrent ];
}

-(id< ADMutableResult >)calculateResultForRequest:( id< ADRequest > )request_
                                      withContext:( id )context_
{
   return ( ADMutableCompositeResult* )context_;
}

-(void)asyncWithDoneBlock:( ADDoneBlock )done_block_
                  inQueue:( ADDispatchQueue* )queue_
                  monitor:( ADOperationMonitor* )monitor_
                lifeCycle:( id< ADLifeCycle > )life_cycle_
{
   ADMutableCompositeResult* composite_result_ = [ ADMutableCompositeResult new ];

   [ monitor_ incrementUsage ];
  
   __block volatile int32_t operations_todo_ = [ self.operations count ];
   ADQueueBlock calculate_block_ = [ self calculateBlockForRequest: monitor_
                                                         doneBlock: done_block_
                                                           context: composite_result_ ];

   for ( ADOperation* operation_ in self.operations )
   {
      [ life_cycle_ birth: operation_ ];

      ADDoneBlock operation_done_block_ = ^( id< ADResult > result_ )
      {
         int32_t operations_remain_ = OSAtomicDecrement32( &operations_todo_ );

         [ composite_result_ setResult: result_ forName: operation_.name ];

         if ( result_.isCancelled || result_.error )
         {
            [ monitor_ cancel ];
         }
         [ life_cycle_ death: operation_ ];
         
         if ( operations_remain_ == 0 && calculate_block_ )
         {
            calculate_block_();
         }
      };

      [ operation_ asyncWithDoneBlock: operation_done_block_
                              inQueue: queue_
                          withMonitor: monitor_ ];
   }

   [ monitor_ decrementUsage ];
}

-(id< ADRequest >)asyncWithDoneBlock:( ADDoneBlock )done_block_
                             inQueue:( ADDispatchQueue* )queue_
                       parentRequest:( id< ADRequest > )parent_request_
{
   ADOperationMonitor* monitor_ = [ [ ADOperationMonitor alloc ] initWithParentRequest: parent_request_ ];

   [ self asyncWithDoneBlock: done_block_
                     inQueue: queue_
                     monitor: monitor_
                   lifeCycle: nil ];
   
   return monitor_;
}

-(void)asyncWithDoneBlock:( ADDoneBlock )client_done_block_
                  inQueue:( ADDispatchQueue* )queue_
              withMonitor:( ADOperationMonitor* )monitor_
{
   //If operation and queue has same type they can be performed in same queue
   //e.g. sequence operation in serial queue,
   //concurrent operation in concurrent queue
   if ( queue_.isConcurrent == self.isConcurrent )
   {
      [ monitor_ incrementUsage ];
      ADDoneBlock done_block_ = ADDoneBlockSum( client_done_block_, ADDoneBlockDecrementMonitor( monitor_ ) );
      [ self asyncWithDoneBlock: done_block_ inQueue: queue_ parentRequest: monitor_ ];
   }
   //If concurrent is pushed to serial queue, serial queue should be paused
   else if ( !queue_.isConcurrent )
   {
      [ queue_ async: ^()
       {
          [ queue_ pause ];

          [ monitor_ incrementUsage ];

          ADDoneBlock done_block_ = ADDoneBlockSum
          ( client_done_block_, ^( id< ADResult > result_ )
           {
              NSLog(@"client_done_block_: %@", self.name);
              [ queue_ resume ];
              [ monitor_ decrementUsage ];
           }
           );

          [ self asyncWithDoneBlock: done_block_ parentRequest:  monitor_ ];
       }
         withMonitor: monitor_ ];
   }
   //If sequence is pushed to concurrent, execute operation in own queue
   else
   {
      [ monitor_ incrementUsage ];
      ADDoneBlock done_block_ = ADDoneBlockSum( client_done_block_, ADDoneBlockDecrementMonitor( monitor_ ) );
      [ self asyncWithDoneBlock: done_block_ parentRequest: monitor_ ];
   }
}

-(id)copyWithZone:( NSZone* )zone_
{
   ADCompositeOperation* copy_ = [ super copyWithZone: zone_ ];
   copy_.operations = self.operations;
   copy_.concurrent = self.isConcurrent;
   return copy_;
}

@end


@implementation ADSequence

-(id)initWithName:( NSString* )name_
       operations:( NSArray* )operations_
{
   return [ self initWithName: name_
                   operations: operations_
                   concurrent: NO ];
}

@end

@implementation ADConcurrent

@synthesize maxConcurrentOperationsCount;

-(id)initWithName:( NSString* )name_
       operations:( NSArray* )operations_
{
   return [ self initWithName: name_
                   operations: operations_
                   concurrent: YES ];
}

-(id< ADRequest >)asyncWithDoneBlock:( ADDoneBlock )done_block_
                             inQueue:( ADDispatchQueue* )queue_
                       parentRequest:( id< ADRequest > )parent_request_
{
   if ( self.maxConcurrentOperationsCount > 0 && [ self.operations count ] > self.maxConcurrentOperationsCount )
   {
      ADSemaphore* semaphore_ = [ ADSemaphore semaphoreWithValue: self.maxConcurrentOperationsCount ];
      ADOperationMonitor* monitor_ = [ [ ADOperationMonitor alloc ] initWithParentRequest: parent_request_ ];

      [ queue_ async: ^()
       {
          [ self asyncWithDoneBlock: done_block_
                            inQueue: queue_
                            monitor: monitor_
                          lifeCycle: semaphore_ ];
       }];

      return monitor_;
   }

   return [ super asyncWithDoneBlock: done_block_ inQueue: queue_ parentRequest: parent_request_ ];
}

-(id)copyWithZone:( NSZone* )zone_
{
   ADConcurrent* copy_ = [ super copyWithZone: zone_ ];
   copy_.maxConcurrentOperationsCount = self.maxConcurrentOperationsCount;
   return copy_;
}

@end
