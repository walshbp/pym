
from sdl2 import *
import OpenGL
#OpenGL.ERROR_CHECKING = False
from OpenGL.GL import *
from OpenGL.GLU import *

import pym
import functools
import numpy
import ctypes

PyBUF_READ = 0x100
PyBUF_WRITE = 0x200

def callback2(self, user_data, stream, length):

    #
    # https://stackoverflow.com/questions/4355524/getting-data-from-ctypes-array-into-numpy
    #

    buffer_from_memory = ctypes.pythonapi.PyMemoryView_FromMemory
    buffer_from_memory.restype = ctypes.py_object
    buffer = buffer_from_memory(stream, length, PyBUF_WRITE)
    stream_out = numpy.frombuffer(buffer, numpy.float32)
    self.pym.PCM().addPCMfloat(stream_out)

class PmSdl(object):    
    def __init__(self, settings, flags):
        self.width = settings.windowWidth
        self.height = settings.windowHeight
        self.done = 0
        self.isFullScreen = False
        self.pym = pym.Pym(settings,flags)
        self.pym.selectRandom(True)
        print("Playlist size %d\n",self.pym.getPlaylistSize())
        pass

    def init(self, window, renderer):
        self.win = window;
        self.rend = renderer;
        self.pym.selectRandom(True);
        self.pym.resetGL(self.width, self.height);
        pass

    def openAudioInput(self):
        # get audio driver name (static)
        driver_name = SDL_GetCurrentAudioDriver()
        SDL_Log(("Using audio driver: %s\n" % driver_name).encode('UTF-8'))

        # get audio input device
        count = SDL_GetNumAudioDevices(True)  # capture, please
        if count <= 0:
            SDL_LogCritical(SDL_LOG_CATEGORY_APPLICATION, "No audio capture devices found".encode('UTF-8'))
            SDL_Quit()

        for i in range(count):
            log_msg = ("Found audio capture device %d: %s" % (i, SDL_GetAudioDeviceName(i, True))).encode('UTF-8')
            SDL_Log(log_msg)

        selectedAudioDevice = 0 #SDL_AudioDeviceID(0) # device to open
        if count > 1:
            # need to choose which input device to use
            selectedAudioDevice = selectAudioInput(count)
            if selectedAudioDevice > count:
                SDL_LogCritical(SDL_LOG_CATEGORY_APPLICATION, "No audio input device specified.".encode('UTF-8'));
                SDL_Quit()
        
    

        # params for audio input
        # request format
        want = SDL_AudioSpec(freq = 48000, aformat = AUDIO_F32,channels = 2, samples = 512)
        have = SDL_AudioSpec(freq = 0 ,aformat = 0,channels = 0, samples = 0)

        self._bound_callback = functools.partial(callback2,self)
        want.callback = SDL_AudioCallback(self._bound_callback)
        want.userdata = 0
        
        audioDeviceName =  SDL_GetAudioDeviceName(selectedAudioDevice, True)
        self._audioDeviceID = SDL_OpenAudioDevice(
            audioDeviceName, True, want, have, 0)

        if self._audioDeviceID == 0:
            SDL_LogCritical(SDL_LOG_CATEGORY_APPLICATION, "Failed to open audio capture device: %s", SDL_GetError());
            SDL_Quit()
    

        # read characteristics of opened capture device
        log_msg = ("Opened audio capture device %i: %s" % (self._audioDeviceID, audioDeviceName)).encode('UTF-8')
        SDL_Log(log_msg);
        log_msg = ("Sample rate: %i, frequency: %i, channels: %i, format: %i" % (have.samples, have.freq, have.channels, have.format)).encode('UTF-8')
        SDL_Log(log_msg);
        self._audioChannelsCount = have.channels;
        self._audioSampleRate = have.freq;
        self._audioSampleCount = have.samples;
        self._audioFormat = have.format;
        self._audioInputDevice = self._audioDeviceID;
        return 1

    def beginAudioCapture(self):
        # allocate a buffer to store PCM data for feeding in
        maxSamples = self._audioChannelsCount * self._audioSampleCount;
        #pcmBuffer = (unsigned char *) malloc(maxSamples);
        SDL_PauseAudioDevice(self._audioDeviceID, False);
        self.pym.PCM().init(2048)
    
    def endAudioCapture(self):
        #free(pcmBuffer);
        SDL_PauseAudioDevice(self._audioDeviceID, True);
        

    def toggleFullScreen(self):
        self.pym.maximize()
        if self.isFullScreen:
            SDL_SetWindowFullscreen(win, SDL_WINDOW_FULLSCREEN_DESKTOP)
            self.isFullScreen = False
            SDL_ShowCursor(True)
        else:
            SDL_ShowCursor(False)
            SDL_SetWindowFullscreen(win, SDL_WINDOW_FULLSCREEN)
            self.isFullScreen = True

    def resize(self, width, height):
        self.width = width
        self.height = height
        #self.pym.settings.windowWidth = width
        #self.pym.settings.windowHeight = height
        self.pym.resetGL(width, height)
        pass

    def renderFrame(self):
        glClearColor( 0.0, 0.0, 0.0, 0.0 )
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        self.pym.renderFrame()
        glFlush()

        SDL_RenderPresent(self.rend)
        pass

    def _callback(self, notused, stream, length):
        print ("Hello")
        #print ("Stream" +str(stream))
        #print ("Length" +str(length))

        #self.pym.pcm().addPCMfloat(stream,length)


    def pollEvent(self):
        evt = SDL_Event()

        SDL_PollEvent(evt)
        if evt.type == SDL_WINDOWEVENT:
            if evt.window.event == SDL_WINDOWEVENT_RESIZED:
                self.resize(evt.window.data1, evt.window.data2)
        elif evt.type == SDL_KEYDOWN:
            self.keyHandler(evt)
        elif evt.type == SDL_QUIT:
            self.done = True;


    def maximize(self):
        dm = SDL_DisplayMode()
        if SDL_GetDesktopDisplayMode(0, dm) != 0:
            SDL_Log("SDL_GetDesktopDisplayMode failed: %s", SDL_GetError());
            return
        

        SDL_SetWindowSize(self.win, dm.w, dm.h)
        self.pym.resize(dm.w, dm.h)
        
    def keyHandler(self, sdl_evt):
        pass
        # TODO:
        # projectMEvent evt;
        # projectMKeycode key;
        # projectMModifier mod;
        # SDL_Keymod sdl_mod = (SDL_Keymod) sdl_evt->key.keysym.mod;
        # SDL_Keycode sdl_keycode = sdl_evt->key.keysym.sym;

        # // handle keyboard input (for our app first, then projectM)
        # switch (sdl_keycode) {
        #     case SDLK_f:
        #         if (sdl_mod & KMOD_LGUI || sdl_mod & KMOD_RGUI || sdl_mod & KMOD_LCTRL) {
        #             // command-f: fullscreen
        #             toggleFullScreen();
        #             return; // handled
        #         }
        #         break;
        # }

        # // translate into projectM codes and perform default projectM handler
        # evt = sdl2pmEvent(sdl_evt);
        # key = sdl2pmKeycode(sdl_keycode);
        # mod = sdl2pmModifier(sdl_mod);
        # key_handler(evt, key, mod);