#import "ADStream.h"

#import <Foundation/Foundation.h>

/** File stream
 */
@interface ADFileStream : NSObject< ADStream >

/** Returns ADFileStream instance for path_
 @param path_ path of file, can't be nil
 */
-(id)initWithPath:( NSString* )path_;

@end
