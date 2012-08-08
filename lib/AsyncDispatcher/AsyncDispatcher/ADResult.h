#import <Foundation/Foundation.h>


/// Result of asynchronous operation is used in done callback
@protocol ADResult <NSObject>

/// Returns data of result
-(id)result;

/// Returns error of operation
-(NSError*)error;

/** Returns indication if request was cancelled.
 
 Result can be cancelled when user cancelled request,
 or if in composite operation one of operations failed or finished with error.
 
 If request was cancelled when operation was in process result or error can be not nil
 */
-(BOOL)isCancelled;

@end


/// Mutable result of asynchronous operation is used in transfrom block
@protocol ADMutableResult <ADResult>

/** Sets result of operation
 @param result_ result of operation
 */
-(void)setResult:( id )result_;

/** Sets error of operation
 @param error_ error of operation
 */
-(void)setError:( NSError* )error_;

/** Sets cancel flag
 @param cancelled_ cancel flag
 */
-(void)setCancelled:( BOOL )cancelled_;

@end


/// Result of composite operation
@protocol ADCompositeResult <NSObject>

/** Returns result of operation by name
  @param name_ name of operation
  @return result of operation by name
 */
-(id< ADResult >)resultForName:( NSString* )name_;

@end


/// Mutable result of composite operation
@protocol ADMutableCompositeResult <ADCompositeResult>

/** Sets result for operation with name
 
 If name is nil result is not saved
 @param result_ result of operation
 @param name_ name of operation
 */
-(void)setResult:( id< ADResult > )result_
         forName:( NSString* )name_;

@end
