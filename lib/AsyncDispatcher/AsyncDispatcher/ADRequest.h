#import <Foundation/Foundation.h>

/// Protocol for manipulation asynchronous process
@protocol ADRequest <NSObject>

/// Cancel operation, cancel all uncompleted operations in composite operation
-(void)cancel;

/// Indicates if operation is cancelled or not
-(BOOL)isCancelled;

/** Waits complete of operation
 @return YES if operation completed, otherwise - NO
 */
-(BOOL)wait;

/** Waits complete of operation
 @param seconds_ time for wait
 @return YES if operation completed, otherwise - NO
 */
-(BOOL)waitForTimeInterval:( NSTimeInterval )seconds_;

//If parent request is cancelled this request is cancelled too
-(void)setParentRequest:( id< ADRequest > )request_;

@end
