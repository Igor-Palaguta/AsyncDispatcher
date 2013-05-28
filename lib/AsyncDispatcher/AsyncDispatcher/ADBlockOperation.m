#import "ADBlockOperation.h"

#import "ADBlockWrappers.h"

#import "Detail/ADOperation+Private.h"
#import "Detail/ADDispatchQueue.h"
#import "Detail/ADOperationMonitor.h"
#import "Detail/ADMutableResult.h"
#import "Detail/ADBlockUtils.h"

@interface ADBlockOperation ()

@property ( nonatomic, copy ) ADWorkerBlock worker;

@end

@implementation ADBlockOperation

@synthesize worker;

-(ADDispatchQueue*)createQueue
{
   return [ ADDispatchQueue serialQueueWithName: self.name ];
}

-(id)initWithName:( NSString* )name_
           worker:( ADWorkerBlock )worker_
{
   self = [ super initWithName: name_ ];
   if ( self )
   {
      self.worker = worker_;
   }
   return self;
}

-(id< ADMutableResult >)calculateResultForRequest:( id< ADRequest > )request_
                                      withContext:( id )context_
{
   if ( request_.isCancelled )
   {
      return [ ADMutableResult cancelledResult ];
   }

   NSAssert( self.worker, @"self.worker can't be nil" );

   NSError* local_error_ = nil;
   id worker_result_ = self.worker( &local_error_ );

   NSAssert( ( local_error_ && !worker_result_ ) || ( !local_error_ && worker_result_ ), @"worker must return result or error" );

   return [ [ ADMutableResult alloc ] initWithResult: worker_result_
                                               error: local_error_ ];
}

-(id< ADRequest >)asyncWithDoneBlock:( ADDoneBlock )client_done_block_
                             inQueue:( ADDispatchQueue* )queue_
                       parentRequest:( id< ADRequest > )parent_request_
{
   ADOperationMonitor* monitor_ = [ [ ADOperationMonitor alloc ] initWithParentRequest: parent_request_ ];

   [ self asyncWithDoneBlock: client_done_block_
                     inQueue: queue_
                 withMonitor: monitor_ ];

   return monitor_;
}

-(void)asyncWithDoneBlock:( ADDoneBlock )client_done_block_
                  inQueue:( ADDispatchQueue* )queue_
              withMonitor:( ADOperationMonitor* )monitor_
{
   [ monitor_ incrementUsage ];

   ADDoneBlock done_block_ = ADDoneBlockSum( client_done_block_, ADDoneBlockDecrementMonitor( monitor_ ) );

   ADQueueBlock queue_block_ = [ self calculateBlockForRequest: monitor_
                                                     doneBlock: done_block_ ];

   [ queue_ async: queue_block_ withMonitor: monitor_ ];
}

-(id)copyWithZone:( NSZone* )zone_
{
   ADBlockOperation* copy_ = [ super copyWithZone: zone_ ];
   copy_.worker = self.worker;
   return copy_;
}

@end
