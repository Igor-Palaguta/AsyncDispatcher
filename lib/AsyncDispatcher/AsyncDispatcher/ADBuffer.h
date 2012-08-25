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

/** Returns gathered all buffers into NSString instance
 */
-(NSString*)string;

@end

/** Represents mutable buffer
 */
@protocol ADMutableBuffer <ADBuffer>

/** Appends to the receiver a given number of bytes from a given buffer.
 @param buffer_ A buffer containing data to append to the receiver's content.
 @param length_ The number of bytes from bytes to append.
 */
-(void)addBuffer:( const void* )buffer_
          length:( NSUInteger )length_;

@end

/** Class that implements ADMutableBuffer protocol
 */
@interface ADMutableBuffer : NSObject< ADMutableBuffer >

/** Creates and returns a data object containing a given number of bytes without copy from a given buffer.
 @param buffer_ A buffer containing data for the new object.
 @param length_ The number of bytes. This value must not exceed the length of bytes.
 */
-(id)initWithBuffer:( const void* )buffer_
             length:( NSUInteger )length_;

@end
