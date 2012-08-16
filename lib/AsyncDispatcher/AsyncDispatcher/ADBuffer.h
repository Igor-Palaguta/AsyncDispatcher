#import "ADBlockDefs.h"

#import <Foundation/Foundation.h>

/** Represents buffer, can incapsulate set of buffers
 */
@protocol ADBuffer <NSObject>

/** Iterates through every buffer. Returns NO if iterating was interrupted
 @param chunk_block_ - is called for every separate subbufer, if it returns NO iterating is stopped
 
 */
-(BOOL)eachChunk:( ADChunkHandlerBlock )chunk_block_;

/** Returns total number of bytes
 */
-(NSUInteger)size;

/** Returns gathered all buffers into NSData instance
 */
-(NSData*)data;

@end
