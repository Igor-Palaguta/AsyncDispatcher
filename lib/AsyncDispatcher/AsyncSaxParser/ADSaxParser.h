#import <Foundation/Foundation.h>

@protocol ADStream;
@protocol ADSaxHandler;

/** Asynhronous sax parser. Works with streams. Parses streams reading chunks 
 */
@interface ADSaxParser : NSObject

/** Returns ADSaxParser instance
 @param stream_ data source
 @param sax_handler_ sax handler
 */
-(id)initWithStream:( id< ADStream > )stream_
            handler:( id< ADSaxHandler > )sax_handler_;

/** Returns ADSaxParser instance with file as stream
 @param path_ path to xml file
 @param sax_handler_ sax handler
 */
-(id)initWithContentsOfFile:( NSString* )path_
                    handler:( id< ADSaxHandler > )sax_handler_;

/** Cancels parsing
 */
-(void)cancel;

@end
