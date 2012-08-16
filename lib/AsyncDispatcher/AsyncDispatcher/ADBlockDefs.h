#import <Foundation/Foundation.h>

@protocol ADResult;
@protocol ADMutableResult;

/** Type for worker block from ADBlockOperation
 @return result of operation or nil in case of error
 */
typedef id (^ADWorkerBlock)( NSError** error_ );

/** Type for done block
 */
typedef void (^ADDoneBlock)( id< ADResult > result_ );

/** Type for transform block
 */
typedef void (^ADTransformBlock)( id< ADMutableResult > result_ );

/** Type for block that can be pushed to apple queue
 */
typedef void (^ADQueueBlock)();

/** Type for block is used for reading data from resource
 */
@protocol ADBuffer;
typedef BOOL (^ADReadHandlerBlock)( BOOL eof_, id< ADBuffer > buffer_, NSError* error_ );


/** Type for block that is used for iterating through buffer chunks
 */
typedef BOOL (^ADChunkHandlerBlock)( const void* data_, NSUInteger size_ );