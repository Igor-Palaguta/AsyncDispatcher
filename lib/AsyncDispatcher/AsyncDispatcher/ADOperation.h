#import "ADBlockDefs.h"
#import "ADOperationPriority.h"

#import <Foundation/Foundation.h>

@class ADSession;

@protocol ADRequest;

/** Base class for all asynchronous operations
 */
@interface ADOperation : NSObject< NSCopying >

/** Name of operation. Is useful for debugging or for retrieving operation result from ADCompositeResult
 */
@property ( nonatomic, strong, readonly ) NSString* name;

/** Done block is called when operation is done or cancelled
 */
@property ( nonatomic, copy ) ADDoneBlock doneBlock;

/** Transform block is called for result transformation.
 
 After transformormation done block is called with modifeid result
 */
@property ( nonatomic, copy ) ADTransformBlock transformBlock;

/** Operation priority.

 Can be:
 
 ADOperationPriorityDefault - default value
 
 ADOperationPriorityLow - low priority
 
 ADOperationPriorityHigh - high priority
 
 ADOperationPriorityBackground - is used for background tasks
 */
@property ( nonatomic, assign ) ADOperationPriority priority;

/** Returns an initialized ADOperation object
  @param name_ operation name
 */
-(id)initWithName:( NSString* )name_;

/** Adds done block that is executed before any
  @param done_block_ first done block
 */
-(void)addFirstDoneBlock:( ADDoneBlock )done_block_;

/** Initiates async operation
 @return ADRequest object for request manipulation
 */
-(id< ADRequest >)async;

/** Initiates async operation in user session
 @param session_ user session
 @return ADRequest object for request manipulation
 */
-(id< ADRequest >)asyncInSession:( ADSession* )session_;

@end
