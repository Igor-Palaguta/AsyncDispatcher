#import "ADOperation+Private.h"

#import "ADResult.h"
#import "ADRequest.h"
#import "ADBlockWrappers.h"

#import "ADMutableResult.h"
#import "ADOperationMonitor.h"

@implementation ADOperation (Private)

#pragma mark - method for override

-(id< ADMutableResult >)calculateResultForRequest:( id< ADRequest > )request_
                                      withContext:( id )context_
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

-(ADDispatchQueue*)createQueue
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

-(id< ADRequest >)asyncWithDoneBlock:( ADDoneBlock )client_done_block_
                             inQueue:( ADDispatchQueue* )queue_
{
   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

-(void)asyncWithDoneBlock:( ADDoneBlock )client_done_block_
                  inQueue:( ADDispatchQueue* )queue_
              withMonitor:( ADOperationMonitor* )monitor_
{
   [ self doesNotRecognizeSelector: _cmd ];
}

#pragma mark -

-(id< ADMutableResult >)checkedResult:( id< ADMutableResult > )result_
                           forRequest:( id< ADRequest > )request_
{
   if ( request_.isCancelled )
   {
      [ result_ setCancelled: YES ];
   }

   return result_;
}

-(ADDoneBlock)wrapDoneBlock:( ADDoneBlock )done_block_
                 forRequest:( id< ADRequest > )request_
{
   return ^( id< ADResult > result_ )
   {
      done_block_( [ self checkedResult: ( id< ADMutableResult > )result_ forRequest: request_ ] );
   };
}

-(ADTransformBlock)wrapTransfromWithDoneBlock:( ADDoneBlock )done_block_
                                   forRequest:( id< ADRequest > )request_
{
   return ^( id< ADMutableResult > result_ )
   {
      id< ADMutableResult > checked_result_ = [ self checkedResult: result_ forRequest: request_ ];

      if ( !checked_result_.isCancelled )
      {
         self.transformBlock( result_ );
      }

      if ( done_block_)
      {
         [ self wrapDoneBlock: done_block_
                   forRequest: request_ ]( checked_result_ );
      }
   };
}

-(void)sendResult:( id< ADMutableResult > )result_
    withDoneBlock:( ADDoneBlock )done_block_
       forRequest:( id< ADRequest > )request_
{
   if ( self.transformBlock )
   {
      [ self wrapTransfromWithDoneBlock: done_block_
                             forRequest: request_ ]( result_ );
   }
   else if ( done_block_ )
   {
      [ self wrapDoneBlock: done_block_
                forRequest: request_ ]( result_ );
   }
}

-(ADQueueBlock)queueBlockForRequest:( id< ADRequest > )request_
                          doneBlock:( ADDoneBlock )client_done_block_
{
   return [ self queueBlockForRequest: request_
                            doneBlock: client_done_block_
                              context: nil ];
}

-(ADQueueBlock)queueBlockForRequest:( id< ADRequest > )request_
                          doneBlock:( ADDoneBlock )client_done_block_
                            context:( id )context_
{
   ADDoneBlock done_block_ = ADDoneBlockSum( self.doneBlock, client_done_block_ );

   return ^()
   {
      ADMutableResult* result_ = [ self calculateResultForRequest: request_ withContext: context_ ];

      [ self sendResult: result_
          withDoneBlock: done_block_
             forRequest: request_ ];
   };
}

-(id< ADRequest >)asyncWithDoneBlock:( ADDoneBlock )done_block_
{
   ADDispatchQueue* queue_ = [ self createQueue ];
   return [ self asyncWithDoneBlock: done_block_ inQueue: queue_ ];
}

@end
