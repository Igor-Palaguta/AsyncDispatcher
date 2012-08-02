#import "ADBlockDefs.h"

#import <Foundation/Foundation.h>

@protocol ADRequest;

/** Protocol common for all asynchronous operations: ADBlockOperation, ADConcurrent, ADSequence
 */
@protocol ADOperation <NSObject>

/** Returns name of operation. Is useful for debugging or for retrieving operation result from ADCompositeResult
 */
-(NSString*)name;

/** Sets done block that will be called when operation will be done or cancelled
 @param done_block_ Done block
 */
-(void)setDoneBlock:( ADDoneBlock )done_block_;

/** Sets transform block that is called for result transformation.
 After transformormation done block is called with modifeid result
 @param transform_block_ Done block
 */
-(void)setTransformBlock:( ADTransformBlock )transform_block_;

/** Initiates async operation
 @return ADRequest object for request manipulation
 */
-(id< ADRequest >)async;

@end


/** Base class for all asynchronous operations
 */
@interface ADOperation : NSObject< ADOperation >

/// Operation name
@property ( nonatomic, strong, readonly ) NSString* name;
/// Done block
@property ( nonatomic, copy ) ADDoneBlock doneBlock;
/// Transform block
@property ( nonatomic, copy ) ADTransformBlock transformBlock;

/** Returns an initialized ADOperation object
  @param name_ operation name
 */
-(id)initWithName:( NSString* )name_;

@end
