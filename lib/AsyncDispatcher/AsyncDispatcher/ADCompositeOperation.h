#import "ADOperation.h"

/** Abstract class for execution asynchronously group of operations
 */
@interface ADCompositeOperation : ADOperation

@end


/** Composite asynchronous operation that executes all operations sequentially.
 All operations will be exectuted in predefined order
 */
@interface ADSequence : ADCompositeOperation

/** Returns an initialized ADSequence object
 @param name_ operation name
 @param operations_ operations for execution
 */
-(id)initWithName:( NSString* )name_
       operations:( NSArray* )operations_;

@end


/** Composite asynchronous operation that executes all operations concurrently.
 All operations will be exectuted in any order
 
 In case if one of child operations is concurrent they are also executed in same queue
 */
@interface ADConcurrent : ADCompositeOperation

//!TODO
/** Max count of operation that can be exectuted concurrently including child concurrent operations
 */
@property ( nonatomic, assign ) NSUInteger maxConcurrentOperationsCount;

/** Returns an initialized ADConcurrent object
 @param name_ operation name
 @param operations_ operations for execution
 */
-(id)initWithName:( NSString* )name_
       operations:( NSArray* )operations_;

@end
