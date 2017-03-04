//
//  LiveAudioRecorder.m
//  webRtcSample
//
//  Created by 罗亮富 on 14-1-17.
//  Copyright (c) 2014年 Lolaage. All rights reserved.
//

#import "LiveAudioRecorder.h"

static void AQInputCallback (void                   * inUserData,
                             AudioQueueRef          inAudioQueue,
                             AudioQueueBufferRef    inBuffer,
                             const AudioTimeStamp   * inStartTime,
                             unsigned long          inNumPackets,
                             const AudioStreamPacketDescription * inPacketDesc);



@implementation LiveAudioRecorder
@synthesize isRunning = mIsRunning;
@synthesize delegate;

-(id)init
{
    self = [super init];
    if(self)
    {
        AudioStreamBasicDescription format; // 声音格式设置，这些设置要和采集时的配置一致
        memset(&format, 0, sizeof(format));
        
        format.mSampleRate = 16000; // 采样率 (立体声 = 8000)
        format.mFormatID = kAudioFormatLinearPCM; // PCM 格式
        format.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        format.mChannelsPerFrame = 1;  // 1:单声道；2:立体声
        format.mBitsPerChannel = 16; // 语音每采样点占用位数
        format.mBytesPerFrame = format.mBitsPerChannel*format.mChannelsPerFrame/8;
        format.mFramesPerPacket = 1;
        format.mBytesPerPacket = format.mBytesPerFrame;
        
        AudioQueueNewInput(&format,
                           AQInputCallback,
                           self,
                           CFRunLoopGetCurrent(),
                           kCFRunLoopCommonModes,
                           0,
                           &mQueue);

        
        for (int i = 0; i < kRecorderBufNum; ++i)
        {
            AudioQueueAllocateBuffer(mQueue, kRecorderBufSize, &mBuffers[i]);
            AudioQueueEnqueueBuffer(mQueue, mBuffers[i], 0, NULL);
        }
        
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        
        AudioSessionSetActive(true);
        
        mIsRunning = false;
    }
    return self;
}

-(void)start
{
    if(mIsRunning)
        return;

    AudioQueueStart(mQueue, NULL);
    mIsRunning = true;
  //  NSLog(@"Start record OSStatus %d",(int)s);
}

-(void)stop
{
    AudioQueueStop(mQueue, true);
    mIsRunning = false;
}

-(void)dealloc
{
    if(mIsRunning)
        [self stop];
    
    AudioQueueDispose(mQueue,true);
    
    [super dealloc];
}

@end

static void AQInputCallback (void                   * inUserData,
                             AudioQueueRef          inAudioQueue,
                             AudioQueueBufferRef    inBuffer,
                             const AudioTimeStamp   * inStartTime,
                             unsigned long          inNumPackets,
                             const AudioStreamPacketDescription * inPacketDesc)
{
    LiveAudioRecorder *r = (LiveAudioRecorder *)inUserData;
//    NSLog(@".......................");
  //  inBuffer->mAudioDataByteSize = 0;
    AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, 0, NULL);
    if(r.delegate && [r.delegate respondsToSelector:@selector(audioRecroder:didReadAudioData:length:)])
    {
        [r.delegate audioRecroder:r didReadAudioData:(char *)inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
    }

}
