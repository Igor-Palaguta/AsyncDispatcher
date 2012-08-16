#import "ADBlockDefs.h"

#import <Foundation/Foundation.h>

/** Stream protocol for asynchronous reading resources such as file or socket
 */
@protocol ADStream <NSObject>

/** Reads mentioned number of bytes, when read completed handler_ callback is called
 @param count_ number of bytes to read
 @param handler_ block that is called on complete
 */
-(void)read:( NSUInteger )count_
    handler:( ADReadHandlerBlock )handler_;

/** Reads bytes by chunk until error or eof, or if handler block returned NO
 @param count_ number of bytes in every read
 @param handler_ block that is called on every read complete
 */
-(void)cyclicRead:( NSUInteger )count_
          handler:( ADReadHandlerBlock )handler_;

@end
