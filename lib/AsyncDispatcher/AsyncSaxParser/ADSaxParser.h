#import <Foundation/Foundation.h>

@protocol ADStream;
@protocol ADSaxHandler;

@interface ADSaxParser : NSObject

-(id)initWithStream:( id< ADStream > )stream_
            handler:( id< ADSaxHandler > )sax_handler_;

-(id)initWithContentsOfFile:( NSString* )path_
                    handler:( id< ADSaxHandler > )sax_handler_;

-(void)cancel;

@end
