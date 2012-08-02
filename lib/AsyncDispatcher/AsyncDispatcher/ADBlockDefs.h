#import <Foundation/Foundation.h>

@protocol ADResult;
@protocol ADMutableResult;

/** Type for worker block from ADBlockOperation
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
