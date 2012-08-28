#import "ADBlockDefs.h"
#import "Detail/ADExport.h"

/// Creates new done block, that calls sync_done_block_ only if request was not cancelled
AD_EXPORT ADDoneBlock ADFilterCancelledResult( ADDoneBlock sync_done_block_ );


/// Creates new done block, that calls sync_done_block_ on main thread
AD_EXPORT ADDoneBlock ADDoneOnMainThread( ADDoneBlock sync_done_block_ );


/// Creates new done block, that calls sync_done_block_ on background thread
AD_EXPORT ADDoneBlock ADDoneOnBackgroundThread( ADDoneBlock sync_done_block_ );


/// Creates new done block, that calls sync_done_block_ on caller thread
AD_EXPORT ADDoneBlock ADDoneOnThisThread( ADDoneBlock sync_done_block_ );


/// Creates new done block, that calls first_block_ and then first_block_
AD_EXPORT ADDoneBlock ADDoneBlockSum( ADDoneBlock first_block_, ADDoneBlock second_block_ );


/// Creates new done block, that calls all done_blocks_
AD_EXPORT ADDoneBlock ADDoneBlockSumArray( NSArray* done_blocks_ );


/// Prints result to output
AD_EXPORT ADDoneBlock ADDoneLogResult();


/// Creates new transform block, that calls sync_transform_block_ on main thread
AD_EXPORT ADTransformBlock ADTransfromOnMainThread( ADTransformBlock sync_transform_block_ );


/// Performs asynchronously block on main thread
AD_EXPORT void ADAsyncOnMainThread( ADQueueBlock block_ );


/// Performs asynchronously block on main thread and wait until done
AD_EXPORT void ADSyncOnMainThread( ADQueueBlock block_ );


/// Performs asynchronously block on main thread after delay
AD_EXPORT void ADDelayAsyncOnMainThread( ADQueueBlock block_, NSTimeInterval time_interval_ );
