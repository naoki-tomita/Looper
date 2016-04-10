//
//  LooperModel.swift
//  Looper
//
//  Created by 冨田 直希 on 2016/04/09.
//  Copyright © 2016年 冨田 直希. All rights reserved.
//

import Foundation
import AVFoundation

/**
 *
 */
class LooperModel {
  var audioUnit: AudioUnit?;
  var auGraph: AUGraph = AUGraph();
  let kOutputBus: UInt32 = 0;
  let kInputBus: UInt32 = 1;

  func initialize() {
    audioUnit = AudioUnit()
    var acd = AudioComponentDescription();
    acd.componentType = kAudioUnitType_Output;
    acd.componentSubType = kAudioUnitSubType_RemoteIO;
    acd.componentManufacturer = kAudioUnitManufacturer_Apple;
    acd.componentFlags = 0;
    acd.componentFlagsMask = 0;

    let ac = AudioComponentFindNext(nil, &acd);
    AudioComponentInstanceNew( ac, &audioUnit! );

    var input = AURenderCallbackStruct( inputProc: RecordingCallback, inputProcRefCon: &audioUnit );
    AudioUnitSetProperty(audioUnit!,
                         kAudioOutputUnitProperty_SetInputCallback,
                         kAudioUnitScope_Global,
                         kInputBus,
                         &input,
                         UInt32(sizeofValue(input)));

    input.inputProc = RenderCallback;
    AudioUnitSetProperty(audioUnit!,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Global,
                         kOutputBus,
                         &input,
                         UInt32(sizeofValue(input)));

    var flag: UInt32 = 1;
    AudioUnitSetProperty(audioUnit!,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         kInputBus,
                         &flag,
                         UInt32( sizeof( UInt32 ) ) );

    AudioUnitSetProperty(audioUnit!,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Output,
                         kOutputBus,
                         &flag,
                         UInt32( sizeof( UInt32 ) ) );

    var audioFormat: AudioStreamBasicDescription = AudioStreamBasicDescription();
    audioFormat.mSampleRate			  = 44100.00;
    audioFormat.mFormatID			    = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		  = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 1;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= 2;
    audioFormat.mBytesPerFrame		= 2;

    AudioUnitSetProperty( audioUnit!,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Output,
                          kInputBus,
                          &audioFormat,
                          UInt32( sizeof( AudioStreamBasicDescription ) ) );

    AudioUnitSetProperty( audioUnit!,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Input,
                          kOutputBus,
                          &audioFormat,
                          UInt32( sizeof( AudioStreamBasicDescription ) ) );

    flag = 0;
    AudioUnitSetProperty( audioUnit!,
                          kAudioUnitProperty_ShouldAllocateBuffer,
                          kAudioUnitScope_Output,
                          kInputBus,
                          &flag,
                          UInt32( sizeof( UInt32 ) ) );

    AudioUnitInitialize( audioUnit! );
  }

  func start() {
    if(( audioUnit ) == nil) {
      return;
    }
    NSLog("start");
    AudioOutputUnitStart( audioUnit! );
  }

  func end() {
    if(( audioUnit ) == nil) {
      return;
    }
    NSLog("end");
    AudioOutputUnitStop( audioUnit! );
  }
}

var bufs: AudioBufferList?;

func RecordingCallback(
  inRefCon: UnsafeMutablePointer<Void>,
  ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
  inTimeStamp: UnsafePointer<AudioTimeStamp>,
  inBusNumber: UInt32,
  inNumberFrames: UInt32,
  ioData: UnsafeMutablePointer<AudioBufferList>) -> (OSStatus)
{
  var err :OSStatus? = nil

  let buffer = allocateAudioBuffer(1 ,size: inNumberFrames)
  bufs = AudioBufferList.init(mNumberBuffers: 1, mBuffers: buffer)
  let au = UnsafeMutablePointer<AudioUnit>(inRefCon).memory;

  err = AudioUnitRender(au,
                        ioActionFlags,
                        inTimeStamp,
                        inBusNumber,
                        inNumberFrames,
                        &bufs!)

  return err!
}

func allocateAudioBuffer(let numChannel: UInt32, let size: UInt32) -> AudioBuffer {
  let dataSize = UInt32(numChannel * UInt32(sizeof(Float64)) * size)
  let data = malloc(Int(dataSize))
  let buffer = AudioBuffer.init(mNumberChannels: numChannel, mDataByteSize: dataSize, mData: data)

  return buffer
}

func checkStatus( status: OSStatus ) {
  if( status != 0 ) {
    NSLog("Error: %ld\n", status);
  }
}

/**
 音声の再生中に呼ばれるコールバック関数です
 */
func RenderCallback (
  inRefCon: UnsafeMutablePointer<Void>,
  ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
  inTimeStamp: UnsafePointer<AudioTimeStamp>,
  inBusNumber: UInt32,
  inNumberFrames: UInt32,
  ioData: UnsafeMutablePointer<AudioBufferList>) -> (OSStatus)
{
  memcpy( ioData.memory.mBuffers.mData , &bufs!.mBuffers.mData, Int( 1 * inNumberFrames * UInt32( sizeof( Float64 ) ) ) );

  let data=UnsafePointer<Int16>(bufs!.mBuffers.mData)

  let dataArray = UnsafeBufferPointer<Int16>(start:data, count: Int(bufs!.mBuffers.mDataByteSize)/sizeof(Int16))

  let io = UnsafeMutablePointer<Int16>( ioData.memory.mBuffers.mData );

  let ioDataArr = UnsafeMutableBufferPointer<Int16>(start: io, count: Int(bufs!.mBuffers.mDataByteSize)/sizeof(Int16));

  for i in 0...dataArray.count-1
  {
    ioDataArr[ i ] = dataArray[ i ];
  }

  bufs?.mBuffers.mData.dealloc(1);


  return noErr;
}