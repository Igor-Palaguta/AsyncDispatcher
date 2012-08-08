#import "ADBlockDefs.h"

#import <Foundation/Foundation.h>

@class ADOperation;

/** Category for registering done callbacks that are called when async operation is completed
 */

@interface NSObject (AsyncKVC)

/** Requests async reading of value by key.

 If value is not nil - done block is called immediately,
 otherwise - done block will be called as soon as value is ready.
 @param key_ - name of key
 @param done_block_ - done block
 */
-(void)asyncValueForKey:( NSString* )key_
              doneBlock:( ADDoneBlock )done_block_;

/** Returns async operation for reading value by key
 @param key_ - name of key
 */
-(ADOperation*)asyncOperationForKey:( NSString* )key_;

@end
