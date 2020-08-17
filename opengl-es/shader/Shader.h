//
//  Shader.h
//  opengl-es
//
//  Created by blackox626 on 2020/8/11.
//  Copyright © 2020 vdian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface Shader : NSObject

@property(nonatomic,assign) GLuint programId;

- (Shader *)init:(NSString *)shaderName;

- (Shader *)init:(NSString *)vname fname:(NSString *)fname;

- (void)use;

- (void)setInt:(NSString *)name value:(int)value;

@end

NS_ASSUME_NONNULL_END
