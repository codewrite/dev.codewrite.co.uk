---
title: "Generating sounds on the Arduino"
date: 2020-08-13
draft: false
categories:
  - arduino
  - wav
  - mosfet
---

![Arduino WAV Player 1](/images/arduinoSoundClassD/ArduinoWAVPlayer1.jpg)
![Arduino WAV Player 2](/images/arduinoSoundClassD/ArduinoWAVPlayer2.jpg)

This is a small project to read wav files from a micro SD card via an Arduino Nano and then play them directly to a loudspeaker.
I'll state upfront that this isn't the easiest way to do this (there are MP3 modules and libraries), but I wanted to:
1. Understand sound generation using a microcontroller from first principles
2. Have some tools / ideas about how to generate sounds for any future projects

As an idea of the sort of thing I was thinking of - I've been thinking of a DIY "ring" doorbell. I already have a camera that can see anyone approaching the front door. A 433.92MHz receiver could detect when the doorbell is pressed (so no new doorbell required). A Raspberry Pi (i.e. the one with the camera) controlling it all and sending and receiving to my mobile phone. A lot more work than just buying a Ring doorbell - but a lot more satisfying!

To drive the loudspeaker I used a power MOSFET. Ideally I would use two (or maybe four) MOSFETs in a push pull arrangement. I was more interested in getting the software right however, so I didn't spend a lot of time getting the hardware correct. [Figure 3 on this page][Class D Audio Amplifiers] would seem be the ideal solution, but I suspect that if I went down this route it would need four independently controllable PWM inputs - and having given this a bit of thought - I think this would be best done with an FPGA. That's a project for another day! (but it would be pretty awesome). ...or maybe I'll just buy an audio amplifier module from Aliexpress :)

<details>
<summary>Hardware:</summary>

![Arduino Loudspeaker Driver](/images/arduinoSoundClassD/ArduinoClassDSchematic.png)

...and an SD card module for the Arduino. They cost about 50p if you get them directly from China.
</details>

<br/>
I realized early on that PWM was the easiest way to generate the sound - and after some investigation and calculations worked out that I could have 8 bit audio with a PWM running at 62.5KHz (16MHz clock divided by 256).<br/><br/>

<details>
<summary>PWM code (62.5KHz):</summary>

````c
inline void fastWriteD3(int value)
{
  if (value) PORTD |= 1 << 3;
  else PORTD &= ~(1 << 3);
}

// Using Timer 2 B = pin D3, 62.5KHz i.e. no prescaler
void setupPWMTimer()
{
  pinMode(3, OUTPUT);
  //pinMode(11, OUTPUT);
  TCCR2A = _BV(COM2B1) | _BV(WGM21) | _BV(WGM20);
  TCCR2B = _BV(CS20);
  OCR2B = 0x80;
}

void updatePWMTimer(uint8_t val)
{
  if (val == 0)
  {
    TCCR2A &= ~_BV(COM2B1);
    fastWriteD3(0);
  }
  else if (val == 0xff)
  {
    TCCR2A &= ~_BV(COM2B1);
    fastWriteD3(1);
  }
  else
  {
    TCCR2A |= _BV(COM2B1);
    OCR2B = val;
  }
}
````
</details>

<br/>
The next thing I needed was to play each sample. I probably could do one channel at 44KHz but decided to use 16KHz - which would mean the upper frequency limit would be 8KHz. Nowhere near HiFi, but easily good enough for what I was trying to achieve. So I created an interrupt routine that occurred 16,000 times a second with the following code:<br/><br/>

<details>
<summary>Interrupt code (16KHz):</summary>

````c
ISR(TIMER1_COMPA_vect)
{
  if (dataFirst != dataLast)
  {
    uint8_t val = dataBuffer[dataFirst++];
    if (dataFirst == DATA_BUFFER_SIZE)
    {
      dataFirst = 0;
    }
    updatePWMTimer(val);
  }
  else if (!paused)
  {
    noData = true;
  }
}

// Set timer1 interrupt at 16kHz
void setup16KHzTimer()
{
  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1  = 0;               //initialize counter value to 0
  OCR1A = 1000;             // = (16*10^6) / (1 * 16000) - 1 (must be <65536)
  TCCR1B |= (1 << WGM12);   // turn on CTC mode
  TCCR1B |= (1 << CS10);    // Set CS10 bit for no prescaler
  TIMSK1 |= (1 << OCIE1A);  // enable timer compare interrupt
  sei();
}
````
</details>

<br/>
Every time the interrupt occurs one sample of the WAV file should be sent to the PWM. You can see this in the ISR.

I haven't included the SD card reading code here (because it's not the reason for this article), but the entire sketch can be be found [on this github repo][Arduino Code Github Repo].

<br/>
And this is what it sounds like:

<audio src="/sounds/ArduinoWavPlayer1.mp3" controls>Radiohead</audio>
<audio src="/sounds/ArduinoWavPlayer2.mp3" controls>Billy Joel</audio>

There seems to be lots of noise in the background of both tracks - but it was raining very hard outside when I recorded them - so it might be that.

I created the WAV files using Audacity - 8 bit @ 16,000 samples per second - which works out to about 1 MByte / minute.
I'll be the first to admit it's not HiFi quality - but it's not bad considering how it's being generated (well I think anyway :))

## What I learnt

I did some tests and found that I could read the data from the SD card about 7 times faster than I needed it.

Therefore I should be able to do stereo (although I'm not sure what the point would be) but I would need another PWM channel.

## References (websites)

- [Secrets of Arduino PWM][Arduino PWM]
- [Arduino Interrupts][Arduino Interrupts]
- [Wav File format][WAV Format]

[//]: # (# -------------)
[//]: # (#  References)
[//]: # (# -------------)

[Class D Audio Amplifiers]: https://www.analog.com/en/analog-dialogue/articles/class-d-audio-amplifiers.html
[Arduino Code Github Repo]: https://github.com/codewrite/ArduinoNanoWavPlayer

[Arduino PWM]: https://www.arduino.cc/en/Tutorial/SecretsOfArduinoPWM
[Arduino Interrupts]: https://www.instructables.com/id/Arduino-Timer-Interrupts/
[WAV Format]: http://soundfile.sapp.org/doc/WaveFormat/
