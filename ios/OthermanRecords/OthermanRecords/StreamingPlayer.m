#import "StreamingPlayer.h"

@implementation StreamingPlayer

@synthesize streamInfo;

static void checkError(OSStatus err,const char *message)
{
    if(err){
        char property[5];
        *(UInt32 *)property = CFSwapInt32HostToBig(err);
        property[4] = '\0';
        //NSLog(@"%s = %-4.4s,%d",message, property,err);
        exit(1);
    }
}

void audioQueuePropertyListenerProc( void                  *inUserData, 
									AudioQueueRef         inAQ, 
									AudioQueuePropertyID  inID )
{
    StreamInfo *streamInfo = inUserData;
    if (streamInfo->isDone) {
        streamInfo->isPlaying = NO;
    }
}

void outputCallback( void                 *inClientData, 
					AudioQueueRef        inAQ, 
					AudioQueueBufferRef  inBuffer )
{
    StreamInfo* streamInfo = (StreamInfo*)inClientData;
    
    //㈰inBufferがstreamInfo->audioQueueBuffer[ ]のどれかを探す
    UInt32 bufIndex = 0;
    for (int i = 0; i < kNumberOfBuffers; ++i){
        if (inBuffer == streamInfo->audioQueueBuffer[i]){
            bufIndex = i;
            break;
        }
    }
    
    pthread_mutex_lock(&streamInfo->mutex);
    //㈪該当するインデックスを未使用（使用済み）にする
    streamInfo->inuse[bufIndex] = NO;
    //㈫pthread_cond_signalを呼んで、ロックを解除する
    pthread_cond_signal(&streamInfo->cond);
    pthread_mutex_unlock(&streamInfo->mutex);
}



static void enqueueBuffer(StreamInfo* streamInfo)
{
//    printf("--------%s\n",__PRETTY_FUNCTION__);
    OSStatus err = noErr;
    
    //バッファに充填済みフラグを立てる
    streamInfo->inuse[streamInfo->fillBufferIndex] = YES;
    
    AudioQueueBufferRef fillBuf 
	= streamInfo->audioQueueBuffer[streamInfo->fillBufferIndex];
    fillBuf->mAudioDataByteSize = streamInfo->bytesFilled;    
    
    err = AudioQueueEnqueueBuffer(streamInfo->audioQueueObject, 
                                  fillBuf, 
                                  streamInfo->packetsFilled, 
                                  streamInfo->packetDescs);
    checkError(err, "AudioQueueEnqueueBuffer");
    
    if (!streamInfo->started){
		printf("AudioQueueStart\n");
        err = AudioQueueStart(streamInfo->audioQueueObject, NULL);
        checkError(err, "AudioQueueStart");
        streamInfo->started = YES;
    }
    
    //インデックスを次に進める 0 -> 1, 1 -> 2, 2 -> 0
    if (++streamInfo->fillBufferIndex >= kNumberOfBuffers){
        streamInfo->fillBufferIndex = 0;
    }
    
    streamInfo->bytesFilled = 0;
    streamInfo->packetsFilled = 0;
    
    //バッファが使われるまで他の処理をロックする
    //一番古いバッファが再生されるのを待つ
    pthread_mutex_lock(&streamInfo->mutex);{
		while (streamInfo->inuse[streamInfo->fillBufferIndex]){
//            printf("WAITING... [%d]:\n",streamInfo->fillBufferIndex);
            pthread_cond_wait(&streamInfo->cond, &streamInfo->mutex);
        }
    }pthread_mutex_unlock(&streamInfo->mutex);
}


void propertyListenerProc(
                          void *							inClientData,
                          AudioFileStreamID				inAudioFileStream,
                          AudioFileStreamPropertyID		inPropertyID,
                          UInt32 *						ioFlags
)
{
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	StreamInfo* streamInfo = (StreamInfo*)inClientData;
	OSStatus err;
    
    //オーディオデータパケットを解析する準備が完了
    if(inPropertyID == kAudioFileStreamProperty_ReadyToProducePackets){
        
        //ASBDを取得する
        AudioStreamBasicDescription audioFormat;
        UInt32 size = sizeof(AudioStreamBasicDescription);
        err = AudioFileStreamGetProperty(inAudioFileStream,
                                         kAudioFileStreamProperty_DataFormat,
                                         &size,
                                         &audioFormat);
        checkError(err, "kAudioFileStreamProperty_DataFormat");
        
        //AudioQueueオブジェクトの作成
        err = AudioQueueNewOutput(&audioFormat,
                                  outputCallback,
                                  streamInfo, 
                                  NULL, NULL, 0, 
                                  &streamInfo->audioQueueObject);
        checkError(err, "AudioQueueNewOutput");
		
		AudioQueueAddPropertyListener(streamInfo->audioQueueObject, 
									  kAudioQueueProperty_IsRunning, 
									  audioQueuePropertyListenerProc, 
									  streamInfo);
		
		//キューバッファを用意する
		for (int i = 0; i < kNumberOfBuffers; ++i) {
			err = AudioQueueAllocateBuffer( streamInfo->audioQueueObject, 
										   kBufferSize, 
										   &streamInfo->audioQueueBuffer[i]);
			checkError(err, "AudioQueueAllocateBuffer");
		}
		
		UInt32 propertySize;
		
		//マジッククッキーのデータサイズを取得
		err = AudioFileStreamGetPropertyInfo( inAudioFileStream, 
											 kAudioFileStreamProperty_MagicCookieData,
											 &propertySize, 
											 NULL );
		if (!err && propertySize) {
			char *cookie =(char*)malloc(propertySize);
			
			//マジッククッキーを取得
			err = AudioFileStreamGetProperty( inAudioFileStream, 
											 kAudioFileStreamProperty_MagicCookieData,
											 &propertySize, 
											 cookie);
			checkError(err, "AudioQueueNewOutput");
			
			//キューにセット
			err = AudioQueueSetProperty( streamInfo->audioQueueObject, 
										kAudioQueueProperty_MagicCookie, 
										cookie, 
										propertySize );
			checkError(err, "kAudioQueueProperty_MagicCookie");
			free(cookie);
		}
    }
}


void packetsProc( void *inClientData,
				 UInt32                        inNumberBytes,
				 UInt32                        inNumberPackets,
				 const void                    *inInputData,
				 AudioStreamPacketDescription  *inPacketDescriptions )
{
	//NSLog(@"%s",__PRETTY_FUNCTION__);
    StreamInfo* streamInfo = (StreamInfo*)inClientData;
		
	if(inPacketDescriptions){
		for (int i = 0; i < inNumberPackets; i++) {
			SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
			SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
			
			//209分のスペースがない == これ以上バッファを埋められない ->エンキューする
			UInt32 bufSpaceRemaining = kBufferSize - streamInfo->bytesFilled;
			if(bufSpaceRemaining < packetSize){
				enqueueBuffer(streamInfo);
			}
			
			//fillBufferIndexは他のスレッドで書き換えられる可能性があるのでロックする
			pthread_mutex_lock(&streamInfo->mutex2);{
				//QueueBufferにコピー
				AudioQueueBufferRef fillBuf 
				= streamInfo->audioQueueBuffer[streamInfo->fillBufferIndex];
				memcpy((char*)fillBuf->mAudioData + streamInfo->bytesFilled, 
					   (const char*)inInputData + packetOffset, 
					   packetSize);
			}pthread_mutex_unlock(&streamInfo->mutex2);
			
			streamInfo->packetDescs[streamInfo->packetsFilled] 
			= inPacketDescriptions[i];
			
			//オフセットを設定
			streamInfo->packetDescs[streamInfo->packetsFilled].mStartOffset 
			= streamInfo->bytesFilled;
			
			streamInfo->bytesFilled += packetSize; //209
			streamInfo->packetsFilled++;           //処理したパケット数
			
			UInt32 packetsDescsRemaining 
			= kMaxPacketDescs - streamInfo->packetsFilled;
			
			//もしくは512パケット埋めたらこれ以上バッファを埋められないのでエンキュー
			if (packetsDescsRemaining == 0){
				enqueueBuffer(streamInfo);
			}
		}
    }else{//固定ビットレート
        UInt32 offset = 0;
        UInt32 bufferByteSize = inNumberBytes;
		
        //bufferByteSize分のデータをバッファにコピーするまで続ける
        while (bufferByteSize){ 
            //現在のバッファにbufferByteSize分の空きがあるか
            UInt32 bufSpaceRemaining = kBufferSize - streamInfo->bytesFilled;            
            //無ければエンキューする
            if(bufSpaceRemaining < bufferByteSize){
                enqueueBuffer(streamInfo);
            }
            
            UInt32 copySize;
            pthread_mutex_lock(&streamInfo->mutex2);{
                AudioQueueBufferRef fillBuf 
				= streamInfo->audioQueueBuffer[streamInfo->fillBufferIndex];
                bufSpaceRemaining = kBufferSize - streamInfo->bytesFilled;
                
                //bufferByteSize分の空きがあれば、それだけコピーする
                if (bufSpaceRemaining >= bufferByteSize){
                    copySize = bufferByteSize;
                }else{//無ければ、空きの分だけをコピーする
                    copySize = bufSpaceRemaining;
                }
                //inInputDataをoffset位置からbytesFilled以降にコピーする
                memcpy(fillBuf->mAudioData + streamInfo->bytesFilled, 
                       inInputData + offset, 
                       copySize);
                
            }pthread_mutex_unlock(&streamInfo->mutex2);
            
            //copySizeを次の処理に反映させる
            streamInfo->bytesFilled += copySize;
            bufferByteSize -= copySize;
            offset += copySize;
        }
    }
}


static void readStreamCallBack(CFReadStreamRef stream, 
                               CFStreamEventType type, 
                               void *clientCallBackInfo)
{
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	OSStatus err;
    StreamingPlayer *self = (__bridge StreamingPlayer*)clientCallBackInfo;
	StreamInfo streamInfo = self.streamInfo;
    
    CFTypeRef response = CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
    CFIndex code = CFHTTPMessageGetResponseStatusCode((CFHTTPMessageRef)response);
    if(code != 200){ //200 == successfully
        NSLog(@"http code : %d", code);

        [self downloadDidFail];
        return;
    }
	
	
    switch(type){
        case kCFStreamEventHasBytesAvailable:{//パケットを受信した
            UInt8 bytes[32768];
            CFIndex length = CFReadStreamRead(stream, bytes, 32768);
            if(length == -1){
                return;
            }			
            err = AudioFileStreamParseBytes(streamInfo.audioFileStream,
                                      length, 
                                      &bytes, 
                                      0);
			checkError(err, "AudioFileStreamParseBytes");
            break;
        }
		case kCFStreamEventErrorOccurred:{//エラーが発生した場合   
            [self downloadDidFail];
            break;
        }
		case kCFStreamEventEndEncountered:{  //ダウンロード終了
			if (streamInfo.started){
				err = AudioQueueFlush(streamInfo.audioQueueObject);
				checkError(err, "AudioQueueFlush");
				
				streamInfo.isDone = YES;
				err = AudioQueueStop(streamInfo.audioQueueObject, NO);
				checkError(err, "AudioQueueStop");
			}
			break;
		}
    }
}

+(StreamingPlayer *)getInstance
{
    static dispatch_once_t pred;
    static StreamingPlayer *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

-(id)init
{
    return [super init];
}

- (void)startWithURL:(NSString *)urlStr
{
    url = [NSURL URLWithString:urlStr];
    [self start];
}

- (void)start {
    
    NSLog(@"ca5test -- start ---");
    if (streamInfo.isPlaying){
        NSLog(@"ca5test -- stop before start ---");
        [self stop];
    }
    if (streamInfo.isPlaying) return;
    //スレッドを作成
    [NSThread detachNewThreadSelector:@selector(startThread)
                              toTarget:self
                            withObject:nil];
    NSLog(@"ca5test -- after make thread ---");
}	

-(void)stop{
    NSLog(@"ca5test -- stop ---");

    if (!streamInfo.isPlaying) return;
    NSLog(@"ca5test -- stopping... ---");
    NSLog(@"streamInfo : %@", streamInfo);
    //NSLog(@"streamInfo started: %@", streamInfo.started);
    NSLog(@"streamInfo isDone: %@", streamInfo.isDone);
    //NSLog(@"streamInfo isPlaying: %@", streamInfo.isPlaying);


    if (streamInfo.started && !streamInfo.isDone) {
        NSLog(@"ca5test -- stop stoppingaaaa ---");
        //他のスレッドでのAudioQueueの操作をロック
        pthread_mutex_lock(&streamInfo.mutex2);{
            streamInfo.isDone = YES; //終了フラグを立てる
            OSStatus err = AudioQueueStop(streamInfo.audioQueueObject, YES);
            checkError(err, "AudioQueueStop");
        }pthread_mutex_unlock(&streamInfo.mutex2);
		
        //スレッドがロックされている場合があるので解除を実行する
        pthread_mutex_lock(&streamInfo.mutex);
        pthread_cond_signal(&streamInfo.cond);
        pthread_mutex_unlock(&streamInfo.mutex);
    }
    NSLog(@"ca5test -- stop done ---");

}

-(void)startThread
{
    //㈰バッファ用変数を初期化
    memset(streamInfo.inuse, 0, sizeof(BOOL) * kNumberOfBuffers);
    streamInfo.fillBufferIndex = 0;
    streamInfo.bytesFilled = 0;
    streamInfo.packetsFilled = 0;
    streamInfo.started = NO;
    streamInfo.isDone = NO;
    
    //㈪再生中のフラグをYESにする
    streamInfo.isPlaying = YES;
    
    pthread_mutex_init(&streamInfo.mutex, NULL);
    pthread_cond_init(&streamInfo.cond, NULL);
    pthread_mutex_init(&streamInfo.mutex2, NULL);
    
    OSStatus err = AudioFileStreamOpen( &streamInfo,
									   propertyListenerProc, 
									   packetsProc, 
									   0, //変更
									   &streamInfo.audioFileStream);
    checkError(err, "AudioFileStreamOpen");
    

    CFHTTPMessageRef message= CFHTTPMessageCreateRequest( NULL, 
														 (CFStringRef)@"GET", 
														 (__bridge CFURLRef)url, 
														 kCFHTTPVersion1_1 );
    streamInfo.stream = CFReadStreamCreateForHTTPRequest(NULL, message);
    
    //redirect対策
    CFReadStreamSetProperty(streamInfo.stream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);
    
    CFRelease(message);
    
    if (!CFReadStreamOpen(streamInfo.stream)) {
        CFRelease(streamInfo.stream);
    }else{
		CFStreamClientContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
        CFReadStreamSetClient( streamInfo.stream,
							  kCFStreamEventHasBytesAvailable 
							  | kCFStreamEventErrorOccurred 
							  | kCFStreamEventEndEncountered,
							  readStreamCallBack,
							  &context);
        CFReadStreamScheduleWithRunLoop( streamInfo.stream,
										CFRunLoopGetCurrent(),
										kCFRunLoopCommonModes);
    }
    
    //㈫再生中はスレッドが終了しないようにする
    do{
        //RunLoopを0.25秒毎に実行する
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.25, false);
    } while (streamInfo.isPlaying);
    
    NSLog(@"*********Thread Did End");
    
    //CFReadStreamの後始末
    if (streamInfo.stream) {
        CFReadStreamClose(streamInfo.stream);
        CFRelease(streamInfo.stream);
        //streamInfo.stream = nil;
    }
}


-(void)downloadDidFail
{
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	if(streamInfo.started){
		pthread_cond_signal(&streamInfo.cond);
		AudioQueueStop(streamInfo.audioQueueObject, YES);
		AudioQueueDispose(streamInfo.audioQueueObject, YES);
	}
	
    CFReadStreamClose(streamInfo.stream);
    CFRelease(streamInfo.stream);
}

@end