#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CFNetwork/CFNetwork.h>
#include <pthread.h>

#define kNumberOfBuffers 3     //バッファの数
#define kBufferSize 32768      //バッファサイズ
#define kMaxPacketDescs 512    //最大ASPD数

typedef struct StreamInfo{
    CFReadStreamRef   stream;
    AudioFileStreamID audioFileStream;
    AudioQueueRef     audioQueueObject;
    BOOL              started;
    
    AudioQueueBufferRef  audioQueueBuffer[kNumberOfBuffers];
    AudioStreamPacketDescription  packetDescs[kMaxPacketDescs];
	
    BOOL  inuse[kNumberOfBuffers];  //バッファが使用されているか    
    UInt32 fillBufferIndex;         //バッファの埋めるべき位置
    UInt32 bytesFilled;             //何Byteバッファを埋めたか
    UInt32 packetsFilled;           //パケットを埋めた数
    
    pthread_mutex_t mutex;          //ロックに使用する
    pthread_mutex_t mutex2;         //ロックに使用する
    pthread_cond_t  cond;           //ロックに使用する
	
	BOOL isPlaying;  //再生中かどうか
    BOOL isDone;     //再生が終了したかどうか
}StreamInfo;

@interface StreamingPlayer: NSObject{
    NSURL *url;
    StreamInfo streamInfo;
}

@property StreamInfo streamInfo;

+(StreamingPlayer *)getInstance;
-(void)startWithURL:(NSString *)urlStr;
-(void)start;
-(void)stop;
-(void)downloadDidFail;
@end