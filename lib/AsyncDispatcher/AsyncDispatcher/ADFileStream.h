#import "ADStream.h"

#import <Foundation/Foundation.h>

/** File stream
 @warning *Important:* ADFileStream requires iOS >= 5.0
 */
@interface ADFileStream : NSObject< ADStream >

/** Returns ADFileStream instance for path_
 @param path_ path of file, can't be nil
 */
-(id)initWithPath:( NSString* )path_;

@end
