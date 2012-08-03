#import "ADCompositeOperation.h"

#import "ADBlockWrappers.h"

#import "Detail/ADOperationMonitor.h"
#import "Detail/ADDispatchQueue.h"
#import "Detail/ADMutableCompositeResult.h"
#import "Detail/ADMutableResult.h"
#import "Detail/ADOperation+Private.h"
#import "Detail/ADBlockUtils.h"

@interface ADCompositeOperation ()

@property ( nonatomic, strong ) NSArray* operations;
@property ( nonatomic, assign, getter=isConcurrent ) BOOL concurrent;

@end

@implementation ADCompositeOperation : ADOperation

@synthesize operations;
@synthesize concurrent;

-(id)initWithOperations:( NSArray* )operations_
                   name:( NSString* )name_
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

-(id< ADRequest >)asyncWithDoneBlock:( ADDoneBlock )done_block_
                             inQueue:( ADDispatchQueue* )queue_
{
   ADOperationMonitor* monitor_ = [ ADOperationMonitor new ];

   ADMutableCompositeResult* composite_result_ = [ ADMutableCompositeResult new ];

   for ( ADOperation* operation_ in self.operations )
   {
      ADDoneBlock operation_done_block_ = ^( id< ADResult > result_ )
      {
         [ composite_result_ setResult: result_ forName: operation_.name ];
         
         if ( result_.isCancelled || result_.error )
         {
            [ monitor_ cancel ];
         }
      };

      [ operation_ asyncWithDoneBlock: operation_done_block_
                              inQueue: queue_
                          withMonitor: monitor_ ];
   }

   [ queue_ reqisterCompleteBlock: [ self queueBlockForRequest: monitor_ doneBlock: done_block_ context: composite_result_ ]
                       forMonitor: monitor_ ];

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
      [ self asyncWithDoneBlock: done_block_ inQueue: queue_ ];
   }
   //If concurrent is pushed to serial queue, serial queue should be paused
   else if ( !queue_.isConcurrent )
   {
      [ queue_ async: ^()
       {
          [ queue_ pause ];
          ADDoneBlock done_block_ = ADDoneBlockSum( client_done_block_, ADDoneBlockResumeQueue( queue_ ) );
          [ self asyncWithDoneBlock: done_block_ ];
       }
         withMonitor: monitor_ ];
   }
   //If sequence is pushed to concurrent, execute operation in own queue
   else
   {
      [ monitor_ incrementUsage ];
      ADDoneBlock done_block_ = ADDoneBlockSum( client_done_block_, ADDoneBlockDecrementMonitor( monitor_ ) );
      [ self asyncWithDoneBlock: done_block_ ];
   }
}

@end


@implementation ADSequence

-(id)initWithOperations:( NSArray* )operations_
                   name:( NSString* )name_
{
   return [ self initWithOperations: operations_
                               name: name_
                         concurrent: NO ];
}

@end

@implementation ADConcurrent

-(id)initWithOperations:( NSArray* )operations_
                   name:( NSString* )name_
{
   return [ self initWithOperations: operations_
                               name: name_
                         concurrent: YES ];
}

@end