#import "ADBlockWrappers.h"

#import "ADResult.h"

ADDoneBlock ADFilterCancelledResult( ADDoneBlock sync_done_block_ )
{
   return ^void( id< ADResult > result_ )
   {
      if ( !result_.isCancelled )
      {
         sync_done_block_( result_ );
      }
   };
}

ADDoneBlock ADDoneOnMainThread( ADDoneBlock sync_done_block_ )
{
   return ^void( id< ADResult > result_ )
   {
      ADAsyncOnMainThread( ^(){ sync_done_block_( result_ ); });
   };
}

ADDoneBlock ADDoneOnBackgroundThread( ADDoneBlock sync_done_block_ )
{
   return ^void( id< ADResult > result_ )
   {
      dispatch_async( dispatch_get_current_queue(), ^()
                     {
                        sync_done_block_( result_ );
                     });
   };
}

ADDoneBlock ADDoneBlockSum( ADDoneBlock first_block_, ADDoneBlock second_block_ )
{
   if ( !first_block_ && !second_block_ )
      return nil;

   return ^void( id< ADResult > result_ )
   {
      if ( first_block_ )
      {
         first_block_( result_ );
      }
      if ( second_block_ )
      {
         second_block_( result_ );
      }
   };
}

ADDoneBlock ADDoneBlockSumArray( NSArray* done_blocks_ )
{
   return ^void( id< ADResult > result_ )
   {
      for ( ADDoneBlock done_block_ in done_blocks_ )
      {
         done_block_( result_ );
      }
   };
}

ADDoneBlock ADDoneLogResult()
{
   return ^void( id< ADResult > result_ )
   {
      NSLog( @"Result: %@", result_ );
   };
}

ADTransformBlock ADTransfromOnMainThread( ADTransformBlock sync_transform_block_ )
{
   return ^void( id< ADMutableResult > mutable_result_ )
   {
      //Should be sync
      ADSyncOnMainThread( ^(){ sync_transform_block_( mutable_result_ ); });
   };
}

void ADAsyncOnMainThread( ADQueueBlock block_ )
{
   dispatch_async( dispatch_get_main_queue(), block_ );
}

void ADSyncOnMainThread( ADQueueBlock block_ )
{
   dispatch_sync( dispatch_get_main_queue(), block_ );
}

void ADDelayAsyncOnMainThread( ADQueueBlock block_, NSTimeInterval time_interval_ )
{
   dispatch_time_t dispatch_time_ = dispatch_time( DISPATCH_TIME_NOW, time_interval_ * NSEC_PER_SEC );

   dispatch_after( dispatch_time_, dispatch_get_main_queue(), block_ );
}
