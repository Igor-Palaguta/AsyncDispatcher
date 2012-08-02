#import "ADOperation.h"

/** Abstract class for execution asynchronously group of operations
 */
@interface ADCompositeOperation : ADOperation

@end


/** Composite asynchronous operation that executes all operations sequentially
 All operations will be exectuted in predefined order
 */
@interface ADSequence : ADCompositeOperation

/** Returns an initialized ADSequence object
 @param operations_ operations for execution
 @param name_ operation name
 */
-(id)initWithOperations:( NSArray* )operations_
                   name:( NSString* )name_;

@end


/** Composite asynchronous operation that executes all operations concurrently
 All operations will be exectuted in any order
 */
@interface ADConcurrent : ADCompositeOperation

/** Returns an initialized ADConcurrent object
 @param operations_ operations for execution
 @param name_ operation name
 */
-(id)initWithOperations:( NSArray* )operations_
                   name:( NSString* )name_;

@end
