//
//  LiveAudioRecorder.h
//  webRtcSample
//
//  Created by 罗亮富 on 14-1-17.
//  Copyright (c) 2014年 Lolaage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#include "Roen_CircleBuffer.h"

#define kRecorderBufSize 480

#define kRecorderBufNum   3

@class LiveAudioRecorder;
@protocol LiveAudioRecroderDelegate <NSObject>

-(void)audioRecroder:(LiveAudioRecorder *)reader didReadAudioData:(char *)bytes length:(unsigned int)len;

@end

@interface LiveAudioRecorder : NSObject
{
    CircleBuffer cirleBuffer;
    AudioQueueRef                 mQueue;
    AudioQueueBufferRef           mBuffers[kRecorderBufNum];
    bool                          mIsRunning;
}

@property (nonatomic, readonly) bool isRunning;
@property (nonatomic, assign) id<LiveAudioRecroderDelegate> delegate;

-(void)start;

-(void)stop;

@end
