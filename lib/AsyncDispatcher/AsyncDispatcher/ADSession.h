#import <Foundation/Foundation.h>

@protocol ADRequest;

/// Session manages all asynchronous requests
@interface ADSession : NSObject

/// Requests added to session
@property ( strong, readonly ) NSSet* requests;

/// Returns shared session
+(ADSession*)sharedSession;

/// Adds request to session
/// @param request_ new session request
-(void)addRequest:( id< ADRequest > )request_;

/// Removes request to session
/// @param request_ session request for delete
-(void)removeRequest:( id< ADRequest > )request_;

/// Cancel all requests
-(void)cancelAll;

/// Returns requests count
-(NSUInteger)count;

@end
