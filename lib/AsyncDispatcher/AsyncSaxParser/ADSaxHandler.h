#import "ADXmlDefs.h"

#import <Foundation/Foundation.h>

/** Sax Handler
 */
@protocol ADSaxHandler <NSObject>

@optional
/** Is called when parsing is failed, or stream operation is failed
 @param error_ error
 */
-(void)didFailWithError:( NSError* )error_;

/** Is called when stream reached end
 */
-(void)didComplete;

/** Is called when xml element is started
 @param name_ zero ending pointer to name of element
 @param attributes_ xml attributes
 */
-(void)didStartElementWithName:( const ADXMLChar* )name_
                    attributes:( const ADXMLChar** )attributes_;

/** Is called when xml element is ended
 @param name_ zero ending pointer to name of element
 */
-(void)didEndElementWithName:( const ADXMLChar* )name_;

/** Is called when text inside element is found. Can be called several times for one element
 @param characters_ pointer to found text
 @param length_ length of found text
 */
-(void)didFoundCharacters:( const ADXMLChar* )characters_
               withLength:( int )length_;

/** Is called when xml document is started
 */
-(void)didStartDocument;

/** Is called when xml document is ended
 */
-(void)didEndDocument;

@end
